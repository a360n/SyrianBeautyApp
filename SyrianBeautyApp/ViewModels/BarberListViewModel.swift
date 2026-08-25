//
//  BarberListViewModel.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/8/25.
//

import Foundation
import FirebaseFirestore

struct Barber: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var avatarUrl: String
    var totalReceived: Int
    var totalPaidToManager: Int
    var balance: Int
    var createdAt: Date?
}

class BarberListViewModel: ObservableObject {
    @Published var barbers: [Barber] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func fetchBarbers() {
        isLoading = true
        errorMessage = nil

        db.collection("barbers")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    do {
                        self.barbers = try snapshot?.documents.compactMap {
                            try $0.data(as: Barber.self)
                        } ?? []
                    } catch {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
    }
}
