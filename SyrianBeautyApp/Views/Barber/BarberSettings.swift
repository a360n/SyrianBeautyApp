//
//  BarberSettings.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI
import FirebaseAuth

struct BarberSettings: View {
    @EnvironmentObject var authService: AuthService
    @State private var showLogoutConfirmation = false
    @State private var showPasswordSheet = false

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isPasswordUpdating = false


    @State private var barberData: Barber?
    @State private var transactions: [Transaction] = []
    @State private var isLoading = true

    var totalReceived: Int {
        transactions.filter { $0.type == "received" }.map(\.amount).reduce(0, +)
    }
    var totalPaidToManager: Int {
        transactions.filter { $0.type == "paidToManager" }.map(\.amount).reduce(0, +)
    }

    var balance: Int {
        (totalReceived / 2)  - totalPaidToManager
    }


    var body: some View {
        ZStack {
            Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 46/255, green: 43/255, blue: 40/255, alpha: 1)  // Dark version
                    : UIColor(red: 244/255, green: 236/255, blue: 223/255, alpha: 1) // Light version
            })
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    if let barber = barberData {
                        VStack(spacing: 10) {
                            AvatarImage(url: barber.avatarUrl)
                                .frame(width: 100, height: 100)

                            Text(barber.name)
                                .foregroundColor(.sbGold)
                                .font(.title3)
                                .bold()
                        }

                        Divider().background(Color.sbLightGray)

                        InfoCard(title: "Total Received", value: totalReceived, valueColor: .white, prefixSymbol: nil, hideSign: true)

                        InfoCard(title: "Submitted to the manager", value: totalPaidToManager, valueColor: .white, prefixSymbol: nil, hideSign: true)

                        let profit = totalReceived - totalPaidToManager
                        let profitColor: Color = profit >= 0 ? .green : .red
                        let profitSymbol = profit >= 0 ? "+" : "-"
                        InfoCard(title: "Profit", value: abs(profit), valueColor: profitColor, prefixSymbol: profitSymbol)

                        let balance = totalPaidToManager - (totalReceived / 2)
                        if balance < 0 {
                            InfoCard(title: "What must be paid to the manager", value: balance, valueColor: .red, prefixSymbol: "-")
                        } else if balance > 0 {
                            InfoCard(title: "What the manager should pay the barber", value: abs(balance), valueColor: .green, prefixSymbol: "+")
                        }






                        Divider().background(Color.sbLightGray)
                    }

                    Button("Change Password") {
    showPasswordSheet = true
}
.padding()
.frame(maxWidth: .infinity)
.background(Color.sbGold)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Sign Out") {
                        showLogoutConfirmation = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .alert("Confirm Sign Out", isPresented: $showLogoutConfirmation) {
                        Button("Yes, Sign Out", role: .destructive) {
                            logout()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Are you sure you want to sign out?")
                    }

                    Spacer()
                }
                .padding()
                .onAppear {
                    loadBarberData()
                    loadTransactions()
                }
            }
        }
        .sheet(isPresented: $showPasswordSheet) {
            VStack(spacing: 20) {
                Text("change password")
                    .font(.headline)
                    .foregroundColor(.sbGold)

                SecureField("New Password", text: $newPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)

                SecureField("Confirm password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)

                if let error = errorMessage {
                    Text(error).foregroundColor(.red).font(.footnote)
                }

                if let success = successMessage {
                    Text(success).foregroundColor(.green).font(.footnote)
                }

                Button(action: updatePassword) {
                    HStack {
                        if isPasswordUpdating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Update password")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.sbGold)
                    .foregroundColor(.sbWhite)
                    .cornerRadius(10)
                }
                .disabled(isPasswordUpdating)

                Button("cancel") {
                    showPasswordSheet = false
                }
                .padding()
                .foregroundColor(.gray)
            }
            .padding()
            .presentationDetents([.medium])
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            authService.logout()
        } catch {
            self.errorMessage = "An error occurred while logging out: \(error.localizedDescription)"
        }
    }

    private func loadBarberData() {
        guard let barberId = authService.barberId else {
            return
        }

        FirebaseService.shared.fetchDocument(
            collection: "barbers",
            documentId: barberId,
            as: Barber.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let barber):
                    self.barberData = barber
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        }
    }

    private func loadTransactions() {
        guard let barberId = authService.barberId else { return }

        FirebaseService.shared.fetchCollection(
            collection: "transactions",
            as: Transaction.self,
            filters: [("barberId", "==", barberId)]
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let txns):
                    self.transactions = txns
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func updatePassword() {
        guard !newPassword.isEmpty, newPassword == confirmPassword else {
            errorMessage = "Please make sure the passwords match"
            return
        }

        isPasswordUpdating = true
        errorMessage = nil
        successMessage = nil

        if let user = Auth.auth().currentUser {
            user.updatePassword(to: newPassword) { error in
                DispatchQueue.main.async {
                    isPasswordUpdating = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.successMessage = "Password updated successfully!"
                        self.newPassword = ""
                        self.confirmPassword = ""

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.showPasswordSheet = false
                        }
                    }
                }
            }
        } else {
            isPasswordUpdating = false
            self.errorMessage = "The password for a local account cannot be changed."
        }
    }
}

#Preview {
    BarberSettings()
        .environmentObject(AuthService())
}
