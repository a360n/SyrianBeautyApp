//
//  AddBarberView.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI

struct AddBarberView: View {
    @EnvironmentObject var authService: AuthService

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var barberId: String = ""

    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color.sbBlack.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    Text("Add New Barber")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.sbGold)

                    Group {
                        TextField("Full Name", text: $name)
                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                        SecureField("Password", text: $password)
                        SecureField("Confirm Password", text: $confirmPassword)
                        TextField("Barber Code (barberId)", text: $barberId)
                    }
                    .padding()
                    .background(Color.sbLightGray)
                    .cornerRadius(10)

                    if let error = errorMessage {
                        Text(error).foregroundColor(.red).font(.footnote)
                    }

                    if let success = successMessage {
                        Text(success).foregroundColor(.green).font(.footnote)
                    }

                    Button(action: addBarber) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .sbGold))
                        } else {
                            Text("Add Barber")
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

    private func addBarber() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !barberId.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        errorMessage = nil
        isLoading = true

        authService.createUser(email: email, password: password, role: "barber", barberId: barberId, name: name) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let barber = Barber(
                        id: barberId,
                        name: name,
                        avatarUrl: "",
                        totalReceived: 0,
                        totalPaidToManager: 0,
                        balance: 0,
                        createdAt: nil
                    )

                    FirebaseService.shared.writeDocument(collection: "barbers", documentId: barberId, data: barber) { error in
                        DispatchQueue.main.async {
                            isLoading = false
                            if let error = error {
                                errorMessage = error.localizedDescription
                            } else {
                                successMessage = "Barber added successfully!"
                                name = ""
                                email = ""
                                password = ""
                                confirmPassword = ""
                                barberId = ""
                            }
                        }
                    }

                case .failure(let error):
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}


#Preview {
    AddBarberView()
        .environmentObject(AuthService())
}
