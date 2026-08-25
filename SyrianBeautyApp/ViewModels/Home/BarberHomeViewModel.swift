//
//  BarberHomeViewModel.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import Foundation
import Combine

class BarberHomeViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var totalReceived: Int = 0
    @Published var totalPaid: Int = 0
    @Published var balance: Int = 0

    @MainActor
    func fetchTransactions(for barberId: String) async {

        if barberId == "demo_barber_001" {
            self.transactions = [
                Transaction(id: "t1", barberId: barberId, amount: 10000, type: "received", timestamp: Date()),
                Transaction(id: "t2", barberId: barberId, amount: 5000, type: "paidToManager", timestamp: Date())
            ]
            self.calculateSums()
            return
        }

        await withCheckedContinuation { continuation in
            FirebaseService.shared.queryDocuments(
                collection: "transactions",
                field: "barberId",
                isEqualTo: barberId,
                as: Transaction.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let txns):
                        self?.transactions = txns.sorted {
                            ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast)
                        }
                        self?.objectWillChange.send()
                        self?.calculateSums()
                    case .failure(let error):
                        print("❗️Error loading transactions:", error)
                    }
                    continuation.resume()
                }
            }
        }
    }

    private func calculateSums() {
        totalReceived = transactions.filter { $0.type == "received" }.map(\.amount).reduce(0, +)
        totalPaid = transactions.filter { $0.type == "paidToManager" }.map(\.amount).reduce(0, +)
        balance = (totalReceived / 2) - totalPaid
    }

    var todayTransactions: [Transaction] {
        transactions.filter { Calendar.current.isDateInToday($0.timestamp ?? .distantPast) }
    }

    var yesterdayTransactions: [Transaction] {
        transactions.filter { Calendar.current.isDateInYesterday($0.timestamp ?? .distantPast) }
    }

    var olderTransactions: [Transaction] {
        transactions.filter {
            guard let date = $0.timestamp else { return false }
            return !Calendar.current.isDateInToday(date) && !Calendar.current.isDateInYesterday(date)
        }
    }
}
