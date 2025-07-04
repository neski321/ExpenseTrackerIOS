import Foundation
import FirebaseFirestore
import Combine

struct PaymentMethod: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
}

class PaymentMethodService: ObservableObject {
    @Published var methods: [PaymentMethod] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    
    func fetchPaymentMethods(forUserId userId: String) {
        isLoading = true
        error = nil
        listener?.remove()
        listener = db.collection("users").document(userId).collection("paymentMethods")
            .addSnapshotListener { [weak self] snapshot, err in
                guard let self = self else { return }
                if let err = err {
                    print("Firestore error: \(err.localizedDescription)")
                    self.error = err.localizedDescription
                    self.isLoading = false
                    return
                }
                let docs: [PaymentMethod] = snapshot?.documents.compactMap { doc -> PaymentMethod? in
                    do {
                        return try doc.data(as: PaymentMethod.self)
                    } catch {
                        print("Failed to decode payment method \(doc.documentID): \(error)")
                        return nil
                    }
                } ?? []
                self.methods = docs.sorted { $0.name < $1.name }
                self.isLoading = false
            }
    }
    
    func addPaymentMethod(forUserId userId: String, method: PaymentMethod, completion: ((Error?) -> Void)? = nil) {
        do {
            let _ = try db.collection("users").document(userId).collection("paymentMethods").addDocument(from: method) { error in
                completion?(error)
            }
        } catch {
            completion?(error)
        }
    }
    
    func deletePaymentMethod(forUserId userId: String, methodId: String, completion: ((Error?) -> Void)? = nil) {
        db.collection("users").document(userId).collection("paymentMethods").document(methodId).delete { error in
            completion?(error)
        }
    }
} 
