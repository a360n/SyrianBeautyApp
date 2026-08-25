//
//  DashboardView.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor { $0.userInterfaceStyle == .dark
                    ? UIColor(red: 46/255, green: 43/255, blue: 40/255, alpha: 1)
                    : UIColor(red: 244/255, green: 236/255, blue: 223/255, alpha: 1)
                })
                .edgesIgnoringSafeArea(.all)

                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .sbGold))
                            .padding()
                    } else if let error = viewModel.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(viewModel.barbersWithBalances, id: \.0.id) { barber, paid in
                                    BarberCard(barber: barber, totalPaidToManager: paid)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Manager Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ManagerSettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.sbGold)
                    }
                }
            }
            .onAppear {
                viewModel.loadBarbersWithBalances()
            }
        }
    }
}

class DashboardViewModel: ObservableObject {
    @Published var barbersWithBalances: [(Barber, Int)] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadBarbersWithBalances() {
        isLoading = true
        errorMessage = nil
        barbersWithBalances = []

        FirebaseService.shared.fetchCollection(collection: "barbers", as: Barber.self) { result in
            switch result {
            case .success(let barbers):
                let group = DispatchGroup()
                var tempResults: [(Barber, Int)] = []

                for barber in barbers {
                    group.enter()
                    FirebaseService.shared.queryDocuments(
                        collection: "transactions",
                        field: "barberId",
                        isEqualTo: barber.id ?? "",
                        as: Transaction.self
                    ) { txnResult in
                        defer { group.leave() }
                        if case .success(let txns) = txnResult {
                            let totalPaid = txns.filter { $0.type == "paidToManager" }
                                                .map(\.amount)
                                                .reduce(0, +)
                            tempResults.append((barber, totalPaid))
                        }
                    }
                }

                group.notify(queue: .main) {
                    self.barbersWithBalances = tempResults
                    self.isLoading = false
                }

            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}


#Preview {
    DashboardView()
}
