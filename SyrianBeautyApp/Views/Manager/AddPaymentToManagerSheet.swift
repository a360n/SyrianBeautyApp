//
//  AddPaymentToManagerSheet.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/8/25.
//

import SwiftUI
import FirebaseFirestore

struct AddPaymentToManagerSheet: View {
    let barberId: String
    var dismissSheet: () -> Void

    @State private var amount: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                Text("Add Payment to Manager")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.sbGold)

                TextField("Amount ($)", text: $amount)
                    .keyboardType(.numberPad)
                    .onChange(of: amount) { oldValue, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if let number = Int(filtered) {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            formatter.groupingSeparator = ","
                            amount = formatter.string(from: NSNumber(value: number)) ?? filtered
                        } else {
                            amount = ""
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.primary)

                Button(action: submitPayment) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .sbWhite))
                        } else {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.sbWhite)
                            Text("Confirm Submission")
                                .foregroundColor(.sbWhite)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.sbGold)
                    .cornerRadius(10)
                }
                .disabled(isLoading)

                if let error = errorMessage {
                    Text(error).foregroundColor(.red).font(.footnote)
                }

                if let success = successMessage {
                    Text(success).foregroundColor(.green).font(.footnote)
                }

                Spacer()
            }
            .padding()
            .background(Color.sbSoftBlack)

            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Sending...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .sbGold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
            }
        }
        .presentationDetents([.height(360)])
    }

    private func submitPayment() {
        let cleanAmount = amount.replacingOccurrences(of: ",", with: "")
        guard let amountInt = Int(cleanAmount), amountInt > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        isLoading = true
        errorMessage = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        let data: [String: Any] = [
            "barberId": barberId,
            "amount": amountInt,
            "type": "paidToManager",
            "timestamp": FieldValue.serverTimestamp()
        ]

        Firestore.firestore().collection("transactions").addDocument(data: data) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            } else {
                FirebaseService.shared.queryDocuments(
                    collection: "transactions",
                    field: "barberId",
                    isEqualTo: barberId,
                    as: Transaction.self
                ) { result in
                    switch result {
                    case .success(let txns):
                        let totalReceived = txns.filter { $0.type == "received" }.map(\.amount).reduce(0, +)
                        let totalPaid = txns.filter { $0.type == "paidToManager" }.map(\.amount).reduce(0, +)
                        let balance = (totalReceived / 2) - totalPaid

                        let updateData: [String: Any] = [
                            "totalReceived": totalReceived,
                            "totalPaidToManager": totalPaid,
                            "balance": balance
                        ]

                        FirebaseService.shared.updateDocument(
                            collection: "barbers",
                            documentId: barberId,
                            data: updateData
                        ) { updateError in
                            self.isLoading = false
                            if let updateError = updateError {
                                self.errorMessage = "Added, but update failed: \(updateError.localizedDescription)"
                            } else {
                                self.successMessage = "Added successfully!"
                                UIDevice.vibrate()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                    dismissSheet()
                                    NotificationCenter.default.post(name: Notification.Name("ManagerPaymentAdded"), object: nil)
                                }
                            }
                        }

                    case .failure(let err):
                        self.isLoading = false
                        self.errorMessage = "Added, but failed to fetch transactions: \(err.localizedDescription)"
                    }
                }
            }
        }
    }
}
//#Preview {
//    AddPaymentToManagerSheet()
//}
