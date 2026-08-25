//
//  Transaction.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import Foundation

struct Transaction: Identifiable, Codable {
    @DocumentID var id: String?
    var barberId: String
    var amount: Int
    var type: String // "received" or "paidToManager"
    @ServerTimestamp var timestamp: Date?
    
    init(id: String? = nil, barberId: String, amount: Int, type: String, timestamp: Date? = nil) {
            self.id = id
            self.barberId = barberId
            self.amount = amount
            self.type = type
            self.timestamp = timestamp
        }
}
