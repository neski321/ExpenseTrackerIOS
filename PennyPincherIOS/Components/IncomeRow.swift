import SwiftUI

struct IncomeRow: View {
    let income: Income
    let sourceName: String
    let onDelete: () -> Void
    var body: some View {
        HStack {
            Text(income.date, style: .date).frame(maxWidth: .infinity, alignment: .leading)
            Text(sourceName).frame(maxWidth: .infinity, alignment: .leading)
            Text(String(format: "$%.2f", income.amount)).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.subheadline)
        .padding(.vertical, 2)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
} 