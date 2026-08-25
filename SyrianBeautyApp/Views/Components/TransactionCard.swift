//
//  TransactionCard.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI

struct TransactionCard: View {
    let transaction: Transaction

    var typeIcon: String {
        transaction.type == "received" ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
    }

    var typeColor: Color {
        transaction.type == "received" ? .green : .red
    }

    var typeLabel: String {
        transaction.type == "received" ? "Received" : "Paid to Manager"
    }

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: typeIcon)
                .font(.system(size: 30))
                .foregroundColor(typeColor)

            VStack(alignment: .leading, spacing: 5) {
                Text("\(transaction.amount) $")
                    .font(.title3)
                    .bold()

                Text(transaction.timestamp?.formatted(date: .abbreviated, time: .shortened) ?? "Not Available")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(typeLabel)
                    .font(.caption2)
                    .padding(4)
                    .background(typeColor.opacity(0.1))
                    .cornerRadius(5)
                    .foregroundColor(typeColor)
            }

            Spacer()
        }
        .padding()
        .background(Color.sbLightBrown.opacity(0.15))
        .cornerRadius(12)
    }
}


//#Preview {
//    TransactionCard(transaction: Transaction(
//        id: "mock_txn_001",
//        barberId: "barber_001",
//        amount: 15000,
//        type: "received",
//        timestamp: Date()
//    ))
//    .previewLayout(.sizeThatFits)
//    .padding()
//    .background(Color.sbBlack)
//}

