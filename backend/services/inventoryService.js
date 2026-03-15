const mongoose = require('mongoose');
const Warehouse = require('../models/Warehouse');
const StockLedger = require('../models/StockLedger');

class InventoryService {
    /**
     * Allocates stock from warehouse. 
     * If items already have allocatedBatches (manual picking), it deducts from those specific batches.
     * Otherwise, it uses FEFO (oldest expiry first).
     */
    static async allocateStock(warehouseId, items, orderId, session) {
        const warehouse = await Warehouse.findById(warehouseId).session(session);
        if (!warehouse) throw new Error('Warehouse not found');

        const allocatedItems = [];

        for (const item of items) {
            const productSku = item.skuCode || item.productName || item.name;
            const requiredQty = item.quantity || item.qty || 0;
            console.log(`🔍 Processing Item: ${productSku}, Required Qty: ${requiredQty}`);

            // Find inventory entry in warehouse
            let inventoryItem = warehouse.inventory.find(inv => 
                (productSku && inv.skuCode === productSku) || (productSku && inv.name === productSku)
            );

            if (!inventoryItem) {
                console.warn(`⚠️  Stock item not found for ${productSku}. Fulfilling via VIRTUAL batch.`);
                inventoryItem = { skuCode: productSku, name: productSku, qty: 0, batches: [] };
                warehouse.inventory.push(inventoryItem);
                inventoryItem = warehouse.inventory[warehouse.inventory.length - 1];
            }

            const allocatedBatches = [];

            // CASE 1: MANUAL ALLOCATION (Provided by picker)
            if (item.allocatedBatches && item.allocatedBatches.length > 0) {
                console.log(`☝️  Found manual batches for ${productSku}`);
                for (const manual of item.allocatedBatches) {
                    const batch = inventoryItem.batches.find(b => b.batchNumber === manual.batchNumber);
                    if (!batch) {
                        // Create virtual batch if not found to prevent block
                        console.warn(`⚠️  Manual Batch ${manual.batchNumber} missing. Creating virtual.`);
                        inventoryItem.batches.push({
                            batchNumber: manual.batchNumber,
                            qty: manual.qty,
                            expiry: manual.expiry || new Date()
                        });
                    } else {
                        if (batch.qty < manual.qty) {
                            console.warn(`⚠️  Manual Batch ${manual.batchNumber} has insufficient qty. Overdrawing.`);
                        }
                        batch.qty -= manual.qty;
                    }
                    inventoryItem.qty -= manual.qty;
                    allocatedBatches.push(manual);
                }
            } 
            // CASE 2: AUTO ALLOCATION (FEFO)
            else {
                // FEFO: Sort batches by expiry date (oldest first)
                if (inventoryItem.batches && inventoryItem.batches.length > 0) {
                    inventoryItem.batches.sort((a, b) => new Date(a.expiry) - new Date(b.expiry));
                }

                let remainingToAllocate = requiredQty;
                for (const batch of inventoryItem.batches) {
                    if (remainingToAllocate <= 0) break;
                    const takeFromBatch = Math.min(batch.qty, remainingToAllocate);
                    batch.qty -= takeFromBatch;
                    remainingToAllocate -= takeFromBatch;
                    allocatedBatches.push({
                        batchNumber: batch.batchNumber,
                        qty: takeFromBatch,
                        expiry: batch.expiry
                    });
                }
                inventoryItem.qty -= requiredQty;
            }

            const itemToSave = item.toObject ? item.toObject() : item;
            allocatedItems.push({
                ...itemToSave,
                allocatedBatches
            });

            // Log movement
            await new StockLedger({
                orderId,
                productId: productSku,
                warehouseId,
                type: 'DEDUCT',
                qty: requiredQty,
                details: `Allocated for Order ${orderId}`
            }).save({ session });
        }

        warehouse.recalculateCapacity();
        await warehouse.save({ session });

        return allocatedItems;
    }

    /**
     * Validates if a scanned barcode belongs to an item in the warehouse and gets its details
     */
    static async validateBarcode(warehouseId, barcode, skuCode) {
        const warehouse = await Warehouse.findById(warehouseId);
        if (!warehouse) throw new Error('Warehouse not found');

        const invItem = warehouse.inventory.find(i => 
            i.skuCode === skuCode && (i.barcode === barcode || barcode === skuCode)
        );

        if (!invItem) {
            // Check global product catalog if not in warehouse inventory record directly
            const Product = require('../models/Product');
            const product = await Product.findOne({ skuCode, barcode });
            if (product) return { isValid: true, productName: product.name, batches: product.batches };
            return { isValid: false, message: 'SKU and Barcode mismatch' };
        }

        return { 
            isValid: true, 
            productName: invItem.name, 
            batches: invItem.batches.filter(b => b.qty > 0) 
        };
    }

    /**
     * Restores stock back to warehouse batches (e.g. on order cancellation)
     */
    static async restoreStock(warehouseId, items, session) {
        const warehouse = await Warehouse.findById(warehouseId).session(session);
        if (!warehouse) return;

        for (const item of items) {
            const productSku = item.skuCode || item.name;
            
            // Find inventory entry
            let inventoryItem = warehouse.inventory.find(inv => 
                inv.skuCode === productSku || inv.name === productSku
            );

            if (!inventoryItem) continue;

            // Restore batches
            if (item.allocatedBatches) {
                for (const allocated of item.allocatedBatches) {
                    let existingBatch = inventoryItem.batches.find(b => b.batchNumber === allocated.batchNumber);
                    if (existingBatch) {
                        existingBatch.qty += allocated.qty;
                    } else {
                        inventoryItem.batches.push(allocated);
                    }
                    inventoryItem.qty += allocated.qty;

                    // Log restoration
                    await new StockLedger({
                        productId: productSku,
                        warehouseId,
                        type: 'RESTORE',
                        qty: allocated.qty,
                        details: `Restored from Order modification`
                    }).save({ session });
                }
            }
        }

        warehouse.recalculateCapacity();
        await warehouse.save({ session });
    }
}

module.exports = InventoryService;
