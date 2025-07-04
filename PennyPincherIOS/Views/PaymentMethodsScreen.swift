import SwiftUI

struct PaymentMethodsScreen: View {
    let userId: String
    @StateObject private var paymentMethodService = PaymentMethodService()
    @State private var showAddMethod = false
    @State private var methodToDelete: PaymentMethod? = nil
    @State private var showDeleteConfirm: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Manage Payment Methods")
                    .font(.title).bold()
                Text("Add, edit, or remove your payment methods.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer().frame(height: 12)
                if paymentMethodService.isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView("Loading payment methods..."); Spacer() }
                    Spacer()
                } else if let error = paymentMethodService.error {
                    Spacer()
                    HStack { Spacer(); Text("Error: \(error)").foregroundColor(.red); Spacer() }
                    Spacer()
                } else if paymentMethodService.methods.isEmpty {
                    Spacer()
                    HStack { Spacer(); Text("No payment methods found.").foregroundColor(.secondary); Spacer() }
                    Spacer()
                } else {
                    List {
                        ForEach(paymentMethodService.methods) { method in
                            PaymentMethodRowView(
                                method: method,
                                onDelete: { deleteMethod(method) }
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddMethod = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddMethod) {
                VStack {
                    Text("Add Payment Method [Placeholder]")
                    Button("Close") { showAddMethod = false }
                }
                .padding()
            }
            .onAppear {
                if !userId.isEmpty {
                    paymentMethodService.fetchPaymentMethods(forUserId: userId)
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete this payment method?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let method = methodToDelete, let id = method.id, !userId.isEmpty {
                        paymentMethodService.deletePaymentMethod(forUserId: userId, methodId: id)
                    }
                    methodToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    methodToDelete = nil
                }
            }
        }
    }
    
    private func deleteMethod(_ method: PaymentMethod) {
        methodToDelete = method
        showDeleteConfirm = true
    }
}

#Preview {
    PaymentMethodsScreen(userId: "demoUserId")
} 