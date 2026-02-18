# Implementation Plan: Mandatory MongoDB Integration

As requested, this plan details the steps to remove the JSON file storage fallback and make MongoDB the mandatory database for the Nexus OMS backend. This ensures a robust, production-ready setup for deployment on DigitalOcean.

## Proposed Changes

### Backend Server

#### [MODIFY] [server.js](file:///c:/Users/Dell/Desktop/NEW%20JOB/backend/server.js)
- Remove `getData` and `saveData` helper functions.
- Remove the `useMongoDB` conditional variable and associated checks.
- Refactor all routes that currently have `if (useMongoDB)` logic to only contain the MongoDB logic:
    - `POST /api/orders`
    - `PATCH /api/orders/:id`
    - `DELETE /api/orders/:id`
    - `POST /api/orders/bulk-update`
    - `GET /api/procurement`
    - `POST /api/procurement`
    - `PUT /api/procurement/:id`
    - `DELETE /api/procurement/:id`
- Ensure the startup check for `MONGODB_URI` remains strict and exits the process if missing.

### Cleanup

#### [DELETE] `backend/data` directory
- Remove `customers.json`, `orders.json`, `products.json`, `users.json`, and any other JSON data files.

### Documentation

#### [MODIFY] [DIGITALOCEAN_DEPLOYMENT_GUIDE.md](file:///c:/Users/Dell/Desktop/NEW%20JOB/DIGITALOCEAN_DEPLOYMENT_GUIDE.md)
- Update the documentation to state that MongoDB is required and JSON storage is not supported.

---

## Verification Plan

### Manual Verification
1. **Startup Check**:
   - Run the server without `MONGODB_URI` in `.env`. Verify it prints `❌ FATAL: MONGODB_URI is missing` and exits.
2. **Connection Verification**:
   - Run the server with a valid `MONGODB_URI`. Verify it prints `✅ Connected to MongoDB Atlas`.
3. **API Integrity**:
   - Call `GET /api/health` and verify `database: "Connected"` is returned.
   - Perform a "Book Order" action in the app or via Postman and verify the data is saved in MongoDB (check MongoDB Atlas dashboard).
   - Ensure the `backend/data` folder is not recreated.
