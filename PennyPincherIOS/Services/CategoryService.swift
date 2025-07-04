import Foundation
import FirebaseFirestore
import Combine

struct Category: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var parentId: String?
    var icon: String?
    var color: String?
    var iconOrDefault: String { icon ?? "folder" }
}

class CategoryService: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    
    func fetchCategories(forUserId userId: String) {
        isLoading = true
        error = nil
        listener?.remove()
        listener = db.collection("users").document(userId).collection("categories")
            .addSnapshotListener { [weak self] snapshot, err in
                guard let self = self else { return }
                if let err = err {
                    print("Firestore error: \(err.localizedDescription)")
                    self.error = err.localizedDescription
                    self.isLoading = false
                    return
                }
                let docs: [Category] = snapshot?.documents.compactMap { doc -> Category? in
                    do {
                        return try doc.data(as: Category.self)
                    } catch {
                        print("Failed to decode category \(doc.documentID): \(error)")
                        return nil
                    }
                } ?? []
                self.categories = docs.sorted { $0.name < $1.name }
                self.isLoading = false
            }
    }
    
    func addCategory(forUserId userId: String, category: Category, completion: ((Error?) -> Void)? = nil) {
        do {
            let _ = try db.collection("users").document(userId).collection("categories").addDocument(from: category) { error in
                completion?(error)
            }
        } catch {
            completion?(error)
        }
    }
    
    func deleteCategory(forUserId userId: String, categoryId: String, completion: ((Error?) -> Void)? = nil) {
        db.collection("users").document(userId).collection("categories").document(categoryId).delete { error in
            completion?(error)
        }
    }
} 
