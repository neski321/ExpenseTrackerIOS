import Foundation
import FirebaseFirestore
import Combine

struct IncomeSource: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var icon: String?
    var iconOrDefault: String { icon ?? "briefcase" }
}

class IncomeSourceService: ObservableObject {
    @Published var sources: [IncomeSource] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    
    func fetchIncomeSources(forUserId userId: String) {
        isLoading = true
        error = nil
        listener?.remove()
        listener = db.collection("users").document(userId).collection("incomeSources")
            .addSnapshotListener { [weak self] snapshot, err in
                guard let self = self else { return }
                if let err = err {
                    print("Firestore error: \(err.localizedDescription)")
                    self.error = err.localizedDescription
                    self.isLoading = false
                    return
                }
                let docs: [IncomeSource] = snapshot?.documents.compactMap { doc -> IncomeSource? in
                    do {
                        return try doc.data(as: IncomeSource.self)
                    } catch {
                        print("Failed to decode income source \(doc.documentID): \(error)")
                        return nil
                    }
                } ?? []
                self.sources = docs.sorted { $0.name < $1.name }
                self.isLoading = false
            }
    }
    
    func addIncomeSource(forUserId userId: String, source: IncomeSource, completion: ((Error?) -> Void)? = nil) {
        do {
            let _ = try db.collection("users").document(userId).collection("incomeSources").addDocument(from: source) { error in
                completion?(error)
            }
        } catch {
            completion?(error)
        }
    }
    
    func deleteIncomeSource(forUserId userId: String, sourceId: String, completion: ((Error?) -> Void)? = nil) {
        db.collection("users").document(userId).collection("incomeSources").document(sourceId).delete { error in
            completion?(error)
        }
    }
} 
