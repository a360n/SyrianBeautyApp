//
//  ManagerSettingsView.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI
import FirebaseAuth

struct ManagerSettingsView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.colorScheme) var colorScheme
    @State private var showLogoutConfirmation = false
    @State private var showPasswordSheet = false
    @State private var barberStats: [(Barber, paid: Int, diff: Int)] = []
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isPasswordUpdating = false
    @State private var totalReceivedFromBarbers: Int = 0
    @State private var transactions: [Transaction] = []

    var totalPaidToManager: Int {
        transactions.filter { $0.type == "paidToManager" }.map(\.amount).reduce(0, +)
    }

    var balanceForManager: Int {
        (totalReceivedFromBarbers / 2) - totalPaidToManager
    }

    var body: some View {
        ZStack {
            Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 46/255, green: 43/255, blue: 40/255, alpha: 1)
                    : UIColor(red: 244/255, green: 236/255, blue: 223/255, alpha: 1)
            })
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    // 🧑‍💼 Show manager name
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.sbGold)

                        Text(authService.user?.email ?? "Unknown Manager")
                            .foregroundColor(.sbGold)
                            .font(.title3)
                            .bold()
                    }

                    Divider()
                        .frame(height: 3)
                        .background(Color.sbGold)
                        .padding(.horizontal)

                    // 💰 Total payments to manager
                    ForEach(barberStats, id: \.0.id) { barber, paid, diff in
                        InfoCard(title: barber.name, value: paid, valueColor: .white, prefixSymbol: nil)

                        if diff != 0 {
                            InfoCard(
                                title: diff < 0 ? "Amount owed to manager" : "Amount manager owes barber",
                                value: abs(diff),
                                valueColor: diff > 0 ? .red : .green,
                                prefixSymbol: diff > 0 ? "-" : "+"
                            )
                        }

                        Divider()
                            .frame(height: 2)
                            .background(Color.sbGold.opacity(0.7)) // clear golden line
                    }

                    Button("Change Password") {
                        showPasswordSheet = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        colorScheme == .dark
                            ? Color.sbGold.opacity(0.9)
                            : Color.sbGold
                    )
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .cornerRadius(10)

                    Button("Log Out") {
                        showLogoutConfirmation = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        colorScheme == .dark
                            ? Color.red.opacity(0.9)
                            : Color.red
                    )
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(showLogoutConfirmation ? 0.95 : 1)
                    .animation(.easeInOut(duration: 0.1), value: showLogoutConfirmation)
                    .cornerRadius(10)
                    .alert("Confirm Logout", isPresented: $showLogoutConfirmation) {
                        Button("Log Out Now", role: .destructive) {
                            logout()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Are you sure you want to log out of your account?")
                    }

                    Spacer()
                }
                .padding()
                .onAppear {
                    loadManagerStats()
                }
            }
        }
        .sheet(isPresented: $showPasswordSheet) {
            passwordSheet
        }
    }

    // MARK: - Load manager stats (payments from barbers)
    private func loadManagerStats() {
        FirebaseService.shared.queryDocuments(
            collection: "transactions",
            field: "type",
            isEqualTo: "paidToManager",
            as: Transaction.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let txns):
                    totalReceivedFromBarbers = txns.map(\.amount).reduce(0, +)
                case .failure:
                    totalReceivedFromBarbers = 0
                }
            }
        }

        FirebaseService.shared.fetchCollection(collection: "barbers", as: Barber.self) { result in
            switch result {
            case .success(let barbers):
                let group = DispatchGroup()
                var stats: [(Barber, Int, Int)] = []

                for b in barbers {
                    group.enter()
                    FirebaseService.shared.queryDocuments(
                        collection: "transactions",
                        field: "barberId",
                        isEqualTo: b.id ?? "",
                        as: Transaction.self
                    ) { r in
                        defer { group.leave() }
                        if case .success(let txns) = r {
                            let totalReceived = txns.filter { $0.type == "received" }.map(\.amount).reduce(0, +)
                            let paid = txns.filter { $0.type == "paidToManager" }.map(\.amount).reduce(0, +)
                            let diff = paid - (totalReceived / 2)
                            stats.append((b, paid, diff))
                        }
                    }
                }

                group.notify(queue: .main) {
                    barberStats = stats
                }

            case .failure:
                break
            }
        }
    }

    // MARK: - Password change sheet UI
    var passwordSheet: some View {
        VStack(spacing: 20) {
            Text("Change Password")
                .font(.headline)
                .foregroundColor(.sbGold)

            SecureField("New Password", text: $newPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.systemGray6))
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
                        Text("Update Password")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.sbGold)
                .foregroundColor(.sbWhite)
                .cornerRadius(10)
            }
            .disabled(isPasswordUpdating)

            Button("Cancel") {
                showPasswordSheet = false
            }
            .padding()
            .foregroundColor(.gray)
        }
        .padding()
        .presentationDetents([.medium])
    }

    // MARK: - Update password logic
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
            self.errorMessage = "Password change not supported for local account"
        }
    }

    // MARK: - Logout logic
    private func logout() {
        do {
            try Auth.auth().signOut()
            authService.logout()
        } catch {
            self.errorMessage = "Error while logging out: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ManagerSettingsView()
        .environmentObject(AuthService())
}
