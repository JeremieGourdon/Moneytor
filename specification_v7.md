# Master Specification Document (MVP v7.7) - Architecture & Design

**Project:** Moneytor
**Date:** May 2026
**Status:** COMPLETE (Finalized for Development)

---

## 1. Technical Stack (`pubspec.yaml`)
*   **UI Framework:** `flutter` (Mobile/Web Multiplatform).
*   **BaaS (Backend):** `supabase_flutter` (PostgreSQL, Auth, pg_cron).
*   **Local-First Sync:** `powersync` + `sqlite_async` (WASM support).
*   **State Management:** `flutter_riverpod` (`riverpod_annotation`).
*   **Navigation:** `go_router`.
*   **Monetization:** `purchases_flutter` (RevenueCat).
*   **Charts:** `fl_chart` (Monochrome styling).
*   **Icons:** `flutter_lucide` (Shadcn style).
*   **Typography:** `google_fonts` (Inter & JetBrains Mono).

---

## 2. Database Rules (Local-First Specific)
1.  **Mandatory UUIDs:** Client-side generated `UUIDv4` for all primary keys.
2.  **Soft Deletion:** NEVER use SQL `DELETE`. Use `deleted_at (TIMESTAMP)`.
3.  **UTC Timestamps:** All dates (`created_at`, `updated_at`, `transaction_date`) MUST be in UTC.
4.  **No Balance Caching:** All balances are calculated on-the-fly via SQLite `SUM(amount)`.

---

## 3. Business Architecture

### A. Accounts and Privacy
*   **Joint Accounts:** `owner_id = NULL`, forced `is_public = TRUE`.
*   **Personal Accounts:** Toggleable `is_public`. If `FALSE`, data is purged from partner devices via PowerSync.

### B. Budgets (Envelopes)
*   **Hierarchy:** Budgets (Mandatory Folder) > Categories (Optional Filter).
*   **Zero-Floor Rule:** Budget overages are mathematically treated as 0 in RAV formulas (absorbed by account balance).

### C. Projects (The "Vegas" Rule)
*   **Mini-Tricount:** Detects when Account X pays for Project Y.
*   **Absorb Debt:** `ignore_in_balances = true` flags a transaction as a gift, removing the debt alert.

### D. Financial Cycles (Dynamic Payday)
*   **Manual Control:** Buttons to "Delay +1 Day" or "Start Next Month Now" from the Accounts screen.
*   **Chaining:** Adjusting Period N end-date automatically updates Period N+1 start-date.

---

## 4. Input Logic: Quick Add BottomSheet
*   **Digital Hub:** Always-present numeric keypad on mobile.
*   **Web Capture:** Captures global 0-9, dot, and Enter keystrokes.
*   **Smart Fallback:** Auto-selects last used budget and "Unplanned" system budget.

---

## 5. Monetization (Household Model)

### A. Free Tier (Solo Discovery)
*   **Limits:** 1 User, 3 Accounts, 10 Budgets. 
*   **Locked:** Household Sharing, Projects, Smart Coaching.

### B. Premium Tier (RevenueCat)
*   **Limits:** Unlimited everything, up to 5 members.
*   **Features:** Multi-device Sync, Debt Absorption, Coaching Engine.

---

## 6. Visual Identity: The Monochrome Protocol

### A. Design Tokens (Shadcn-Inspired)
*   **Palette:** Pure White (#FFFFFF), Pure Black (#000000), Slate Gray (#71717A).
*   **Alerts:** Red (#EF4444) for negative states only.
*   **Shapes:** 1px borders, 8px corner radius.

### B. Typography
*   **Body:** Inter.
*   **Financials:** JetBrains Mono (Monospace for precise alignment).

---

## 7. System Initialization & Cascade
*   **Auto-Init:** Create "Unplanned" Budget, "General" Category, and initial Financial Period on household creation.
*   **Cascade:** Deleting Account deletes all linked transactions/templates. Deleting Category sets ID to NULL on transactions.
