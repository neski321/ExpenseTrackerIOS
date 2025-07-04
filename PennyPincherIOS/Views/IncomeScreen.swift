import SwiftUI

struct IncomeScreen: View {
    let userId: String
    @StateObject private var incomeService = IncomeService()
    @StateObject private var incomeSourceService = IncomeSourceService()
    @State private var showAddIncome = false
    @State private var incomeToDelete: Income? = nil
    @State private var showDeleteConfirm: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Manage Income")
                    .font(.title).bold()
                Text("Track your earnings and keep your finances in order.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer().frame(height: 12)
                if incomeService.isLoading || incomeSourceService.isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView("Loading income..."); Spacer() }
                    Spacer()
                } else if let error = incomeService.error ?? incomeSourceService.error {
                    Spacer()
                    HStack { Spacer(); Text("Error: \(error)").foregroundColor(.red); Spacer() }
                    Spacer()
                } else if incomeService.incomes.isEmpty {
                    Spacer()
                    HStack { Spacer(); Text("No income records found.").foregroundColor(.secondary); Spacer() }
                    Spacer()
                } else {
                    List {
                        Section(header:
                            HStack {
                                Text("Date").font(.caption).frame(maxWidth: .infinity, alignment: .leading)
                                Text("Source").font(.caption).frame(maxWidth: .infinity, alignment: .leading)
                                Text("Amount").font(.caption).frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(.vertical, 4)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(6)
                        ) {
                            ForEach(incomeService.incomes.sorted(by: { $0.date > $1.date })) { income in
                                IncomeRow(
                                    income: income,
                                    sourceName: incomeSourceService.sources.first(where: { $0.id == income.incomeSourceId })?.name ?? income.incomeSourceId,
                                    onDelete: { deleteIncome(income) }
                                )
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddIncome = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddIncome) {
                VStack {
                    Text("Add Income [Placeholder]")
                    Button("Close") { showAddIncome = false }
                }
                .padding()
            }
            .onAppear {
                if !userId.isEmpty {
                    incomeService.fetchIncomes(forUserId: userId)
                    incomeSourceService.fetchIncomeSources(forUserId: userId)
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete this income?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let income = incomeToDelete, let id = income.id, !userId.isEmpty {
                        incomeService.deleteIncome(forUserId: userId, incomeId: id)
                    }
                    incomeToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    incomeToDelete = nil
                }
            }
        }
    }
    
    private func deleteIncome(_ income: Income) {
        incomeToDelete = income
        showDeleteConfirm = true
    }
}

#Preview {
    IncomeScreen(userId: "demoUserId")
} 