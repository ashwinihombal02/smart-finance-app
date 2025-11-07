trackerapp

A Flutter-based personal finance tracker app called Smart Finance, which helps users manage transactions, track expenses, monitor budgets, and visualize spending trends.

Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

Lab: Write your first Flutter app

Cookbook: Useful Flutter samples

For help getting started with Flutter development, view the online documentation
, which offers tutorials, samples, guidance on mobile development, and a full API reference.

Features

Dashboard: Overview of wallet balance, income, expenses, and budget progress.

Transaction Management: Add, edit, and delete income or expense transactions.

Budget Overview: Track monthly budgets by category with progress indicators.

Expense Visualization: Pie chart showing expenses by category.

Pull-to-Refresh: Update transactions easily.

Floating Action Buttons: Quick access to add transactions or view history.

Drawer Navigation: Navigate between Dashboard, Transactions, and Budgets.

Responsive Design: Works across multiple screen sizes.

Architecture & State Management

State Management: Provider for reactive state updates.

Data Handling:

Transactions and budgets managed via FinanceProvider.

Calculates total income, total expense, and category-wise expenses.

UI Layer:

DashboardPage shows balance, budget, recent transactions, and pie chart.

AddEditTransactionPage handles adding/editing transactions.

TransactionsPage shows the full list of transactions.

BudgetPage shows budget management overview.

Design: Uses Google Fonts (Poppins).

Charts: fl_chart for pie chart visualization.