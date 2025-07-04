import SwiftUI

struct ExpenseRow: View {
    let expense: Expense
    let categoryName: String
    let paymentMethodName: String
    let onDelete: () -> Void
    let onEdit: () -> Void = {}
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(expense.description)
                    .font(.body)
                    .fontWeight(.medium)
                Text(categoryName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 170, alignment: .leading)
            VStack(alignment: .trailing, spacing: 1) {
                Text(String(format: "$%.2f", expense.amount))
                    .font(.headline)
                Text(paymentMethodName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 110, alignment: .trailing)
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.accentColor)
            }
            .frame(width: 40, alignment: .center)
        }
        .padding(.vertical, 6)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
} 
