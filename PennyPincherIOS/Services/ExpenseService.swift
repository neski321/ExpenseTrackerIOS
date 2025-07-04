import Foundation
import FirebaseFirestore

struct Expense: Identifiable, Codable {
    @DocumentID var id: String?
    var description: String
    var amount: Double
    var date: Date
    var categoryId: String
    var currencyId: String
    var isSubscription: Bool?
    var paymentMethodId: String?
    var nextDueDate: Date?
}

class ExpenseService: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    
    func fetchExpenses(forUserId userId: String) {
        isLoading = true
        error = nil
        listener?.remove()
        listener = db.collection("users").document(userId).collection("expenses")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, err in
                guard let self = self else { return }
                if let err = err {
                    print("Firestore error: \(err.localizedDescription)")
                    self.error = err.localizedDescription
                    self.isLoading = false
                    return
                }
                let docs: [Expense] = snapshot?.documents.compactMap { doc -> Expense? in
                    do {
                        return try doc.data(as: Expense.self)
                    } catch {
                        print("Failed to decode expense \(doc.documentID): \(error)")
                        return nil
                    }
                } ?? []
                print("Fetched \(docs.count) expenses from Firestore for userId: \(userId)")
                self.expenses = docs
                self.isLoading = false
            }
    }
    
    func addExpense(forUserId userId: String, expense: Expense, completion: ((Error?) -> Void)? = nil) {
        do {
            let _ = try db.collection("users").document(userId).collection("expenses").addDocument(from: expense) { error in
                completion?(error)
            }
        } catch {
            completion?(error)
        }
    }
    
    // Add more CRUD methods here as needed
    
    func totalForCurrentMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }
    
    func transactionsForCurrentWeek() -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return 0 }
        return expenses.filter {
            $0.date >= weekInterval.start && $0.date <= weekInterval.end
        }.count
    }
    
    func deleteExpense(forUserId userId: String, expenseId: String, completion: ((Error?) -> Void)? = nil) {
        db.collection("users").document(userId).collection("expenses").document(expenseId).delete { error in
            if let error = error {
                print("Failed to delete expense: \(error.localizedDescription)")
            }
            completion?(error)
        }
    }
} 
