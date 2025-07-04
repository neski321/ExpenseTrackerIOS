import SwiftUI

struct DashboardScreen: View {
    let userId: String
    @Binding var selectedTab: ContentView.Screen
    @StateObject private var expenseService = ExpenseService()
    @State private var isLoading: Bool = false
    @State private var isRefreshing: Bool = false
    @State private var showAddExpenseDialog: Bool = false
    
    var body: some View {
        ZStack {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading dashboard...")
                        .scaleEffect(1.5)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Quick Actions
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Actions")
                                .font(.title2).bold()
                            Text("Manage your finances efficiently.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Button(action: { showAddExpenseDialog = true }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add New Expense")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            Button(action: { selectedTab = .categories }) {
                                HStack {
                                    Image(systemName: "tag")
                                    Text("Manage Categories")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        // Stat Cards
                        HStack(spacing: 16) {
                            StatCardView(title: "This Month", value: String(format: "$%.2f", expenseService.totalForCurrentMonth()))
                            StatCardView(title: "This Week", value: "\(expenseService.transactionsForCurrentWeek()) transactions", onTap: { selectedTab = .expenses })
                        }
                        // Spending Overview (Bar Chart Placeholder)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Spending Overview")
                                .font(.title3).bold()
                            Rectangle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(height: 120)
                                .overlay(Text("[Bar Chart Placeholder]").foregroundColor(.blue))
                        }
                        // Spending by Category (Pie Chart Placeholder)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Spending by Category")
                                .font(.title3).bold()
                            Rectangle()
                                .fill(Color.green.opacity(0.2))
                                .frame(height: 120)
                                .overlay(Text("[Pie Chart Placeholder]").foregroundColor(.green))
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            expenseService.fetchExpenses(forUserId: userId)
        }
        .sheet(isPresented: $showAddExpenseDialog) {
            VStack {
                Text("Add Expense Dialog Placeholder")
                Button("Close") { showAddExpenseDialog = false }
            }
            .padding()
        }
    }
}

struct StatCardView: View {
    var title: String
    var value: String
    var onTap: (() -> Void)? = nil
    var body: some View {
        Button(action: { onTap?() }) {
            VStack {
                Text(title)
                    .font(.headline)
                Text(value)
                    .font(.title2).bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashboardScreen(userId: "1", selectedTab: .constant(.dashboard))
} 