import Foundation
import FirebaseFirestore
import Combine

struct Income: Identifiable, Codable {
    @DocumentID var id: String?
    var amount: Double
    var date: Date
    var incomeSourceId: String
    var currencyId: String
    var description: String
}

class IncomeService: ObservableObject {
    @Published var incomes: [Income] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    
    func fetchIncomes(forUserId userId: String) {
        isLoading = true
        error = nil
        listener?.remove()
        listener = db.collection("users").document(userId).collection("incomes")
            .addSnapshotListener { [weak self] snapshot, err in
                guard let self = self else { return }
                if let err = err {
                    print("Firestore error: \(err.localizedDescription)")
                    self.error = err.localizedDescription
                    self.isLoading = false
                    return
                }
                let docs: [Income] = snapshot?.documents.compactMap { doc -> Income? in
                    do {
                        return try doc.data(as: Income.self)
                    } catch {
                        print("Failed to decode income \(doc.documentID): \(error)")
                        return nil
                    }
                } ?? []
                self.incomes = docs.sorted { $0.date > $1.date }
                self.isLoading = false
            }
    }
    
    func addIncome(forUserId userId: String, income: Income, completion: ((Error?) -> Void)? = nil) {
        do {
            let _ = try db.collection("users").document(userId).collection("incomes").addDocument(from: income) { error in
                completion?(error)
            }
        } catch {
            completion?(error)
        }
    }
    
    func deleteIncome(forUserId userId: String, incomeId: String, completion: ((Error?) -> Void)? = nil) {
        db.collection("users").document(userId).collection("incomes").document(incomeId).delete { error in
            completion?(error)
        }
    }
} 
