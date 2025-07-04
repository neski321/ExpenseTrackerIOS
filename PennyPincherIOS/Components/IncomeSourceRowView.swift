import SwiftUI

struct IncomeSourceRowView: View {
    let source: IncomeSource
    let onDelete: () -> Void
    var body: some View {
        HStack {
            Text(source.name)
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