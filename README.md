# 💙 Settl - Expense Tracker & Settlement App

A modern, intuitive mobile application for tracking shared expenses and managing group settlements. Perfect for roommates, travel groups, and friends who split bills.

## ✨ Features

- **Group Management** - Create and manage expense groups easily
- **Expense Tracking** - Add expenses with detailed information (category, payer, split members)
- **Smart Settlement** - Automatically calculate optimal payment flows to settle debts
- **Analytics & Insights** - View spending trends, fairness scores, and member contributions
- **Category Breakdown** - Track expenses by categories (Food, Transport, Accommodation, etc.)
- **PDF Reports** - Export detailed group reports
- **Real-time Updates** - Instant UI updates when data changes
- **Modern UI** - Clean, intuitive blue-themed interface with smooth animations

---

## 📱 Screenshots

### Home Screen - Group Overview
```
┌─────────────────────────────────────────┐
│                                         │
│    [Screenshot 1: Home Page]            │
│                                         │
│  Shows:                                 │
│  ├─ Group list with expense summaries   │
│  ├─ Total spending per group            │
│  ├─ Member count and expense count      │
│  └─ Floating action button for new group│
│                                         │
└─────────────────────────────────────────┘
```

### Group Detail - Expenses & Members
```
┌─────────────────────────────────────────┐
│                                         │
│  [Screenshot 2: Group Detail]           │
│                                         │
│  Shows:                                 │
│  ├─ Insights card with total & fairness │
│  ├─ Settlement summary card             │
│  ├─ Members list with balances          │
│  ├─ Add member functionality            │
│  ├─ Complete expense history            │
│  └─ Member balance breakdown            │
│                                         │
└─────────────────────────────────────────┘
```

### Add/Edit Expense Form
```
┌─────────────────────────────────────────┐
│                                         │
│  [Screenshot 3: Add Expense]            │
│                                         │
│  Shows:                                 │
│  ├─ Expense title input field           │
│  ├─ Amount entry with currency          │
│  ├─ Member selection for split          │
│  ├─ Split mode toggle (Equal/Custom)    │
│  ├─ Who paid section with amounts       │
│  ├─ Category dropdown                   │
│  ├─ Optional notes field                │
│  └─ Save/Update button                  │
│                                         │
└─────────────────────────────────────────┘
```

### Insights & Analytics Dashboard
```
┌─────────────────────────────────────────┐
│                                         │
│  [Screenshot 4: Insights Overview]      │
│                                         │
│  Overview Tab Shows:                    │
│  ├─ Total spending stat                 │
│  ├─ Fairness score percentage           │
│  ├─ Interactive debt graph               │
│  │  └─ Member selection by name         │
│  ├─ Settlement efficiency metric        │
│  └─ Graph visualization                 │
│                                         │
│  Analytics Tab Shows:                   │
│  ├─ Contribution pie chart              │
│  ├─ Spending trend line chart           │
│  ├─ Fairness score interpretation       │
│  ├─ Member behavior insights            │
│  └─ Expense category breakdown          │
│                                         │
└─────────────────────────────────────────┘
```

### Settlement Management
```
┌─────────────────────────────────────────┐
│                                         │
│  [Screenshot 5: Settlement View]        │
│                                         │
│  Shows:                                 │
│  ├─ Member balance summary              │
│  ├─ Outstanding debts with amounts      │
│  ├─ Suggested optimal payments          │
│  │  └─ Quick record payment button      │
│  ├─ Recorded payments history           │
│  │  └─ Edit and delete options          │
│  └─ Balance verification summary        │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** 3.12.0 or higher
- **Dart SDK** 3.12.0 or higher
- **Android SDK** (for Android development)
- **Xcode** (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/settl.git
   cd settl
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run -d <device_id>
   
   # For iOS
   flutter run -d <device_id>
   
   # Or let Flutter auto-select
   flutter run
   ```

---

## 📖 Usage Guide

### Creating a Group
1. Tap the **"New Group"** button on the home screen
2. Enter the **group name** and optional **description**
3. Add **members** by typing their names and tapping the add button
4. Tap **"Create Group"** to finalize

### Adding an Expense
1. Open a group
2. Tap the **"Add expense"** floating action button
3. Fill in the expense details:
   - **What was it for?** - Expense title
   - **Total price** - Amount spent
   - **Who shared this?** - Select participants
   - **Split mode** - Choose equal or custom amounts
   - **Who paid?** - Specify each person's payment
   - **Category** - Select from predefined categories
   - **Note** (optional) - Additional details
4. Tap **"Add expense"** to save

### Settling Debts
1. Open a group and tap **"Settlement"**
2. Review **Outstanding debts** section
3. View **Suggested payments** for optimal settlement
4. Record payments as they're made:
   - Tap **"Pay"** on any debt
   - Enter the amount
   - Add optional note
5. Track **Recorded payments** history

### Viewing Insights
1. Open a group and tap **"Insights"**
2. **Overview Tab:**
   - View total spending and fairness score
   - Interactive debt graph
   - Tap member names to filter the graph
3. **Analytics Tab:**
   - Pie chart of contributions
   - Line chart of spending trends
   - Member behavior insights
   - Category-wise expense breakdown

---

## 🏗️ Project Architecture

```
lib/
├── core/
│   ├── di/                    # Dependency Injection (GetIt)
│   │   └── injection.dart
│   ├── router/                # Navigation (GoRouter)
│   │   └── app_router.dart
│   ├── theme/                 # Theme & Colors
│   │   └── app_theme.dart
│   └── utils/                 # Utility functions
│       └── currency_formatter.dart
│
├── data/
│   ├── datasources/           # Local storage with Hive
│   │   └── local_ledger_datasource.dart
│   ├── mappers/               # Entity mapping
│   │   └── entity_mappers.dart
│   ├── repositories/          # Repository implementations
│   │   └── ledger_repository_impl.dart
│   └── services/              # External services
│       └── pdf_report_service.dart
│
├── domain/
│   ├── entities/              # Data models
│   │   ├── group.dart
│   │   ├── expense.dart
│   │   ├── member.dart
│   │   └── settlement_payment.dart
│   ├── repositories/          # Repository interfaces
│   │   └── ledger_repository.dart
│   ├── services/              # Domain business logic
│   │   ├── debt_graph_engine.dart
│   │   ├── settlement_optimizer.dart
│   │   ├── fairness_calculator.dart
│   │   ├── group_analytics_service.dart
│   │   └── trend_analyzer.dart
│   └── usecases/              # Use cases (business logic)
│       ├── get_groups.dart
│       ├── add_expense.dart
│       ├── get_settlement.dart
│       └── ...
│
├── presentation/
│   ├── blocs/                 # State Management (BLoC)
│   │   ├── groups_list/
│   │   ├── group_detail/
│   │   ├── expense_form/
│   │   ├── analytics/
│   │   ├── graph/
│   │   └── settlement/
│   ├── pages/                 # Full-page screens
│   │   ├── home_page.dart
│   │   ├── create_group_page.dart
│   │   ├── group_detail_page.dart
│   │   ├── expense_form_page.dart
│   │   ├── group_insights_page.dart
│   │   └── settlement_page.dart
│   ├── widgets/               # Reusable UI components
│   │   ├── member_balances_section.dart
│   │   ├── debt_graph_painter.dart
│   │   ├── stat_card.dart
│   │   └── app_navigation.dart
│   └── utils/                 # Presentation utilities
│       └── expense_display.dart
│
└── main.dart                  # Entry point
```

---

## 🛠️ Technologies & Dependencies

### State Management
- **flutter_bloc** ^8.1.6 - BLoC pattern
- **equatable** ^2.0.5 - Value equality

### Navigation
- **go_router** ^14.6.2 - Modern routing

### Local Storage
- **hive** ^2.2.3 - NoSQL database
- **hive_flutter** ^1.1.0 - Flutter integration

### UI & Visualization
- **fl_chart** ^0.69.0 - Charts and graphs
- **cupertino_icons** ^1.0.8 - iOS icons

### Utilities
- **get_it** ^8.0.2 - Service locator
- **uuid** ^4.5.1 - UUID generation
- **intl** ^0.19.0 - Internationalization
- **collection** ^1.18.0 - Collections utilities

### PDF & Printing
- **pdf** ^3.11.1 - PDF generation
- **printing** ^5.13.4 - Printing functionality
- **path_provider** ^2.1.4 - File system access

---

## 🎨 Design System

### Color Palette
| Color | Hex | Usage |
|-------|-----|-------|
| Primary Blue | `#0066FF` | Buttons, highlights, primary actions |
| Secondary Purple | `#6366F1` | Accents, gradients, secondary elements |
| Background | `#FAFBFC` | App background |
| Surface | `#FFFFFF` | Cards, containers |
| Text Primary | `#1A1D23` | Main text content |
| Text Secondary | `#6B7280` | Secondary text, labels |
| Danger Red | `#E74C3C` | Error states, deletions |
| Success Green | Similar to primary | Success states |

### Typography
- **Display (22px)** - Font weight 700 - Main app title
- **Heading (18px)** - Font weight 700 - Page titles
- **Subheading (16px)** - Font weight 700 - Section titles
- **Body (14-15px)** - Font weight 400-600 - Main content
- **Caption (12-13px)** - Font weight 500 - Labels
- **Small (11px)** - Font weight 400 - Secondary info

### Spacing Scale
- `xs`: 4px
- `sm`: 8px
- `md`: 12px
- `lg`: 16px
- `xl`: 20px
- `2xl`: 24px
- `3xl`: 32px

---

## 🔄 State Management Architecture

### BLoC Pattern Implementation

**GroupsListBloc**
- Manages the list of all groups
- Handles group creation and deletion
- Manages loading and error states

**GroupDetailBloc**
- Loads group-specific data
- Manages member addition/removal
- Tracks balance changes

**ExpenseFormCubit**
- Manages form state during expense creation/editing
- Handles amount calculations and validations

**GraphBloc**
- Computes debt relationships
- Manages graph visualization state

**AnalyticsBloc**
- Calculates analytics metrics
- Handles PDF export

**SettlementBloc**
- Optimizes settlement calculations
- Manages recorded payments

---

## 💾 Data Persistence

### Hive Database Structure

```
groups/
├── {groupId}: Group JSON
│
expenses/
├── {groupId}:{expenseId}: Expense JSON
│
settlement_payments/
└── {groupId}:{paymentId}: SettlementPayment JSON
```

### Data Models

**Group**
- ID, name, description
- Members list
- Creation timestamp

**Expense**
- ID, title, amount, category
- Payer information
- Split details
- Timestamp

**SettlementPayment**
- ID, from/to member IDs
- Amount, note
- Timestamp

---

## 🧮 Core Algorithms

### Debt Settlement Optimization
1. Compute net balances for each member
2. Eliminate positive/negative cycles
3. Generate minimum payment transactions
4. Calculate settlement efficiency

### Fairness Scoring
- Compares expected vs actual spending per member
- Weighs participation and contribution
- Returns score 0-100%

### Expense Splitting
- **Equal Split**: Divides equally among participants
- **Custom Split**: User-defined amounts per person

---

## 🚦 Getting Help

### Documentation
- Comprehensive code comments throughout
- Type-safe Dart/Flutter code
- Clear naming conventions

### Common Issues

**Issue: Data not showing after app restart**
- Solution: Clear app cache via Settings > Apps > Settl > Storage > Clear Data

**Issue: New group not appearing on home screen**
- Solution: The app automatically refreshes after group creation

---

## 📋 Code Standards

- **Naming**: camelCase for variables, PascalCase for classes
- **Formatting**: Dart conventions via `dart format`
- **Analysis**: Strict lint rules via `analysis_options.yaml`
- **Testing**: Unit and widget tests in `/test` directory

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes with clear messages
4. **Push** to the branch
5. **Open** a Pull Request with detailed description

### Code Review Process
- All PRs require code review
- Tests must pass
- Code should follow project style guide

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🎯 Roadmap

### Version 1.1
- [ ] Multi-currency support
- [ ] Recurring expenses
- [ ] Expense templates

### Version 1.2
- [ ] Cloud synchronization
- [ ] Real-time collaboration
- [ ] User accounts

### Version 2.0
- [ ] Dark mode
- [ ] Advanced reporting
- [ ] Mobile payment integration
- [ ] Voice expense input

---

## 📞 Support & Feedback

- **Report Issues**: Open an issue on GitHub
- **Feature Requests**: Create a discussion on GitHub
- **Email Support**: support@settl.app

---

## 🙌 Acknowledgments

- Built with [Flutter](https://flutter.dev)
- State management by [flutter_bloc](https://bloclibrary.dev)
- Charts powered by [FL Chart](https://fl-chart.github.io)

---

<div align="center">

**Made with 💙 by the Settl Team**

*Making shared expenses simple and fair*

⭐ If you find this helpful, please star the repository!

</div>
