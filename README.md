# Baki Khata

A simple digital **baki khata** for small businesses in Bangladesh. Keep a
clear record of customer sales, payments, and outstanding dues without the
complexity of a feature-heavy business management system.

The app uses Bengali labels and Bangladeshi taka (৳), and is built with Flutter.

## What it does

- **Keep customer accounts:** Save a customer's name, phone number, and optional
  address. Find customers by name or phone number, see who has a balance due,
  and sort the list by due amount or name.
- **Write down a sale:** Add sale items with quantity, unit, and unit price;
  record a discount, amount paid, and an optional note. The remaining balance
  is shown as due.
- **Record a payment:** Add a later payment to a customer's account and review
  their sales and payment history.
- **Contact customers:** Open the phone dialer or WhatsApp from a customer
  account.
- **Save common products:** Keep a searchable list of product names and prices
  to use when entering sales. This is a price list, not stock management.
- **Track shop expenses:** Record expenses by category and review daily or
  monthly totals and category summaries.
- **Separate shops:** Keep customers, transactions, products, and expenses
  organized by shop and switch between shops.

## What it is not

Baki Khata is focused on writing down transactions and due balances. It does not
currently provide cloud sync or backup, stock quantity tracking, automated
customer reminders, or advanced accounting and analytics. App data is stored
locally on the device; uninstalling the app or losing the device may result in
data loss.

## Getting started

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install), then
from the project directory run:

```sh
flutter pub get
flutter run
```

To run the automated tests:

```sh
flutter test
```

## Project structure

```text
lib/
  core/          Shared formatting and theme helpers
  data/          Local database access and repository implementations
  domain/        Business entities and repository interfaces
  presentation/  Screens, widgets, and Riverpod state providers
test/            Flutter tests
```

The app uses a local Sembast database in the platform's application documents
directory, with Riverpod for app state.
