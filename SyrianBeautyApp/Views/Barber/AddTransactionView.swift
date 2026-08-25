//
//  AddTransactionView.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI
import FirebaseFirestore

struct AddTransactionSheet: View {
    @ObservedObject var authService: AuthService
    @State private var amount: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    var dismissSheet: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                Text("Add a New Payment")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.sbGold)

                TextField("Amount ($)", text: $amount)
                    .keyboardType(.numberPad)
                    .onChange(of: amount) {
                        let filtered = amount.filter { $0.isNumber }
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

                Button(action: submitTransaction) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .sbWhite))
                        } else {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.sbWhite)
                            Text("Submit Payment")
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
            
            // ✅ Loading indicator and screen dim when isLoading is true
            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Processing...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .sbGold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
            }
        }
        .presentationDetents([.height(360)])
    }

    // MARK: - Submit Transaction
    private func submitTransaction() {
        let cleanAmount = amount.replacingOccurrences(of: ",", with: "")
        guard let barberId = authService.barberId,
              let amountInt = Int(cleanAmount), amountInt > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        errorMessage = nil
        isLoading = true
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        let data: [String: Any] = [
            "barberId": barberId,
            "amount": amountInt,
            "type": "received",
            "timestamp": FieldValue.serverTimestamp()
        ]

        let db = Firestore.firestore()

        db.collection("transactions").addDocument(data: data) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }

            // ✅ After adding, recalculate totals and update barber data
            db.collection("transactions")
                .whereField("barberId", isEqualTo: barberId)
                .getDocuments { snapshot, error in
                    self.isLoading = false

                    guard let documents = snapshot?.documents else { return }

                    let txns = documents.compactMap { doc -> Transaction? in
                        try? doc.data(as: Transaction.self)
                    }

                    let totalReceived = txns.filter { $0.type == "received" }.map(\.amount).reduce(0, +)
                    let totalPaid = txns.filter { $0.type == "paidToManager" }.map(\.amount).reduce(0, +)
                    let balance = (totalReceived / 2) - totalPaid

                    db.collection("barbers").document(barberId).updateData([
                        "totalReceived": totalReceived,
                        "totalPaidToManager": totalPaid,
                        "balance": balance
                    ]) { updateError in
                        if let updateError = updateError {
                            self.errorMessage = "Failed to update barber data: \(updateError.localizedDescription)"
                        } else {
                            self.successMessage = "Payment added and data updated successfully!"
                            UIDevice.vibrate()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismissSheet()
                                NotificationCenter.default.post(name: Notification.Name("TransactionAdded"), object: nil)
                            }
                        }
                    }
                }
        }
    }
}
