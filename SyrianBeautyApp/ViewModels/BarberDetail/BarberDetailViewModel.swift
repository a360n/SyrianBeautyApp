//
//  BarberDetailViewModel.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import Foundation

class BarberDetailViewModel: ObservableObject {
    @Published var barber: Barber?
    @Published var transactions: [Transaction] = []
    var totalReceived: Int {
        transactions.filter { $0.type == "received" }.map(\.amount).reduce(0, +)
    }
    // معاملات اليوم
    var todayTransactions: [Transaction] {
        transactions.filter { Calendar.current.isDateInToday($0.timestamp ?? .distantPast) }
    }

    var yesterdayTransactions: [Transaction] {
        transactions.filter { Calendar.current.isDateInYesterday($0.timestamp ?? .distantPast) }
    }

    // المعاملات الأقدم
    var olderTransactions: [Transaction] {
        transactions.filter { txn in
            guard let date = txn.timestamp else { return false }
            return !Calendar.current.isDateInToday(date) &&
                   !Calendar.current.isDateInYesterday(date)
        }
    }

    var totalPaidToManager: Int {
        transactions.filter { $0.type == "paidToManager" }.map(\.amount).reduce(0, +)
    }

    // إجمالي
    var balance: Int {
      (totalReceived / 2) - totalPaidToManager
    }


    func loadBarberDetails(barberId: String) {
        FirebaseService.shared.fetchDocument(
            collection: "barbers",
            documentId: barberId,
            as: Barber.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let barber) = result {
                    self?.barber = barber
                }
            }
        }

        FirebaseService.shared.queryDocuments(
            collection: "transactions",
            field: "barberId",
            isEqualTo: barberId,
            as: Transaction.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let txns) = result {
                    self?.transactions = txns.sorted(by: { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) })
                }
            }
        }
    }
}
