Perfect 👍 — here’s your **final, clear instruction summary** including the pagination reference note for development:

---

## 🔹 **Billing Page Functionality (with Client Page & Cubit Reference)**

### **1. Filters**

- Two filter groups:

  1. **Payment Status:** `Paid`, `Unpaid`, `Partially Paid`
  2. **Date Range:** `All`, `Last Month`, `Last 3 Months`, `Custom`

- For each filter combination:

  - **Only 10 documents** are fetched initially.
  - On clicking **Next**, load the **next 10 documents** of the same filter.
  - Pagination logic should follow the **same approach used in the Client Page and Cubit**.

---

### **2. Search**

- When a search is performed:

  - Only **top 10 matching documents** are shown (no pagination).
  - Search applies within the **current filter context** (e.g., _Last Month + Paid_).
  - When the search is cleared, revert to the **previous filtered document list** with pagination restored.

---

### **3. Combined Filter + Search**

- Example flow:

  - User selects **Last Month + Paid** → show 10 docs.
  - Click **Next** → next 10 docs (same filter).
  - Perform search → show top 10 matching docs (no pagination).
  - Clear search → revert to filtered docs view (pagination enabled).

---

### **4. Client Page**

- The **Client Page** should have the **same filtering, search, and pagination logic** as the Billing Page.
- Use the **existing pagination system from the Client Cubit** for consistent functionality and performance.

---

### **5. Categories**

- **Fetch categories immediately after user login** so that data is available globally across all relevant components.

---

### **6. Partial Payments**

- For any bill with status **Partially Paid**:

  - Show an option to **pay the remaining balance**.
  - After payment:

    - If balance = 0 → status becomes **Paid**.
    - If partial balance remains → status stays **Partially Paid**.

---

### **7. Transaction Handling**

- Whenever a **new bill is created** or a **partial payment is updated**,
  → A corresponding **transaction record** should automatically be created in the Transactions collection.

