import SwiftUI

struct CategoryRowView: View {
    let category: Category
    let isParent: Bool
    let isExpanded: Bool
    let onExpandToggle: () -> Void
    let onDelete: () -> Void
    var hasChildren: Bool = false
    
    var body: some View {
        HStack {
            if isParent && hasChildren {
                Button(action: onExpandToggle) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.accentColor)
                }
            } else {
                Spacer().frame(width: 24)
            }
            Text(category.name)
                .font(isParent ? .headline : .body)
            Spacer()
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
} 