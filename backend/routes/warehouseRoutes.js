const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Warehouse = require('../models/Warehouse');
const Order = require('../models/Order');
const StockLedger = require('../models/StockLedger');
const InventoryService = require('../services/inventoryService');

// Create/Update Warehouse
router.post('/create', async (req, res) => {
    try {
        const warehouse = new Warehouse(req.body);
        await warehouse.save();
        res.status(201).json({ success: true, warehouse });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Get Warehouses
router.get('/list', async (req, res) => {
    try {
        const warehouses = await Warehouse.find();
        res.json({ success: true, warehouses });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Add Stock (Bulk with Batches)
router.post('/add-stock', async (req, res) => {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
        const { warehouseId, items } = req.body;
        const warehouse = await Warehouse.findById(warehouseId).session(session);
        if (!warehouse) throw new Error('Warehouse not found');

        for (const item of items) {
            let invItem = warehouse.inventory.find(i => 
                (item.skuCode && i.skuCode === item.skuCode) || (item.name && i.name === item.name)
            );

            if (!invItem) {
                invItem = { skuCode: item.skuCode, name: item.name, qty: 0, batches: [] };
                warehouse.inventory.push(invItem);
                // Need to find it again to get the reference if not found
                invItem = warehouse.inventory[warehouse.inventory.length - 1];
            }

            const batch = {
                batchNumber: item.batchNumber || `BATCH-${Date.now()}`,
                qty: item.qty,
                expiry: item.expiry || new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days default
            };
            invItem.batches.push(batch);
            invItem.qty += item.qty;

            // Log movement
            await new StockLedger({
                productId: item.skuCode || item.name,
                warehouseId,
                type: 'ADD',
                qty: item.qty,
                details: `Stock entry: ${batch.batchNumber}`
            }).save({ session });
        }

        warehouse.recalculateCapacity();
        await warehouse.save({ session });

        await session.commitTransaction();
        res.json({ success: true, message: 'Stock added successfully' });
    } catch (error) {
        await session.abortTransaction();
        res.status(500).json({ success: false, message: error.message });
    } finally {
        session.endSession();
    }
});

// Assign to Order (Atomic with FIFO)
router.post('/assign-to-order', async (req, res) => {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
        const { orderId, warehouseId } = req.body;
        const order = await Order.findOne({ id: orderId }).session(session);
        if (!order) throw new Error('Order not found');

        // Check for double allocation or status change
        if (order.sourceWarehouse) {
            // Restore previous stock if already assigned
            await InventoryService.restoreStock(order.sourceWarehouse, order.items, session);
        }

        // Allocate using FIFO
        const allocatedItems = await InventoryService.allocateStock(warehouseId, order.items, orderId, session);

        // Update Order
        order.items = allocatedItems;
        order.sourceWarehouse = warehouseId;
        order.status = 'Pending Packing';
        order.statusHistory.push({ status: 'Pending Packing' });
        await order.save({ session });

        await session.commitTransaction();
        res.json({ success: true, message: 'Order assigned to warehouse with FIFO allocation' });
    } catch (error) {
        await session.abortTransaction();
        res.status(500).json({ success: false, message: error.message });
    } finally {
        session.endSession();
    }
});

module.exports = router;
