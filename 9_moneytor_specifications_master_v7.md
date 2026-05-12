# Master Specification Document (MVP v7.8) - Architecture & Design

**Project:** Moneytor
**Date:** May 2026
**Status:** COMPLETE (Finalized for Development & DevOps)

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

## 4. Internationalization (I18n) & Currency

### A. Translation Strategy
*   **Primary Language:** English (Codebase & Default UI).
*   **Supported Languages:** French (MVP), English.
*   **Tooling:** `flutter_localizations` with `.arb` files.
*   **Auto-Detection:** App starts in system language if supported, else defaults to English.

### B. Currency Management
*   **Constraint:** One currency per Household.
*   **Supported Currencies:** Any ISO 4217 code (EUR, USD, GBP, CHF, etc.).
*   **Formatting:** Using `intl` package for local currency symbols and decimal placement based on the chosen ISO code.

---

## 5. Input Logic: Quick Add BottomSheet
*   **Digital Hub:** Always-present numeric keypad on mobile.
*   **Web Capture:** Captures global 0-9, dot, and Enter keystrokes.

---

## 6. Monetization (Household Model)
*   **Free Tier:** 1 User, 3 Accounts, 10 Budgets.
*   **Premium:** Shared household, Unlimited data, Projects, Smart Coaching.

---

## 7. Visual Identity: The Monochrome Protocol
*   **Palette:** Pure White (#FFFFFF), Pure Black (#000000).
*   **Radius:** 8px. **Borders:** 1px.

---

## 8. DevOps & GitHub Strategy

### A. CI/CD (GitHub Actions)
*   **Workflow:** On Push/PR to `main`.
*   **Jobs:** `flutter analyze`, `flutter test`.

### B. Project Management
*   **GitHub Project:** Automated board with "Todo", "In Progress", "Review", "Done".
*   **Issues:** Systematic creation of issues for each feature (Auth, Dashboard, Sync, etc.).
