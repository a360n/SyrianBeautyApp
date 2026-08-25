<div align="center">

# SyrianBeautyApp — Enterprise Salon Management & Financial Point-of-Sale System

[![Swift](https://img.shields.io/badge/Swift-5.9+-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/swift/)
[![iOS](https://img.shields.io/badge/iOS-17.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-MVVM-007ACC?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![Firebase](https://img.shields.io/badge/Backend-Cloud_Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/docs/firestore)
[![Firebase Auth](https://img.shields.io/badge/Security-Firebase_Auth-DD2C00?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com/docs/auth)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

<p align="center">
  A native iOS salon management and financial reconciliation application built with <b>SwiftUI</b>, <b>Role-Based Access Control (RBAC)</b>, and <b>Cloud Firestore</b> real-time synchronization.
</p>

</div>

---

## Table of Contents
- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Key Features](#key-features)
- [Role-Based Workflows](#role-based-workflows)
- [Design System & Theme Tokens](#design-system--theme-tokens)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Author & License](#author--license)

---

## Overview

**SyrianBeautyApp** (Qasr Al-Jamal Al-Souri) is an enterprise iOS management and transaction ledger platform designed for commercial salons and barbershops. The application replaces fragmented manual bookkeeping with a synchronized, real-time cloud point-of-sale system, separating managerial governance from daily barber operation workflows.

### Core Objectives
- **Financial Reconciliation:** Instant balance computation between customer revenue collected and manager commission payouts.
- **Dual-Role Navigation:** Seamless dynamic routing providing customized user journeys for Salon Managers and Staff Barbers.
- **Real-Time Cloud Ledger:** Zero-latency persistence with Cloud Firestore, ensuring instant synchronization across all managerial and staff devices.

---

## System Architecture

```mermaid
flowchart TD
    subgraph Client["Native iOS Client (SwiftUI / MVVM)"]
        AuthApp["Application Entry & Lifecycle
(SyrianBeautyAppApp.swift)"]
        AuthSvc["AuthService
(Session & RBAC Token)"]
        Router["RoleRouterView
(Dynamic View Resolver)"]
        
        subgraph ManagerFlow["Manager Interface"]
            ManagerDash["DashboardView
(Total Revenue & Metrics)"]
            BarberMgmt["ManagerBarberListViewModel
(Staff Management)"]
            PayoutSheet["AddPaymentToManagerSheet
(Commission Reconciliation)"]
        end

        subgraph BarberFlow["Barber Interface"]
            BarberHome["BarberHomeViewModel
(Shift Metrics)"]
            AddTx["AddTransactionView
(Rapid POS Logging)"]
            TxList["TransactionsListView
(Audit History)"]
        end

        FirebaseSvc["FirebaseService (Generic Firestore Client)"]
    end

    subgraph CloudBackend["Firebase Cloud Infrastructure"]
        FirebaseAuth["Firebase Authentication
(JWT & Identity)"]
        FirestoreDB["Cloud Firestore Database
(Collections: users, barbers, transactions)"]
        FirebaseStorage["Firebase Storage
(Avatar & Media Assets)"]
    end

    AuthApp --> AuthSvc
    AuthSvc --> FirebaseAuth
    AuthSvc --> Router
    Router -->|Role: Manager| ManagerDash
    Router -->|Role: Barber| BarberHome
    ManagerDash --> BarberMgmt
    ManagerDash --> PayoutSheet
    BarberHome --> AddTx
    BarberHome --> TxList
    BarberMgmt & PayoutSheet & AddTx & TxList --> FirebaseSvc
    FirebaseSvc <==>|Real-Time Streams (gRPC / TLS)| FirestoreDB
    FirebaseSvc --> FirebaseStorage
```

---

## Key Features

### 1. Dynamic Role-Based Access Control (RBAC)
- Client-side routing engine (`RoleRouterView`) dynamically resolves views based on the authenticated user's role:
  - **Manager Role:** Full access to revenue charts, staff balance sheets, commission overrides, and staff creation.
  - **Barber Role:** Streamlined interface focused strictly on logging service tickets and viewing personal commission metrics.

### 2. Double-Entry Financial Tracking
- Granular transaction records (`Transaction`) classified into:
  - `received`: Direct customer payments for grooming/haircare services.
  - `paidToManager`: End-of-shift commission handovers to management.
- Real-time balance calculations:
  $$	ext{Net Balance} = \sum 	ext{Received} - \sum 	ext{Paid to Manager}$$

### 3. Asynchronous Generic Firestore Engine
- Centralized `FirebaseService` leveraging Swift generics and Codable protocols for type-safe database querying and mutations.
- Uses `@DocumentID` and `@ServerTimestamp` property wrappers to prevent clock drift issues during offline and multi-timezone operation.

### 4. Custom Component Architecture
- Reusable UI component library including `StatCard`, `TransactionCard`, `InfoCard`, `AvatarImage`, and `ConfirmDialog` for consistent UX across both roles.

---

## Role-Based Workflows

### Manager Experience
```
Manager Login -> DashboardView -> Overall Revenue Metrics
                               -> Staff Performance Cards
                               -> Add New Barber
                               -> Settle Barber Balances
```

### Barber Experience
```
Barber Login  -> HomeView      -> Today's Revenue & Completed Services
                               -> Quick "Add Transaction" Modal
                               -> Shift Summary & Historical Transactions
```

---

## Design System & Theme Tokens

The application employs a luxury dark palette tailored for high-end aesthetic salons:

| Token Name | Color Description | Hex Code | Visual Application |
| :--- | :--- | :--- | :--- |
| `sbBlack` | Rich Midnight Black | `#121212` | Root Background & Primary Canvas |
| `sbSoftBlack` | Charcoal Slate | `#2C2C2C` | Surface Cards & Modal Containers |
| `sbGold` | Royal Antique Gold | `#CDA434` | Primary CTAs, Badges & Highlights |
| `sbLightGold` | Bright Accent Gold | `#FFD700` | Financial Metrics & Active States |
| `sbBrown` | Deep Earth Brown | `#5D4037` | Secondary Dividers & Accents |
| `sbWhite` | Pure White | `#FFFFFF` | Primary Typography |

---

## Tech Stack

| Category | Technology | Purpose |
| :--- | :--- | :--- |
| **Language** | Swift 5.9+ | Primary Language |
| **UI Framework** | SwiftUI (iOS 17+) | Declarative Reactive Interface |
| **Design Pattern** | MVVM | State Separation & Presentation Logic |
| **Authentication** | Firebase Auth | User Identity & Token Management |
| **Database** | Cloud Firestore | Real-Time NoSQL Document Store |
| **Cloud Storage**| Firebase Storage | Image Assets & Staff Profile Media |
| **Testing** | XCTest, XCUITest | Unit & UI Automation Coverage |

---

## Project Structure

```
SyrianBeautyApp/
├── SyrianBeautyApp/                  # Main Target
│   ├── SyrianBeautyAppApp.swift      # App Lifecycle & Firebase Initialization
│   ├── ContentView.swift             # Root Container
│   ├── Models/                       # Domain Entities
│   │   ├── User.swift                # User Entity
│   │   ├── Barber.swift              # Barber Profile & Balances
│   │   ├── Transaction.swift         # Ledger Record (Received / Paid)
│   │   └── Session.swift             # Active Session State
│   ├── ViewModels/                   # Presentation ViewModels
│   │   ├── Auth.swift                # Authentication State
│   │   ├── Settings.swift            # Preferences & Profile
│   │   ├── Home/BarberHomeViewModel.swift
│   │   ├── BarberList/ManagerBarberListViewModel.swift
│   │   └── BarberDetail/BarberDetailViewModel.swift
│   ├── Views/                        # SwiftUI View Layer
│   │   ├── RoleRouterView.swift      # Dynamic RBAC Root Router
│   │   ├── LoginView.swift           # Authentication View
│   │   ├── Manager/                  # Manager Module
│   │   │   ├── DashboardView.swift
│   │   │   ├── AddBarberView.swift
│   │   │   ├── BarberDetailView.swift
│   │   │   └── AddPaymentToManagerSheet.swift
│   │   ├── Barber/                   # Barber Module
│   │   │   ├── HomeView.swift
│   │   │   ├── AddTransactionView.swift
│   │   │   └── TransactionsListView.swift
│   │   └── Components/               # Atomic Shared Components
│   │       ├── StatCard.swift
│   │       ├── TransactionCard.swift
│   │       ├── AvatarImage.swift
│   │       └── ConfirmDialog.swift
│   ├── Services/                     # Cloud & Infrastructure
│   │   ├── AuthService.swift         # Firebase Authentication Provider
│   │   ├── FirebaseService.swift     # Firestore Generic CRUD Engine
│   │   └── ImageService.swift        # Image Upload & Compression
│   └── Resources/                    # Tokens & Helpers
│       ├── Color+Theme.swift         # Palette Constants
│       └── Localization.swift        # Localized Strings
├── SyrianBeautyAppTests/             # Unit Test Suite
└── SyrianBeautyAppUITests/           # UI Automation Test Suite
```

---

## Getting Started

### Prerequisites
- macOS Sonoma 14.0+ / macOS Sequoia 15.0+
- Xcode 15.0+ or Xcode 16.0+
- Active Firebase Project with Firestore and Authentication enabled

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/a360n/SyrianBeautyApp.git
   cd SyrianBeautyApp
   ```

2. **Configure Firebase:**
   - Place your `GoogleService-Info.plist` inside the `SyrianBeautyApp/` directory.
   - Ensure Cloud Firestore rules permit authenticated read/write access for the `users`, `barbers`, and `transactions` collections.

3. **Open and Run in Xcode:**
   ```bash
   open SyrianBeautyApp.xcodeproj
   ```
   Select an iOS 17.0+ Simulator or connected physical device and press `Cmd + R`.

---

## Author

**Ali Nasser (Ali Al-Khazali)**
- Portfolio: [www.ali-nasser.dev](https://www.ali-nasser.dev)
- GitHub: [@a360n](https://github.com/a360n)
- LinkedIn: [Ali Nasser](https://www.linkedin.com/in/ali-nasser-dev/)

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
