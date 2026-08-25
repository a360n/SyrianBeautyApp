//
//  SectionView.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/8/25.
//

import SwiftUI

struct SectionView: View {
    let title: String
    let transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.sbGold)
                .font(.headline)
                .padding(.leading, 4)

            ForEach(transactions) { txn in
                TransactionCard(transaction: txn)
            }
        }
        .padding(.vertical)
    }
}


//#Preview {
//    SectionView()
//}
