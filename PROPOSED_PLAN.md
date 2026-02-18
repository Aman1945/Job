# Implementation Plan - UI Improvements & Zone-wise Segregation

Maine aapke request ke basis par ye changes plan kiye hain:

## 1. Backend Changes (Node.js)
- `User` model mein `zone` field add karna (`WEST`, `EAST`, `SOUTH`, `NORTH`, `PAN INDIA`).
- User creation/update APIs ko update karna.

## 2. Flutter Models
- `User` model mein `zone` property add karna.

## 3. Step Assignment UI Improvements
- **Backdrop Blur**: Jab "Assign" popup khulega, toh background blur (0.3 level) ho jayega and white-themed popup aayega.
- **Zone-wise Segregation**: Dialog ke andar users list Zones (WEST, EAST, etc.) ke hisaab se divided hogi.
- **Workflow Labels Sync**: Screen ke labels ko image table ke labels (`Master Creation`, `Placed Order`, etc.) se sync kiya jayega.

## 4. Verification
- Admin dashboard se checks karna ki grouping sahi ho rahi hai ya nahi.
- Blur effect manually toggle karke verify karna.
