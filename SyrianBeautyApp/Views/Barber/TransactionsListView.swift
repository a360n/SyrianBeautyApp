//
//  TransactionsListView.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/8/25.
//

import SwiftUI

struct TransactionsListView: View {
    let title: String
    let transactions: [Transaction]

    var body: some View {
        NavigationView {
            List(transactions) { txn in
                TransactionCard(transaction: txn)
            }
            .navigationTitle(title)
        }
    }
}

//#Preview {
//    TransactionsListView()
//}
