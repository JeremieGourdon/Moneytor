# Moneytor - Project Overview & Instructions

Moneytor is a professional, local-first, multi-platform personal finance application (Mobile/Web) designed for household management with high-tier privacy, offline resilience, and seamless synchronization.

## 🚀 Technical Stack

- **Frontend:** Flutter (Riverpod, GoRouter, Lucide Icons)
- **BaaS (Backend):** Supabase (PostgreSQL, Auth, Edge Functions, pg_cron)
- **Local-First Sync:** PowerSync + `sqlite_async` (WASM/IndexedDB support)
- **Data Precision:** All amounts stored as **BIGINT** (cents)
- **Monetization:** RevenueCat (`purchases_flutter`)

## 🏗️ Architecture & Core Principles

### 1. Database & Sync (Local-First)
- **UUIDs:** Mandatory client-side `UUIDv4` generation for all primary keys.
- **Soft Delete:** NEVER use physical SQL deletes. Use the `deleted_at` timestamp.
- **UTC Enforcement:** All timestamps (`created_at`, `updated_at`, `transaction_date`) MUST be in **UTC**.
- **Calculated State:** Balances and Disposable Income are calculated on-the-fly (SQLite `SUM`). Never cache balances.

### 2. Business Logic
- **Disposable Income (DI):** Calculated per account. 
  - Formula: `DI = RealBalance - SUM(max(PlannedBudget, RealExpenses))`.
- **Privacy (Sync Path):** 
  - Joint accounts (`owner_id = NULL`) are always public.
  - Personal accounts can be toggled to `is_public = FALSE`.
  - **Security:** Private data is NEVER synced to the devices of other household members via PowerSync rules.
  - **Cleanup:** When `is_public` changes to `FALSE`, PowerSync must automatically remove (un-sync) the data from unauthorized local devices.
- **Budget Rules:** Mandatory linking to an `account_id`. Overages are absorbed by the account balance (Zero-floor rule).
- **Fallback:** Transactions without a chosen envelope are assigned to the system-generated **"Unplanned"** budget.

### 3. Workflows
- **Transfers:** Linked via `linked_transaction_id` (Double-entry logic).
- **Invoices:** Templates generate `pending` transactions via backend CRON jobs. Users confirm/clear them in-app.
- **Smart Duplicate:** Detection of identical transactions within a 48h window.
- **Multi-Currency:** Fixed ISO currency per household (e.g., 'EUR', 'USD').

## 🖼️ UI/UX Architecture

- **Navigation:** Persistent Bottom Bar with 4 tabs (Dashboard, Accounts, Budgets, Projects) and a central **Quick Add (+)** Floating Action Button (FAB) that triggers the entry BottomSheet.
- **Dashboard Layout:**
  - **Greeting & Notifications:** User greeting + Notification bell icon.
  - **Hero Section:** Primary "Current RAV" + Secondary "Forecasted Month-End RAV".
  - **Coming Week:** Horizontal slidable carousel of pending transactions.
  - **Budgets Overview:** 2x2 grid of interactive budget status cards.
- **Quick Add BottomSheet:**
  - Toggle for Income/Expense.
  - Large numeric display with a built-in custom keypad (0-9, dot, backspace).
  - Selectors for Account and Budget.
  - Note field with placeholder.
- **Web Specifics:** Captured keyboard input (0-9, ., Backspace, Enter) for fast entry.

## 🛠️ Development Workflow

- **Coding Standard:** MVVM architecture, composition-over-inheritance, strict type safety.
- **Formatting:** 80 characters line limit. Use `dart_format` and `dart_fix`.
- **Naming:** **English only** for all variables, tables, and documentation.
- **Analysis:** Always run `analyze_files` before testing.

---
*Note: This file is a foundational mandate. Refer to `9_moneytor_specifications_master_v7.md` for detailed algorithmic requirements.*
