//
//  HomeView.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI
import FirebaseFirestore
import AudioToolbox

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

//extension String: Identifiable {
//    public var id: String { self }
//}

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = BarberHomeViewModel()
    @State private var selectedType: String? = nil//تم
    @State private var showAddSheet = false
    @State private var barberName: String = ""
    @State private var showDateFilterSheet = false//تم
    @State private var selectedDate: Date? = nil//تم
    @State private var dateFrom: Date = Date()//تم
    @State private var dateTo: Date = Date()//تم
    @State private var showDateRangeSheet = false
    @State private var exactDate: Date = Date()//تم
    @State private var showFilterSheet = false//تم
    @State private var isSelectingFromDate = false//تم
    @State private var isSelectingToDate = false//تم
    @State private var filterMode: FilterMode = .none//
    @State private var selectedPeriod: StatPeriod = .today

    enum FilterMode {
        case none, exact, range
    }
    enum StatPeriod: String, CaseIterable, Identifiable {
        case today = "Today"
        case thisMonth = "This Month"
        var id: String { self.rawValue }
    }

    
    var body: some View {
        NavigationStack {
        ZStack(alignment: .bottom) {
            Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 46/255, green: 43/255, blue: 40/255, alpha: 1)
                : UIColor(red: 244/255, green: 236/255, blue: 223/255, alpha: 1)
            })
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                contentView()
                    .padding(.bottom, selectedDate != nil ? 140 : 80) // مساحة للزرين
                
                Spacer(minLength: 0)
            }
            
            // زر إلغاء التصفية إذا تم اختيار تاريخ
            if let selected = selectedDate {
                VStack(spacing: 4) {
                    Text(" Filtered by: \(selected.formatted(date: .long, time: .omitted))")
                        .foregroundColor(.primary)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                    
                    
                    Button(action: {
                        selectedDate = nil
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                            Text("Clear Filter")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 80)
            }//تم
            
            // زر إضافة دفعة جديدة
            Button(action: {
                showAddSheet = true
            }) {
                Text("Add New Transaction")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.sbGold)
                    .foregroundColor(.sbWhite)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        
        .refreshable {
            if let barberId = authService.barberId {
                await viewModel.fetchTransactions(for: barberId)
            }
        }
        
        .task {
            print("📌 Task running")
               if let barberId = authService.barberId {
                   print("📌 Fetching barber: \(barberId)")
                   await viewModel.fetchTransactions(for: barberId)
                   loadBarberName(from: barberId)
               }
            if let barberId = authService.barberId {
                await viewModel.fetchTransactions(for: barberId)
                loadBarberName(from: barberId)
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TransactionAdded"))) { _ in
            if let barberId = authService.barberId {
                Task {
                    await viewModel.fetchTransactions(for: barberId)
                }
            }
        }
        .navigationTitle("Accounts- \(barberName)")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showFilterSheet = true
                }) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.sbGold)
                        .padding(6)
                        .clipShape(Circle())
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: BarberSettings()) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.sbGold)
                }
            }
        }
        
        .sheet(isPresented: $showAddSheet) {
            AddTransactionSheet(authService: authService, dismissSheet: {
                showAddSheet = false
            })
        }
        .sheet(isPresented: $showFilterSheet) {
            VStack(spacing: 20) {
                Text("Filter Transactions")
                    .font(.headline)
                    .foregroundColor(.sbGold)
                
                Picker("Type", selection: $selectedType) {
                    Text("All").tag(String?.none)
                    Text("Received").tag(String?("received"))
                    Text("Paid to Manager").tag(String?("paidToManager"))
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("Date Mode", selection: $filterMode) {
                    Text("No Date").tag(FilterMode.none)
                    Text("Exact Day").tag(FilterMode.exact)
                    Text("Range").tag(FilterMode.range)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if filterMode == .exact {
                    DatePicker("", selection: $exactDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                } else if filterMode == .range {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("From:")
                                .font(.subheadline)
                                .foregroundColor(.sbGold)

                            DatePicker("", selection: $dateFrom, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("To:")
                                .font(.subheadline)
                                .foregroundColor(.sbGold)

                            DatePicker("", selection: $dateTo, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }

                
                
                
                HStack {
                    Button("Apply") {
                        showFilterSheet = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.sbGold)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Cancel") {
                        selectedType = nil
                        filterMode = .none
                        showFilterSheet = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .presentationDetents([.fraction(1.0)]) // يغطي الشاشة بالكامل
            .presentationDragIndicator(.visible) // اختيارية لعرض المؤشر الأعلى
        }
        
    }
}
    
    
    
    
    
    private var filteredTransactions: [Transaction] {
        viewModel.transactions.filter { txn in
            var matches = true

            // Debug Print
            let tsString = txn.timestamp?.description ?? "nil"
            print("🔍 Checking transaction: \(String(describing: txn.id)), Type: \(txn.type), Date: \(tsString)")

            // فلترة حسب النوع
            if let type = selectedType, type != "profit" {
                matches = matches && txn.type == type
            }

            // فلترة حسب التاريخ
            if filterMode == .exact {
                if let txDate = txn.timestamp {
                    matches = matches && Calendar.current.isDate(txDate, inSameDayAs: exactDate)
                } else {
                    matches = false
                    print("⚠️ No timestamp available for transaction \(String(describing: txn.id))")
                }
            } else if filterMode == .range {
                if let txDate = txn.timestamp {
                    let start = Calendar.current.startOfDay(for: dateFrom)
                    let end = Calendar.current.date(
                        bySettingHour: 23, minute: 59, second: 59,
                        of: dateTo
                    ) ?? dateTo

                    matches = matches && (txDate >= start && txDate <= end)
                } else {
                    matches = false
                    print("⚠️ No timestamp available for transaction \(String(describing: txn.id))")
                }
            }

            print("✅ Filter result for transaction \(String(describing: txn.id)): \(matches ? "Accepted" : "Rejected")")
            return matches
        }
    }



    private func loadBarberName(from barberId: String) {
        FirebaseService.shared.fetchDocument(
            collection: "barbers",
            documentId: barberId,
            as: Barber.self
        ) { result in
            DispatchQueue.main.async {
                if case .success(let barber) = result {
                    self.barberName = barber.name
                }
            }
        }
    }

    private func contentView() -> some View {
        
        ScrollView {
            VStack(spacing: 20) {
                statCards()

                // عرض تفاصيل الفلاتر المطبقة
                if selectedType != nil || filterMode != .none {
                    VStack(spacing: 4) {
                        if let type = selectedType {
                            Text("Type: \(type == "received" ? "Received" : "Paid to Manager")")
                                .foregroundColor(.sbGold)
                        }

                        
                        if filterMode == .exact {
                            Text("Date: \(exactDate.formatted(date: .long, time: .omitted))")
                                .foregroundColor(.sbGold)
                        } else if filterMode == .range {
                            Text("From: \(dateFrom.formatted(date: .abbreviated, time: .omitted)) To \(dateTo.formatted(date: .abbreviated, time: .omitted))")
                                .foregroundColor(.sbGold)
                        } else if selectedType != nil {
                            Text("Filter by type only")
                                .foregroundColor(.sbGold)
                        }

                        Button(action: {
                            selectedType = nil
                            filterMode = .none
                            exactDate = Date()
                            dateFrom = Date()
                            dateTo = Date()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                Text("Clear Filter")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 80)
                }

                
                // نتائج التصفية أو التصنيفات الأساسية
                if selectedType != nil || filterMode != .none {
                    if filteredTransactions.isEmpty {
                        Text("No transactions match the selected filters")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(groupedTransactions(filteredTransactions)) { section in
                            SectionView(title: section.title, transactions: section.items)
                        }
                    }
                } else {
                    if !viewModel.todayTransactions.isEmpty {
                        SectionView(title: " Today", transactions: viewModel.todayTransactions)
                    }
                    if !viewModel.yesterdayTransactions.isEmpty {
                        SectionView(title: "Yesterday", transactions: viewModel.yesterdayTransactions)
                    }
                    if !viewModel.olderTransactions.isEmpty {
                        SectionView(title: "Previous Days", transactions: viewModel.olderTransactions)
                    }
                }
            }
            .padding()
        }
        // شاشة الفلاتر
        // شيت لعجلة "من"
        .sheet(isPresented: $isSelectingFromDate) {
            VStack {
                DatePicker("From:", selection: $dateFrom, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                Button("Done") {
                    isSelectingFromDate = false
                }
                .padding()
            }
            .presentationDetents([.height(300)])
        }

        // شيت لعجلة "إلى"
        .sheet(isPresented: $isSelectingToDate) {
            VStack {
                DatePicker("To:", selection: $dateTo, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                Button("Done") {
                    isSelectingToDate = false
                }
                .padding()
            }
            .presentationDetents([.height(300)])
        }
        .overlay(emptyOverlay())
    }//تم
    func groupedTransactions(_ txns: [Transaction]) -> [TransactionSection] {
        let grouped = Dictionary(grouping: txns) { txn in
            guard let date = txn.timestamp else {
                return "Unknown"
            }
            if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            }
        }

        return grouped.map { TransactionSection(title: $0.key, items: $0.value) }
            .sorted { lhs, rhs in lhs.title > rhs.title }
    }

    struct TransactionSection: Identifiable {
        let id = UUID()
        let title: String
        let items: [Transaction]
    }//تم

    private func statCards() -> some View {
        VStack(spacing: 16) {
            // 1. عرض Picker فقط عندما filterMode == .none
            if filterMode == .none {
                HStack(spacing: 0) {
                    ForEach(StatPeriod.allCases) { period in
                        Button(period.rawValue) {
                            selectedPeriod = period
                        }
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundColor(selectedPeriod == period ? .sbBlack : .sbGold)
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(
                            ZStack {
                                if selectedPeriod == period {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.sbGold)
                                        .transition(.opacity)
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor { trait in
                            trait.userInterfaceStyle == .dark
                            ? UIColor(red: 44/255, green: 43/255, blue: 40/255, alpha: 1)
                            : UIColor(red: 224/255, green: 212/255, blue: 195/255, alpha: 1)
                        }))
                )
                .padding(.horizontal)
            }

            // 2. حساب الفترة الفعلية للتصفية
            let filteredTxns: [Transaction] = {
                switch filterMode {
                case .none:
                    return viewModel.transactions.filter { txn in
                        guard let date = txn.timestamp else { return false }
                        switch selectedPeriod {
                        case .today:
                            return Calendar.current.isDateInToday(date)
                        case .thisMonth:
                            return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
                        }
                    }
                case .exact:
                    return viewModel.transactions.filter { txn in
                        guard let date = txn.timestamp else { return false }
                        return Calendar.current.isDate(date, inSameDayAs: exactDate)
                    }
                case .range:
                    return viewModel.transactions.filter { txn in
                        guard let date = txn.timestamp else { return false }
                        let start = Calendar.current.startOfDay(for: dateFrom)
                        let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: dateTo)!
                        return (date >= start && date <= end)
                    }
                }
            }()

            // 3. حساب الأرقام
            let totalReceived = filteredTxns.filter { $0.type == "received" }.map(\.amount).reduce(0, +)
            let totalPaid     = filteredTxns.filter { $0.type == "paidToManager" }.map(\.amount).reduce(0, +)
            let profit        = totalReceived - totalPaid

            // 4. بطاقات الإحصائيات
            HStack(spacing: 12) {
                StatCard(title: "Received", value: totalReceived, valueColor: .green, hideSign: true, icon: "arrow.down.circle.fill") { selectedType = "received" }

                StatCard(title: "To Manager", value: totalPaid, valueColor: .red, hideSign: true, icon: "arrow.up.circle.fill") { selectedType = "paidToManager" }

                StatCard(title: "Profit",
                         value: abs(profit),
                         valueColor: profit >= 0 ? .green : .red,
                         prefixSymbol: profit >= 0 ? "+" : "-",
                         hideSign: false,
                         icon: "creditcard.fill") {
                            selectedType = "profit"
                         }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical)
    }//تم
    @ViewBuilder
    private func filterSheetView() -> some View {
        VStack(spacing: 20) {
            Text("Filter Transactions")
                .font(.headline)
                .foregroundColor(.sbGold)

            Picker("Type", selection: $selectedType) {
                Text("All").tag(String?.none)
                Text("Received").tag(String?("received"))
                Text("Paid to Manager").tag(String?("paidToManager"))
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Color.sbLightGray)
            .cornerRadius(8)

            Picker("Date Mode", selection: $filterMode) {
                Text("No Date").tag(FilterMode.none)
                Text("Exact Day").tag(FilterMode.exact)
                Text("Range").tag(FilterMode.range)
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Color.sbLightGray)
            .cornerRadius(8)

            if filterMode == .exact {
                DatePicker("Choose the date", selection: $exactDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .accentColor(Color.sbGold)
            } else if filterMode == .range {
                VStack(spacing: 16) {
                    Button(action: { isSelectingFromDate = true }) {
                        HStack {
                            Text("From:")
                            Spacer()
                            Text(dateFrom.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.sbGold)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }

                    Button(action: { isSelectingToDate = true }) {
                        HStack {
                            Text("To:")
                            Spacer()
                            Text(dateTo.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.sbGold)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }




            HStack {
                Button("Apply") {
                    showFilterSheet = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.sbGold)
                .foregroundColor(.sbBlack)
                .cornerRadius(10)

                Button("Cancel") {
                    selectedType = nil
                    filterMode = .range
                    dateFrom = Date()
                    dateTo = Date()
                    showFilterSheet = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.sbWhite)
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .background(Color.sbSoftBlack)
        .cornerRadius(20)
        .presentationDetents([.medium, .large])
    }//تم
    

    private func emptyOverlay() -> some View {
        Group {
            if viewModel.transactions.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No transactions yet")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
                .padding()
            }
        }
    }
}

#Preview {
    HomeView()
}
