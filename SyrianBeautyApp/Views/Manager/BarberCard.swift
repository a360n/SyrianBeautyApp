//
//  BarberCard.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/9/25.
//

import SwiftUI

struct BarberCard: View {
    let barber: Barber
    let totalPaidToManager: Int

    var body: some View {
        NavigationLink(destination: BarberDetailView(barberId: barber.id ?? "")) {
            HStack(spacing: 15) {
                AvatarImage(url: barber.avatarUrl)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(barber.name)
                        .foregroundColor(.sbGold)
                        .font(.headline)

                    Text("Paid to Manager: \(totalPaidToManager.formattedWithSeparator()) $")
                        .foregroundColor(.primary)
                        .font(.subheadline)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor {
                $0.userInterfaceStyle == .dark
                    ? UIColor(red: 60/255, green: 55/255, blue: 50/255, alpha: 1)
                    : UIColor(red: 235/255, green: 230/255, blue: 220/255, alpha: 1)
            }))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}
//#Preview {
//    BarberCard()
//}
