//
//  LoginView.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        if let role = authService.role {
            destinationView(for: role)
        } else {
            ZStack {
                Color(UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark
                        ? UIColor(red: 46/255, green: 43/255, blue: 40/255, alpha: 1)
                        : UIColor(red: 244/255, green: 236/255, blue: 223/255, alpha: 1)
                })
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("Login")
                        .font(.largeTitle)
                        .foregroundColor(.sbGold)
                        .bold()

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(10)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(10)

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }

                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .sbGold))
                        } else {
                            Text("Log In")
                                .foregroundColor(.sbWhite)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.sbGold)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func login() {
        errorMessage = nil
        isLoading = true
        authService.signIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                if case .failure(let error) = result {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    @ViewBuilder
    private func destinationView(for role: String) -> some View {
        if role == "manager" {
            DashboardView()
        } else {
            HomeView()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}
