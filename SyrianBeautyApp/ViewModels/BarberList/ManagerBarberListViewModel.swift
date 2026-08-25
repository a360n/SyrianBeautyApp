//
//  ManagerBarberListViewModel.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import Foundation

class ManagerBarberListViewModel: ObservableObject {
    @Published var barbers: [Barber] = []

    func fetchBarbers(isLocalAdmin: Bool = false) {
        if isLocalAdmin {
            // بيانات وهمية للتجربة
            self.barbers = [
                Barber(id: "b001", name: "حلاق 1", avatarUrl: "", totalReceived: 100000, totalPaidToManager: 50000, balance: 50000, createdAt: nil),
                Barber(id: "b002", name: "حلاق 2", avatarUrl: "", totalReceived: 120000, totalPaidToManager: 80000, balance: 40000, createdAt: nil)
            ]
            return
        }

        FirebaseService.shared.queryDocuments(
            collection: "barbers",
            field: "name",
            isEqualTo: "",
            as: Barber.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let barbers):
                    self?.barbers = barbers
                case .failure(let error):
                    print("Error loading barbers:", error)
                }
            }
        }
    }
}
