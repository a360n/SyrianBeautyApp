//
//  InfoCard.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI

struct InfoCard: View {
    let title: String
    let value: Int
    var valueColor: Color?
    var prefixSymbol: String?
    var hideSign: Bool = false
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.2, green: 0.18, blue: 0.16),
                Color(red: 0.25, green: 0.22, blue: 0.19)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.80, green: 0.75, blue: 0.70),
                Color(red: 0.74, green: 0.68, blue: 0.63)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)

        }
    }

//    private var computedColor: Color {
//        if let valueColor = valueColor {
//            return valueColor
//        } else if value < 0 {
//            return .red
//        } else if value == 0 {
//            return .yellow
//        } else {
//            return .white
//        }
//    }

//    private var computedSymbol: String {
//        if hideSign {
//            return ""
//        } else if let symbol = prefixSymbol {
//            return symbol
//        } else if value < 0 {
//            return "-"
//        } else if value > 0 {
//            return "+"
//        } else {
//            return ""
//        }
//    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.sbLightGold)

            Text("\(prefixSymbol ?? "")\(abs(value).formattedWithSeparator()) $")
                .font(.headline)
                .foregroundColor(valueColor ?? .white)

        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .cornerRadius(10)
    }
}
