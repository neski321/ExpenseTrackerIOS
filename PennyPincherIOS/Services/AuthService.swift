import Foundation
import FirebaseAuth
import Combine

class AuthService: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, err in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let err = err {
                    self?.error = err.localizedDescription
                    completion(false)
                } else {
                    self?.user = result?.user
                    completion(true)
                }
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, err in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let err = err {
                    self?.error = err.localizedDescription
                    completion(false)
                } else {
                    self?.user = result?.user
                    completion(true)
                }
            }
        }
    }
    
    func sendPasswordReset(email: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] err in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let err = err {
                    self?.error = err.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    var userId: String? {
        user?.uid
    }
} 