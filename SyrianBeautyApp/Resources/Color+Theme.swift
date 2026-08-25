//
//  Color+Theme.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import Foundation
import SwiftUI

extension Color {
    static let sbBlack = Color(hex: "#121212")
    static let sbWhite = Color(hex: "#FFFFFF")
    static let sbGold = Color(hex: "#CDA434")
    static let sbBrown = Color(hex: "#5D4037")
    static let sbLightGray = Color(hex: "#F5F5F5")
    static let sbSoftBlack = Color(hex: "#2C2C2C")
    static let sbLightGold = Color(hex: "#FFD700")
    static let sbLightBrown = Color(hex: "#A1887F")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        scanner.currentIndex = hex.index(hex.startIndex, offsetBy: 1)
        scanner.scanHexInt64(&hexNumber)

        let r = Double((hexNumber & 0xff0000) >> 16) / 255
        let g = Double((hexNumber & 0x00ff00) >> 8) / 255
        let b = Double(hexNumber & 0x0000ff) / 255

        self.init(red: r, green: g, blue: b)
    }
}

