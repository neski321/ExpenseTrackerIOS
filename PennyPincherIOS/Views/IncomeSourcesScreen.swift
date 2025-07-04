import SwiftUI

struct IncomeSourcesScreen: View {
    let userId: String
    @StateObject private var incomeSourceService = IncomeSourceService()
    @State private var showAddSource = false
    @State private var sourceToDelete: IncomeSource? = nil
    @State private var showDeleteConfirm: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Manage Income Sources")
                    .font(.title).bold()
                Text("Add, edit, or remove your income sources.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer().frame(height: 12)
                if incomeSourceService.isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView("Loading income sources..."); Spacer() }
                    Spacer()
                } else if let error = incomeSourceService.error {
                    Spacer()
                    HStack { Spacer(); Text("Error: \(error)").foregroundColor(.red); Spacer() }
                    Spacer()
                } else if incomeSourceService.sources.isEmpty {
                    Spacer()
                    HStack { Spacer(); Text("No income sources found.").foregroundColor(.secondary); Spacer() }
                    Spacer()
                } else {
                    List {
                        ForEach(incomeSourceService.sources) { source in
                            IncomeSourceRowView(
                                source: source,
                                onDelete: { deleteSource(source) }
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
                    Button(action: { showAddSource = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSource) {
                VStack {
                    Text("Add Income Source [Placeholder]")
                    Button("Close") { showAddSource = false }
                }
                .padding()
            }
            .onAppear {
                incomeSourceService.fetchIncomeSources(forUserId: userId)
            }
            .confirmationDialog(
                "Are you sure you want to delete this income source?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let source = sourceToDelete, let id = source.id {
                        incomeSourceService.deleteIncomeSource(forUserId: userId, sourceId: id)
                    }
                    sourceToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    sourceToDelete = nil
                }
            }
        }
    }
    
    private func deleteSource(_ source: IncomeSource) {
        sourceToDelete = source
        showDeleteConfirm = true
    }
}

#Preview {
    IncomeSourcesScreen(userId: "demoUserId")
} 