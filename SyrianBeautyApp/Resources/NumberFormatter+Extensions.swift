//
//  NumberFormatter+Extensions.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/8/25.
//

import Foundation

extension Int {
    var formattedWithSeparatorr: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
