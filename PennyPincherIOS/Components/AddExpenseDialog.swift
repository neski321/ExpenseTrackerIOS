import SwiftUI

struct AddExpenseDialog: View {
    @Environment(\.dismiss) private var dismiss
    let categories: [Category]
    let paymentMethods: [PaymentMethod]
    let currencies: [String]
    let onAdd: (Expense) -> Void
    let userId: String
    
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var selectedCategoryId: String = ""
    @State private var selectedPaymentMethodId: String = ""
    @State private var selectedCurrencyId: String = "USD"
    @State private var isSubscription: Bool = false
    @State private var nextDueDate: Date = Date()
    @State private var showNextDueDate: Bool = false
    @State private var error: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Description", text: $description)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Picker("Category", selection: $selectedCategoryId) {
                        ForEach(categories) { category in
                            Text(category.name).tag(category.id ?? "")
                        }
                    }
                    Picker("Payment Method", selection: $selectedPaymentMethodId) {
                        Text("None").tag("")
                        ForEach(paymentMethods) { method in
                            Text(method.name).tag(method.id ?? "")
                        }
                    }
                    Picker("Currency", selection: $selectedCurrencyId) {
                        ForEach(currencies, id: \. self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    Toggle("Is Subscription", isOn: $isSubscription)
                        .onChange(of: isSubscription) { value in
                            showNextDueDate = value
                        }
                    if showNextDueDate {
                        DatePicker("Next Due Date", selection: $nextDueDate, displayedComponents: .date)
                    }
                }
                if let error = error {
                    Section {
                        Text(error).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let amountValue = Double(amount), !description.isEmpty, !selectedCategoryId.isEmpty else {
                            error = "Please fill all required fields and enter a valid amount."
                            return
                        }
                        let expense = Expense(
                            id: nil,
                            description: description,
                            amount: amountValue,
                            date: date,
                            categoryId: selectedCategoryId,
                            currencyId: selectedCurrencyId,
                            isSubscription: isSubscription ? true : nil,
                            paymentMethodId: selectedPaymentMethodId.isEmpty ? nil : selectedPaymentMethodId,
                            nextDueDate: showNextDueDate ? nextDueDate : nil
                        )
                        onAdd(expense)
                        dismiss()
                    }
                }
            }
        }
    }
} 