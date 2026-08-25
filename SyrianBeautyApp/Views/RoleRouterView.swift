//
//  RoleRouterView.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI

struct RoleRouterView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        ZStack {
            Color.sbBlack.edgesIgnoringSafeArea(.all)

            Group {
                if let role = authService.role {
                    switch role {
                    case "manager":
                        DashboardView()
                    case "barber":
                        NavigationStack {
                            HomeView()
                        }
                    default:
                        Text("Loading...")
                            .foregroundColor(.sbGold)
                    }
                } else {
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    RoleRouterView()
}
