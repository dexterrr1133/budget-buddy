# BudgetBuddy Home Screen - Implementation Guide

## 📋 Overview

The Home Screen is a modern financial dashboard that provides users with a complete overview of their financial health, recent transactions, alerts, and AI-powered insights. It's designed with a clean, friendly, and calming aesthetic suitable for students aged 16-25.

## 🏗️ Architecture

### Directory Structure

```
features/
  home/
    controllers/
      home_controller.dart          # State management
    models/
      (future: transaction models)
    screens/
      home_screen.dart              # Main home screen
    widgets/
      home_header_widget.dart       # Header with greeting & notifications
      balance_summary_card.dart     # Main balance display
      financial_stat_card.dart      # Income/Expense stats
      alert_insight_cards.dart      # Alert & Insight cards
      transaction_item_widget.dart  # Individual transaction items
      floating_add_button.dart      # Action button
      modern_bottom_nav_bar.dart    # Navigation bar
```

## 🧩 Components

### 1. **HomeHeaderWidget**

- **Purpose**: Display greeting and notifications
- **Features**:
  - Circular avatar with user's first letter
  - Welcome back message with username
  - Notification bell with badge count
  - Fade-in animation on load
- **Props**:
  - `userName`: String - User's name for greeting
  - `notificationCount`: int - Number of unread notifications
  - `onNotificationTap`: VoidCallback - Notification tap handler

### 2. **BalanceSummaryCard**

- **Purpose**: Show total balance with income/expense breakdown
- **Features**:
  - Gradient background (teal to green)
  - Large balance display
  - Two stat cards for income and expenses
  - Slide and fade animations on load
  - Responsive formatting (M for millions, K for thousands)
- **Props**:
  - `totalBalance`: double - Total account balance
  - `totalIncome`: double - Total income
  - `totalExpenses`: double - Total expenses

### 3. **FinancialStatCard**

- **Purpose**: Display income or expense statistics
- **Features**:
  - Icon with accent color background
  - Formatted amount display
  - Slide transition animation
  - Responsive sizing
- **Props**:
  - `label`: String - "Income" or "Expenses"
  - `amount`: double - Amount value
  - `icon`: IconData - Trending up/down icon
  - `accentColor`: Color - Color for the stat

### 4. **AlertInsightCards**

- **Purpose**: Show financial alerts and AI insights
- **Features**:
  - Two side-by-side cards (Alert & Insight)
  - Staggered slide-in animations
  - Tap handlers for each card
  - Color-coded: Alert (warm/red), Insight (cool/blue)
- **Props**:
  - `alertMessage`: String - Alert text
  - `insightMessage`: String - Insight text
  - `onAlertTap`: VoidCallback - Alert tap handler
  - `onInsightTap`: VoidCallback - Insight tap handler

### 5. **TransactionItemWidget**

- **Purpose**: Display individual transactions in recent activity list
- **Features**:
  - Category icon in circle
  - Title, category, and date
  - Formatted transaction amount
  - Color-coded by transaction type (income/expense)
  - Slide animation on appear
- **Props**:
  - `title`: String - Transaction title
  - `category`: String - Transaction category
  - `date`: String - Transaction date
  - `amount`: double - Transaction amount
  - `isIncome`: bool - Income or expense flag
  - `icon`: IconData - Category icon

### 6. **FloatingAddButton**

- **Purpose**: Action button for adding new transactions
- **Features**:
  - Extended FAB with icon and label
  - Elastic scale animation on load
  - Shadow for depth
  - Positioned above bottom navigation
- **Props**:
  - `onPressed`: VoidCallback - Button tap handler

### 7. **ModernBottomNavBar**

- **Purpose**: Navigation between app screens
- **Features**:
  - Four tabs: Home, Budget, Activity, Advisor
  - Icon + label display
  - Active tab highlighting
  - Smooth color transitions
  - Icon background animation
- **Props**:
  - `selectedIndex`: int - Currently selected tab
  - `onTabChanged`: ValueChanged<int> - Tab change handler

### 8. **HomeController**

- **Purpose**: Manage home screen state
- **Features**:
  - Loading state management
  - Navigation index tracking
  - ChangeNotifier for reactive updates
- **Methods**:
  - `setSelectedNavIndex(int)` - Update selected nav tab
  - `setLoading(bool)` - Update loading state

## 🎨 Visual Style

### Colors (from core/theme/colors.dart)

- **Primary**: `#1FA971` (Teal) - Main brand color
- **Primary Light**: `#4ED6A1` - Light teal accent
- **Income**: `#22C55E` (Green) - Income transactions
- **Expense**: `#EF4444` (Red) - Expense transactions
- **Savings**: `#3B82F6` (Blue) - Savings/Insights

### Typography (from core/theme/text_styles.dart)

- **Headlines**: `headlineLarge` (28px), `headlineMedium` (22px)
- **Body Text**: `bodyLarge` (16px), `bodyMedium` (14px)
- **Labels**: `label` (12px)

### Spacing & Borders

- **Border Radius**: 24px for main cards, 16px for items
- **Horizontal Padding**: 20px
- **Vertical Spacing**: 16-24px between sections
- **Card Elevation**: Subtle shadows from `AppShadows` class

## ✨ Animations

### Load Animations

- **Header**: Fade-in (800ms)
- **Balance Card**: Slide up + Fade (1000ms)
- **Stat Cards**: Staggered slide up (800ms each)
- **Alert/Insight Cards**: Staggered slide in from sides (700ms each)
- **Transactions**: Slide in from right (600ms)
- **FAB**: Elastic scale (500ms, elasticOut curve)

### Interactive Animations

- **Nav Tab**: Color transition (300ms easeInOutCubic)
- **Navigation**: Active state highlighting (300ms)

## 🔄 State Management

The HomeScreen uses:

1. **HomeController** (ChangeNotifier) - Local state management
2. **Provider** - For transaction and chat coach data
3. **ListenableBuilder** - Reactive UI updates

### Data Flow

```
HomeScreen (StatefulWidget)
  ↓
HomeController (manages nav & loading state)
  ↓
UI Components (reflect state changes)
```

## 📊 Mock Data

The screen includes mock data for demonstration:

- **User**: "Lance"
- **Balance**: ₱45,250.50
- **Income**: ₱120,000.00
- **Expenses**: ₱28,420.75
- **Notifications**: 2
- **Recent Transactions**: 5 sample items

## 🔧 Integration Points

### Connect Real Data

Replace mock data with actual data from providers:

```dart
// Example: Use transaction provider
final transactions = context.watch<TransactionProvider>().transactions;

// Example: Get user profile
final userName = context.watch<UserProvider>().userName;
```

### Navigation Routes

- `/home` - Home screen
- `/chat` - Chat advisor screen
- `/budget` - Budget screen (to be implemented)
- `/activity` - Activity/transaction list (to be implemented)

### Future Enhancements

- [ ] Connect real transaction data from database
- [ ] Add pull-to-refresh functionality
- [ ] Implement notification screen
- [ ] Add transaction detail screen
- [ ] Implement budget tracking screen
- [ ] AI advisor integration
- [ ] Chart/graph visualizations
- [ ] Spending analytics

## 🧪 Testing

To test the home screen:

1. Build and run: `flutter run`
2. App should display welcome screen
3. Navigation to `/home` shows the dashboard
4. Test animations by scrolling and interacting
5. Verify dark mode by changing system theme

## 📱 Responsiveness

The screen handles:

- ✅ Small phones (320px width)
- ✅ Standard phones (375-430px)
- ✅ Large phones (500px+)
- ✅ Tablets (landscape mode)
- ✅ Safe area handling (notches, status bar)

## ♿ Accessibility

- Semantic labels for screen readers
- Minimum tap size: 48x48 dp
- High contrast text
- Font scaling support
- Icon descriptions

## 🐛 Debugging Tips

1. **Enable debug painting**: `debugPaintSizeEnabled = true`
2. **Widget tree inspection**: Use DevTools
3. **Performance monitoring**: Check animation smoothness
4. **Theme testing**: Switch between light/dark modes
5. **Responsive testing**: Use Device Preview package

## 📚 Related Files

- `lib/core/theme/app_theme.dart` - Theme definitions
- `lib/core/theme/colors.dart` - Color palette
- `lib/core/theme/text_styles.dart` - Typography
- `lib/core/theme/shadows.dart` - Shadow effects
- `lib/main.dart` - App configuration

---

**Last Updated**: February 9, 2026
**Status**: Complete and Ready for Integration
