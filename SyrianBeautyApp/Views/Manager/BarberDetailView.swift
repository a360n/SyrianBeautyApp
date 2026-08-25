//
//  BarberDetailView.swift
//  SyrianBeautyApp
//
//  Created by Ali Al-Khazali on 6/6/25.
//

import SwiftUI

struct BarberDetailView: View {
    let barberId: String
    @StateObject private var viewModel = BarberDetailViewModel()
    @State private var showPaymentSheet = false
    @StateObject var transactionViewModel = BarberHomeViewModel()
    
    @State private var paymentAmount = ""
    @State private var selectedType: String? = nil//تم
    @State private var isSelectingToDate = false//تم
    @State private var selectedDate: Date? = nil//تم
    
    @State private var showConfirmationDialog = false
    @State private var errorMessage: String?
    @State private var showAddSheet = false
    @State private var transactions: [Transaction] = []
    @State private var showDateFilterSheet = false//تم
    @State private var isSelectingFromDate = false//تم
    @State private var showFilterSheet = false//تم
    @State private var dateFrom: Date = Date()//تم
    @State private var dateTo: Date = Date()//تم
    @State private var filterMode: FilterMode = .none//
    @State private var exactDate: Date = Date()//تم
    @State private var selectedPeriod: StatPeriod = .today
    enum FilterMode {
        case none, exact, range
    }
    enum StatPeriod: String, CaseIterable, Identifiable {
        case today = "Today"
        case thisMonth = "This Month"
        
        var id: String { self.rawValue }
    }
    var totalReceived: Int {
        viewModel.transactions.filter { $0.type == "received" }.map(\.amount).reduce(0, +)
    }
    
    var totalPaidToManager: Int {
        viewModel.transactions.filter { $0.type == "paidToManager" }.map(\.amount).reduce(0, +)
    }
    
    var balance: Int {
        totalPaidToManager - (totalReceived / 2)
    }
    var body: some View {
        ZStack {
            Color(UIColor { trait in
                trait.userInterfaceStyle == .dark
                ? UIColor(red: 46/255, green: 43/255, blue: 40/255, alpha: 1)
                : UIColor(red: 244/255, green: 236/255, blue: 223/255, alpha: 1)
            })
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { showFilterSheet.toggle() }) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.title2)
                            .foregroundColor(.sbGold)
                            .padding(8)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 20) {
                        let filteredTransactions: [Transaction] = {
                            var txns = viewModel.transactions
                            
                            if let type = selectedType {
                                txns = txns.filter { $0.type == type }
                            }
                            
                            switch filterMode {
                            case .exact:
                                txns = txns.filter {
                                    guard let d = $0.timestamp else { return false }
                                    return Calendar.current.isDate(d, inSameDayAs: exactDate)
                                }
                            case .range:
                                txns = txns.filter {
                                    guard let d = $0.timestamp else { return false }
                                    let start = Calendar.current.startOfDay(for: dateFrom)
                                    let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: dateTo)!
                                    return d >= start && d <= end
                                }
                            default:
                                break
                            }
                            
                            return txns
                        }()
                        
                        statCards()
                        Divider().background(Color.sbLightGray)
                        
                        if let barber = viewModel.barber {
                            AvatarImage(url: barber.avatarUrl)
                                .frame(width: 100, height: 100)
                            
                            Text(barber.name)
                                .font(.title2)
                                .foregroundColor(.sbGold)
                            
                            InfoCard(title: "Total Received by Barber", value: totalReceived, valueColor: .white)
                            InfoCard(title: "Paid to Manager", value: totalPaidToManager, valueColor: .white)
                            
                            let profit = totalReceived - totalPaidToManager
                            InfoCard(
                                title: "Barber's Profit",
                                value: abs(profit),
                                valueColor: profit >= 0 ? .green : .red,
                                prefixSymbol: profit >= 0 ? "+" : "-"
                            )
                            
                            let balance = totalPaidToManager - (totalReceived / 2)
                            if balance != 0 {
                                InfoCard(
                                    title: balance < 0 ? "Amount Owed to Manager" : "Amount Owed to Barber",
                                    value: abs(balance),
                                    valueColor: balance > 0 ? .red : .green,
                                    prefixSymbol: balance > 0 ? "-" : "+"
                                )
                            }
                            
                            Divider().background(Color.sbLightGray)
                            
                            if filteredTransactions.isEmpty {
                                Text("No transactions match the selected filters")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(filteredTransactions) { txn in
                                    TransactionCard(transaction: txn)
                                }
                            }
                        } else {
                            ProgressView("Loading...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .sbGold))
                        }
                        
                        if let error = errorMessage {
                            Text(error).foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, selectedDate != nil ? 180 : 120)
                }
                
                VStack(spacing: 12) {
                    if selectedType != nil || filterMode != .none {
                        VStack(spacing: 4) {
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
                                    Text("Clear Filters")
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
                        .padding(.bottom, 45)
                    }
                    
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Text("Add Payment to Manager")
                            .foregroundColor(.sbWhite)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.sbGold)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
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
                
                Picker("Date Filter Mode", selection: $filterMode) {
                    Text("No Date").tag(FilterMode.none)
                    Text("Exact Day").tag(FilterMode.exact)
                    Text("Date Range").tag(FilterMode.range)
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
            .presentationDetents([.fraction(1.0)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.loadBarberDetails(barberId: barberId)
            Task {
                await transactionViewModel.fetchTransactions(for: barberId)
            }
        }
        .sheet(isPresented: $showPaymentSheet) {
            paymentSheet
        }
        .sheet(isPresented: $showAddSheet) {
            AddPaymentToManagerSheet(barberId: barberId) {
                showAddSheet = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ManagerPaymentAdded"))) { _ in
            viewModel.loadBarberDetails(barberId: barberId)
        }
        .alert("Are you sure you want to pay \(paymentAmount) $?", isPresented: $showConfirmationDialog) {
            Button("Confirm", role: .destructive) {
                submitPayment()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    var paymentSheet: some View {
        VStack(spacing: 20) {
            Text("Add New Payment")
                .font(.headline)
                .foregroundColor(.sbGold)
            
            TextField("Amount", text: $paymentAmount)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.sbLightGray)
                .cornerRadius(10)
            
            Button("Confirm Payment") {
                showPaymentSheet = false
                showConfirmationDialog = true
            }
            .disabled(paymentAmount.isEmpty)
            .padding()
            .background(Color.sbGold)
            .foregroundColor(.sbWhite)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
    
    func groupedTransactions(_ txns: [Transaction]) -> [TransactionSection] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let grouped = Dictionary(grouping: txns) { txn in
            guard let date = txn.timestamp else { return "Unknown Date" }
            
            if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                return formatter.string(from: date)
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
    private func contentView() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                statCards()
                
                // Show applied filter details
                if selectedType != nil || filterMode != .none {
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()
                            if let type = selectedType {
                                Text(type == "received" ? "Received" : "Paid to Manager")
                                    .foregroundColor(.sbGold)
                                    .padding(8)
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }
                        
                        if filterMode == .exact {
                            Text("Date: \(exactDate.formatted(date: .long, time: .omitted))")
                                .foregroundColor(.sbGold)
                        } else if filterMode == .range {
                            Text("From: \(dateFrom.formatted(date: .abbreviated, time: .omitted)) to \(dateTo.formatted(date: .abbreviated, time: .omitted))")
                                .foregroundColor(.sbGold)
                        }
                        
                        Button(action: {
                            selectedType = nil
                            filterMode = .none
                            dateFrom = Date()
                            dateTo = Date()
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Clear Filters")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.sbBrown.opacity(0.2))
                    .cornerRadius(12)
                }
                
                // Filtered or default transaction sections
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
                        SectionView(title: "Today", transactions: transactionViewModel.todayTransactions)
                    }
                    if !viewModel.yesterdayTransactions.isEmpty {
                        SectionView(title: "Yesterday", transactions: transactionViewModel.yesterdayTransactions)
                    }
                    if !viewModel.olderTransactions.isEmpty {
                        SectionView(title: "Previous Days", transactions: transactionViewModel.olderTransactions)
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showFilterSheet) {
            VStack(spacing: 20) {
                Text("Filter Transactions")
                    .font(.headline)
                    .foregroundColor(.sbGold)
                    .padding(.top)
                
                Picker("Type", selection: $selectedType) {
                    Text("All").tag(String?.none)
                    Text("Received").tag(String?("received"))
                    Text("Paid to Manager").tag(String?("paidToManager"))
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("Date Filter Mode", selection: $filterMode) {
                    Text("Exact Day").tag(FilterMode.exact)
                    Text("Date Range").tag(FilterMode.range)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if filterMode == .exact {
                    DatePicker("", selection: $exactDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .accentColor(.sbGold)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
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
            .presentationDetents([.fraction(1.0)])
            .presentationDragIndicator(.visible)
        }
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
    }
    private func emptyOverlay() -> some View {
        Group {
            if viewModel.todayTransactions.isEmpty &&
                viewModel.yesterdayTransactions.isEmpty &&
                viewModel.olderTransactions.isEmpty {
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
    private func statCards() -> some View {
        VStack(spacing: 16) {
            // 1. Show Picker only when filterMode == .none
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
            
            // 2. Filter transactions based on selected period or filters
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
            
            // 3. Calculate totals
            let totalReceived = filteredTxns.filter { $0.type == "received" }.map(\.amount).reduce(0, +)
            let totalPaid     = filteredTxns.filter { $0.type == "paidToManager" }.map(\.amount).reduce(0, +)
            let profit        = totalReceived - totalPaid
            
            // 4. Stat Cards
            HStack(spacing: 12) {
                StatCard(title: "Received", value: totalReceived, valueColor: .green, hideSign: true, icon: "arrow.down.circle.fill") {
                    selectedType = "received"
                }
                
                StatCard(title: "To Manager", value: totalPaid, valueColor: .red, hideSign: true, icon: "arrow.up.circle.fill") {
                    selectedType = "paidToManager"
                }
                
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
    }
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
            
            Picker("Date Filter Mode", selection: $filterMode) {
                Text("No Date").tag(FilterMode.none)
                Text("Exact Day").tag(FilterMode.exact)
                Text("Date Range").tag(FilterMode.range)
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Color.sbLightGray)
            .cornerRadius(8)
            
            if filterMode == .exact {
                DatePicker("Select Date", selection: $exactDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .accentColor(Color.sbGold)
            } else if filterMode == .range {
                VStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("From:")
                            .font(.subheadline)
                            .foregroundColor(.sbGold)
                        DatePicker("From", selection: $dateFrom, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading) {
                        Text("To:")
                            .font(.subheadline)
                            .foregroundColor(.sbGold)
                        DatePicker("To", selection: $dateTo, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
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
    }
    
    private var filteredTransactions: [Transaction] {
        viewModel.transactions.filter { txn in
            var matches = true
            
            // فلترة حسب النوع
            if let type = selectedType {
                matches = matches && txn.type == type
            }
            
            // فلترة حسب التاريخ
            if filterMode == .exact {
                if let txDate = txn.timestamp {
                    matches = matches && Calendar.current.isDate(txDate, inSameDayAs: exactDate)
                } else {
                    matches = false
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
                }
            }
            
            return matches
        }
    }//تم
    
    
    private func submitPayment() {
        guard let amount = Int(paymentAmount), amount > 0 else {
            errorMessage = "Please enter a valid amount"
            return
        }
        
        let transaction = Transaction(
            barberId: barberId,
            amount: amount,
            type: "paidToManager",
            timestamp: Date()
        )
        
        // 1. Add the transaction
        FirebaseService.shared.addDocument(collection: "transactions", data: transaction) { result in
            switch result {
            case .success:
                // 2. Fetch all transactions for this barber
                FirebaseService.shared.queryDocuments(
                    collection: "transactions",
                    field: "barberId",
                    isEqualTo: barberId,
                    as: Transaction.self
                ) { txnResult in
                    switch txnResult {
                    case .success(let txns):
                        let totalReceived = txns.filter { $0.type == "received" }.map(\.amount).reduce(0, +)
                        let totalPaid = txns.filter { $0.type == "paidToManager" }.map(\.amount).reduce(0, +)
                        let balance = (totalReceived / 2) - totalPaid
                        
                        // 3. Update the barber document with calculated values
                        let updatedFields: [String: Any] = [
                            "totalReceived": totalReceived,
                            "totalPaidToManager": totalPaid,
                            "balance": balance
                        ]
                        
                        FirebaseService.shared.updateDocument(collection: "barbers", documentId: barberId, data: updatedFields) { error in
                            if let error = error {
                                errorMessage = "Failed to update data: \(error.localizedDescription)"
                            } else {
                                paymentAmount = ""
                                errorMessage = nil
                                viewModel.loadBarberDetails(barberId: barberId)
                            }
                        }
                        
                    case .failure(let error):
                        errorMessage = "Failed to fetch transactions: \(error.localizedDescription)"
                    }
                }
                
            case .failure(let error):
                errorMessage = "Failed to record transaction: \(error.localizedDescription)"
            }
        }
    }
}


#Preview {
    BarberDetailView(barberId: "mock_barber_001")
}
