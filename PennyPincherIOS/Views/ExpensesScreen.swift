import SwiftUI
import Combine

struct ExpensesScreen: View {
    let userId: String
    @StateObject private var expenseService = ExpenseService()
    @StateObject private var categoryService = CategoryService()
    @StateObject private var paymentMethodService = PaymentMethodService()
    
    @State private var showAddExpense: Bool = false
    @State private var expenseToDelete: Expense? = nil
    @State private var showDeleteConfirm: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Manage Expenses")
                    .font(.title).bold()
                Text("Track your daily spending and keep your finances in order.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer().frame(height: 12)
                if expenseService.isLoading || categoryService.isLoading || paymentMethodService.isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView("Loading expenses..."); Spacer() }
                    Spacer()
                } else if let error = expenseService.error ?? categoryService.error {
                    Spacer()
                    HStack { Spacer(); Text("Error: \(error)").foregroundColor(.red); Spacer() }
                    Spacer()
                } else if expenseService.expenses.isEmpty {
                    Spacer()
                    HStack { Spacer(); Text("No expenses found.").foregroundColor(.secondary); Spacer() }
                    Spacer()
                } else {
                    ExpenseListView(
                        expenses: expenseService.expenses.sorted(by: { $0.date > $1.date }),
                        categories: categoryService.categories,
                        paymentMethods: paymentMethodService.methods,
                        onDelete: { expense in
                            expenseToDelete = expense
                            showDeleteConfirm = true
                        }
                    )
                }
            }
            //.padding(.horizontal, 2)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddExpense = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseDialog(
                    categories: categoryService.categories,
                    paymentMethods: paymentMethodService.methods,
                    currencies: ["USD", "EUR", "KES"],
                    onAdd: { expense in
                        expenseService.addExpense(forUserId: userId, expense: expense)
                    },
                    userId: userId
                )
            }
            .confirmationDialog(
                "Are you sure you want to delete this expense?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let expense = expenseToDelete, let id = expense.id {
                        expenseService.deleteExpense(forUserId: userId, expenseId: id)
                    }
                    expenseToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    expenseToDelete = nil
                }
            }
            .onAppear {
                print("Fetching expenses for userId: \(userId)")
                expenseService.fetchExpenses(forUserId: userId)
                categoryService.fetchCategories(forUserId: userId)
                paymentMethodService.fetchPaymentMethods(forUserId: userId)
            }
        }
    }
}

struct ExpenseListView: View {
    let expenses: [Expense]
    let categories: [Category]
    let paymentMethods: [PaymentMethod]
    let onDelete: (Expense) -> Void
    var body: some View {
        List {
            Section(header:
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Date").font(.caption)
                        Text("Description").font(.caption)
                        Text("Category").font(.caption)
                    }
                    .frame(width: 170, alignment: .leading)
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("Amount").font(.caption)
                        Text("Payment Method").font(.caption)
                    }
                    .frame(width: 110, alignment: .trailing)
                    Text("Action").font(.caption)
                        .frame(width: 40, alignment: .center)
                }
                .padding(.vertical, 4)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(4)
            ) {
                ForEach(expenses) { expense in
                    ExpenseRow(
                        expense: expense,
                        categoryName: categories.first(where: { $0.id == expense.categoryId })?.name ?? expense.categoryId,
                        paymentMethodName: paymentMethods.first(where: { $0.id == expense.paymentMethodId })?.name ?? (expense.paymentMethodId ?? ""),
                        onDelete: { onDelete(expense) }
                    )
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    ExpensesScreen(userId: "demoUserId")
} 
