# Moneytor UI/UX Design Specifications

**Theme:** The Monochrome Protocol (Black & White, Shadcn-inspired)
**Typography:** Inter (Body), JetBrains Mono (Financials/Numbers)
**Components:** 8px Radius, 1px Borders, Slate Gray accents (#71717A)

---

## 1. Global Navigation

### A. Bottom Navigation Bar
- **4 Static Tabs:** Dashboard, Accounts, Budgets, Projects.
- **Central Action:** Elevated Floating Action Button (FAB) with a **(+)** icon.
- **Design:** The FAB's center sits on the top edge of the navigation bar, overlapping slightly with the screen content for a prominent "Quick Add" feel.

---

## 2. Dashboard (Home)

### A. Header
- **Greeting:** "Bonjour, [Name]" on the left.
- **Notifications:** A bell icon on the right with a red numeric badge for `pending` tasks.
- **Date:** Current Financial Period name (e.g., "April / May").

### B. Hero Section (The RAV Split)
- **Visual:** A large card with a subtle horizontal separator.
- **Top Half:** **Current Disposable Income** (Large font, e.g., "850.00 €"). Calculated from cleared transactions.
- **Bottom Half:** **Forecasted Month-End RAV** (Smaller font, e.g., "Est: 720.00 €"). Includes all pending transactions for the period.

### C. "Coming This Week" Carousel
- **Content:** Horizontal slidable cards of `pending` transactions (Invoices/Bills).
- **Behavior:** Auto-sliding + Manual swipe.
- **Interaction:** Tapping a card opens a modal to "Adjust & Clear" (confirm final amount and validate).

### D. Budget Grid
- **Layout:** 2x2 grid of interactive cards.
- **Selection:** Shows **Pinned** budgets (user choice) or **Top 4** by volume.
- **Card Details:** Icon (Lucide), Name, Progress Bar (Grayscale), and "Spent / Total" text.
- **Interaction:** Clicking a card navigates to the detailed Budget transaction list.

---

## 3. Accounts Screen (Command Center)

### A. Cycle Control (Payday Logic)
- **Display:** "Current Period: [Start Date] - [End Date]".
- **Actions:** 
    - **"Start Next Month Now":** Immediate transition to the next cycle.
    - **"Delay +1 Day":** Extends the current cycle by 24h.
- **Edit Mode:** A small "pencil" icon allows manual date adjustment for the last two periods (error correction).

### B. Account List
- **Card Design:** Plain cards with a border.
- **Details:** Name, Type badge (Joint/Personal), and Calculated Balance.
- **Privacy:** A padlock icon if `is_public = FALSE`.
- **Linked Envelopes:** Horizontal list of mini-chips representing budgets drawing from this account.

### C. Bill Management (Sub-view)
- **Entry:** A "Manage Bills" button inside each account card.
- **Content:** List of `recurring_templates`.
- **Action:** Toggle `is_active` or edit the "Theory" amount.

---

## 4. Budgets Screen (Management)

### A. Period Selector
- **UI:** Horizontal scrollable header of period names (e.g., "March", "April", "May").
- **Auto-Scroll:** Centers the current active period on load.

### B. Hierarchy View
- **Folders:** The main list shows mandatory Budget envelopes (Folders).
- **Sub-filters:** Within a budget detail, a small toggle or chip list to filter by Category (e.g., Budget "Food" -> Filter "Restaurant").

### C. Detail View
- **Summary:** Simple graph (Bar or Line) of spending speed.
- **Transaction List:** Filtered by the selected budget and period.
- **Shortcut:** "Edit Budget" button in the top right.

---

## 5. Projects Screen (The Vegas Bubble)

### A. Goal Tracking
- **Progress:** Large circular gauge showing `% of Target Amount`.
- **Labels:** Total Spent vs. Target.

### B. Mini-Tricount (Debt Alerts)
- **UI:** A conditional warning box: "Déséquilibre : The Joint Account owes you [Amount]".
- **Action:** **"Absorb Debt"** button. Flagging as "gift" removes the alert but keeps the stat.

---

## 6. Quick Add BottomSheet (The Engine)

### A. Input Layout
- **Toggle:** Income / Expense switcher at the very top.
- **Display:** Massive number display (JetBrains Mono).
- **Selectors:** Two side-by-side selectors for **Account** and **Budget**.
- **Note:** Placeholder field (+ Note, ex: "Carrefour").

### B. Custom Digital Keypad
- **UI:** A 0-9 numeric pad with a dot and a large backspace button.
- **Always Present:** Does **NOT** use the system keyboard on mobile to prevent layout jumps.
- **Web:** Global listener for physical key presses (0-9, ., Backspace, Enter).

---

## 7. Notification Center

### A. List Content
- **Types:**
    - `pending_tx`: "A bill is due today."
    - `duplicate`: "Potential duplicate detected!"
    - `sync_summary`: "Anna deleted 'Shopping' while you were away."
    - `coaching`: "You have a surplus! Move 150€ to savings."
