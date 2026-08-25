//
//  StatCard.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/8/25.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: Int
    var valueColor: Color = .white
    var prefixSymbol: String? = nil
    var hideSign: Bool = false
    var icon: String? = nil
    let onTap: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var computedSymbol: String {
        if hideSign {
            return ""
        } else if let symbol = prefixSymbol {
            return symbol
        } else if value < 0 {
            return "-"
        } else if value > 0 {
            return "+"
        } else {
            return ""
        }
    }

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

    var body: some View {
        VStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(valueColor)
            }

            Text("\(computedSymbol)\(abs(value).formattedWithSeparator())")
                .font(.system(size: 15, weight: .semibold))
                .frame(minWidth: 90, alignment: .center)
                .foregroundColor(valueColor)

            Text(title)
                .font(.caption)
                .foregroundColor(.sbLightGold)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}



//#Preview {
//    StatCard()
//}
