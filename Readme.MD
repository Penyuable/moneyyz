 <div align="center">

# Moneyyz

**Personal Finance & Cash Flow Management**

Manage your money. Track every transaction. Take control of your finances.

Aplikasi pencatatan keuangan pribadi berbasis Flutter untuk Android dan iOS, dengan fitur pemasukan, pengeluaran, pemantauan cash flow, dan pemindaian struk belanja.

<br/>

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Status](https://img.shields.io/badge/Status-In%20Development-orange?style=for-the-badge)

</div>

---

## Overview

**Moneyyz** is a cross-platform personal finance application designed to help users record transactions, monitor cash flow, and manage their daily finances in one place.

Built with Flutter, Moneyyz aims to deliver a consistent and intuitive experience across Android and iOS devices.

The application focuses on simplifying financial tracking through structured transaction records, categorized income and expenses, and receipt scanning capabilities.

## Key Features

### Income Management
- Record income transactions.
- Organize income by category.
- Set transaction amounts and dates.
- Add notes and transaction descriptions.

### Expense Management
- Record daily expenses.
- Categorize spending for easier financial analysis.
- Store transaction amounts, dates, and descriptions.
- Attach receipt images as transaction evidence.

### Cash Flow Dashboard
- View total income and expenses.
- Monitor financial balances based on recorded transactions.
- Review cash flow over selected periods.
- Access a centralized overview of personal finances.

### Receipt Scanner
- Capture receipts using the device camera.
- Attach receipt images to expense records.
- Support future OCR integration to extract transaction information automatically.
- Reduce manual data entry when recording purchases.

### Transaction History
- Browse recorded income and expenses.
- Filter transactions by category and date.
- Review individual transaction details.
- Track previous financial activities.

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile framework |
| Dart | Primary programming language |
| PostgreSQL / Supabase | Database and backend services, if implemented |
| Camera / Image Picker | Receipt image capture |
| OCR | Receipt text extraction, if implemented |
| Git & GitHub | Version control and collaboration |

## Supported Platforms

- **Android** — mobile devices running supported Android versions.
- **iOS** — iPhone and other supported Apple development targets.

A shared Flutter codebase helps maintain consistent application behavior across platforms.

## Project Structure

```text
moneyyz/
├── android/
├── ios/
├── assets/
├── lib/
│   ├── main.dart
│   ├── app/
│   ├── core/
│   │   ├── constants/
│   │   ├── services/
│   │   ├── theme/
│   │   └── utils/
│   ├── models/
│   ├── repositories/
│   ├── features/
│   │   ├── dashboard/
│   │   ├── income/
│   │   ├── expense/
│   │   ├── cash_flow/
│   │   ├── receipt_scanner/
│   │   └── transaction_history/
│   └── shared/
│       └── widgets/
├── test/
├── pubspec.yaml
└── README.md
```

*This is a recommended structure. Actual directories may differ depending on the implementation.*

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Visual Studio Code or Android Studio
- Android SDK
- Xcode for iOS development (macOS required)
- Git

### Installation

**1. Clone the repository**

```bash
git clone <YOUR_REPOSITORY_URL>
```

**2. Navigate to the project directory**

```bash
cd moneyyz
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Check the development environment**

```bash
flutter doctor
```

**5. Run the application**

```bash
flutter run
```

## Build

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

Requires macOS and Xcode.

```bash
flutter build ios --release
```

## Development Roadmap

- [x] Establish Flutter as the primary framework.
- [ ] Build the main dashboard.
- [ ] Implement income tracking.
- [ ] Implement expense tracking.
- [ ] Add transaction categories.
- [ ] Develop cash flow summaries.
- [ ] Implement transaction history and filtering.
- [ ] Add receipt image capture.
- [ ] Integrate OCR-based receipt recognition.
- [ ] Implement persistent database storage.
- [ ] Add authentication, if required.
- [ ] Test across Android and iOS.
- [ ] Prepare production builds.

## Development Principles

Moneyyz is designed around the following principles:

- **Simplicity** — make daily financial tracking easy.
- **Clarity** — present income, expenses, and balances clearly.
- **Efficiency** — reduce manual input through receipt scanning.
- **Consistency** — maintain a unified experience across mobile platforms.
- **Maintainability** — use modular architecture for future development.

## Contributing

Contributions and improvements are welcome.

1. Fork the repository.
2. Create a feature branch.
3. Implement and test your changes.
4. Submit a Pull Request.

Example:

```bash
git checkout -b feature/cash-flow-dashboard
git checkout -b feature/receipt-scanner
git checkout -b feature/transaction-history
```

## License

The project license has not yet been specified. Add a `LICENSE` file when a license has been selected.

---

<div align="center">

**Moneyyz**

*Track your money. Own your financial journey.*

Built with Flutter.

</div>
