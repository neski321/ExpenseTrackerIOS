import SwiftUI

struct CategoriesScreen: View {
    let userId: String
    @StateObject private var categoryService = CategoryService()
    @State private var expanded: Set<String> = []
    @State private var showAddCategory = false
    @State private var categoryToDelete: Category? = nil
    @State private var showDeleteConfirm: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Manage Categories")
                    .font(.title).bold()
                Text("Organize your expenses by creating and managing categories and sub-categories.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer().frame(height: 12)
                if categoryService.isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView("Loading categories..."); Spacer() }
                    Spacer()
                } else if let error = categoryService.error {
                    Spacer()
                    HStack { Spacer(); Text("Error: \(error)").foregroundColor(.red); Spacer() }
                    Spacer()
                } else if categoryService.categories.isEmpty {
                    Spacer()
                    HStack { Spacer(); Text("No categories found.").foregroundColor(.secondary); Spacer() }
                    Spacer()
                } else {
                    List {
                        ForEach(parentCategories, id: \.id) { parent in
                            Section {
                                CategoryRowView(
                                    category: parent,
                                    isParent: true,
                                    isExpanded: expanded.contains(parent.id ?? ""),
                                    onExpandToggle: {
                                        toggleExpand(parent.id)
                                    },
                                    onDelete: {
                                        deleteCategory(parent)
                                    },
                                    hasChildren: hasChildren(parent)
                                )
                                if expanded.contains(parent.id ?? "") {
                                    ForEach(childCategories(parentId: parent.id), id: \.id) { child in
                                        CategoryRowView(
                                            category: child,
                                            isParent: false,
                                            isExpanded: false,
                                            onExpandToggle: {},
                                            onDelete: {
                                                deleteCategory(child)
                                            }
                                        )
                                        .padding(.leading, 32)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCategory = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                VStack {
                    Text("Add Category [Placeholder]")
                    Button("Close") { showAddCategory = false }
                }
                .padding()
            }
            .onAppear {
                categoryService.fetchCategories(forUserId: userId)
            }
            .confirmationDialog(
                "Are you sure you want to delete this category?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete, let id = category.id {
                        categoryService.deleteCategory(forUserId: userId, categoryId: id)
                    }
                    categoryToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    categoryToDelete = nil
                }
            }
        }
    }
    
    private var parentCategories: [Category] {
        categoryService.categories.filter { $0.parentId == nil }
    }
    private func childCategories(parentId: String?) -> [Category] {
        categoryService.categories.filter { $0.parentId == parentId }
    }
    private func toggleExpand(_ id: String?) {
        guard let id = id else { return }
        if expanded.contains(id) {
            expanded.remove(id)
        } else {
            expanded.insert(id)
        }
    }
    private func deleteCategory(_ category: Category) {
        categoryToDelete = category
        showDeleteConfirm = true
    }
    private func hasChildren(_ category: Category) -> Bool {
        guard let id = category.id else { return false }
        return categoryService.categories.contains { $0.parentId == id }
    }
}

#Preview {
    CategoriesScreen(userId: "demoUserId")
} 