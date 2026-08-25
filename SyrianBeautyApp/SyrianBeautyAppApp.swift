//
//  SyrianBeautyAppApp.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI
import FirebaseCore

@main
struct SyrianBeautyAppApp: App {
    @StateObject private var authService = AuthService()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LoginView() // ✅ استخدم LoginView مباشرة
                .environmentObject(authService)
        }
    }
}

