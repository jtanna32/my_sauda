# My Sauda

A Flutter mobile application for agricultural trading platform with clean architecture and modern UI design.

**Tech Stack:** Flutter | Riverpod | MVVM Architecture | GoRouter

---

## Overview

My Sauda is a non-technical friendly mobile application designed for farmers and agricultural brokers. It features complete authentication and party management modules with:

* Agriculture-inspired theme (Green & Brown)
* MVVM architecture for scalability
* Riverpod for state management
* GoRouter for navigation
* Form validation and error handling
* Responsive design for all devices
* Supabase backend integration with RPC functions

---

## Quick Start

### Installation

```bash
# Navigate to project
cd /Users/jitarth/Documents/my_sauda

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## Recent Updates (May 2026)

### Parties Module Enhancements

The Parties module has been improved with better UX, data consistency, and reusable components:

#### Smart Suggestion System

* Introduced reusable Suggestion Picker Dialog
* Used for city selection
* Allows:

   * Selecting previously used values
   * Adding new values dynamically
* Data stored per user for reuse

#### Improved Input Experience

* Replaced dropdowns with uniform text-field based selection UI
* State and City fields:

   * Visually consistent with other inputs
   * Open searchable dialog on tap

#### Enhanced UI

* Updated parties list with card-based layout
* Improved spacing and hierarchy
* Better empty state messaging:

   * "No parties yet. Tap + to add your first party"

#### Search Improvements

* Real-time search across:

   * Party name
   * City
   * State
   * Party code

#### Feedback and Interaction

* Snackbar feedback added for:

   * Create
   * Update
   * Delete
* Loading states handled during API operations

#### Safe Async Handling

* Fixed lifecycle issue related to deactivated widget
* Implemented safe ScaffoldMessenger usage

#### Data Handling Improvements

* Proper state updates after create/update/delete
* Parties sorted by latest created
* MVVM structure maintained cleanly

---

## Project Structure

```
lib/
├── main.dart
├── config/
│   └── router.dart
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   ├── service/
│   │   └── suggestion_service.dart
│   ├── view_model/
│   │   └── suggestion_view_model.dart
│   └── widgets/
│       └── suggestion_picker_dialog.dart
└── features/
    ├── auth/
    ├── parties/
```

---

## Parties Feature Architecture

### MVVM Pattern

**Model**

* Party entity
* JSON serialization

**Service**

* Supabase integration
* RPC-based CRUD operations

**ViewModel**

* State management with Riverpod
* Business logic and validation
* Search handling

**View**

* Parties list screen
* Add/Edit screen

---

## Features

* Authentication (Login/Register/Forgot Password)
* Parties CRUD operations
* Smart suggestions system
* Search and filtering
* Snackbar feedback
* Clean and consistent UI
* Error handling and loading states

---

## Next Steps

1. Firms Module
2. Sauda Module
3. Assignment Logic
4. Billing and PDF
5. Reports

---

**Last Updated:** May 4, 2026
