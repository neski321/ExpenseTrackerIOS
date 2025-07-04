import SwiftUI

struct PaymentMethodRowView: View {
    let method: PaymentMethod
    let onDelete: () -> Void
    var body: some View {
        HStack {
            Text(method.name)
                .font(.body)
            Spacer()
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
} 