const mongoose = require('mongoose');
const Warehouse = require('../models/Warehouse');
const StockLedger = require('../models/StockLedger');

class InventoryService {
    /**
     * Allocates stock from warehouse using FIFO (oldest batches first)
     */
    static async allocateStock(warehouseId, items, orderId, session) {
        const warehouse = await Warehouse.findById(warehouseId).session(session);
        if (!warehouse) throw new Error('Warehouse not found');

        const allocatedItems = [];

        for (const item of items) {
            const productSku = item.skuCode || item.name;
            const requiredQty = item.qty;

            // Find all batches for this product
            const inventoryItem = warehouse.inventory.find(inv => 
                inv.skuCode === productSku || inv.name === productSku
            );

            if (!inventoryItem || inventoryItem.qty < requiredQty) {
                throw new Error(`Insufficient stock for ${productSku}. Available: ${inventoryItem?.qty || 0}, Required: ${requiredQty}`);
            }

            // FIFO: Sort batches by expiry date (oldest first)
            inventoryItem.batches.sort((a, b) => new Date(a.expiry) - new Date(b.expiry));

            let remainingToAllocate = requiredQty;
            const allocatedBatches = [];

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

            // Deduct total qty from inventory item
            inventoryItem.qty -= requiredQty;

            allocatedItems.push({
                ...item,
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
