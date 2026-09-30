import SwiftUI

struct LaunchesFiltersView: View {
    @Binding var filters: LaunchesList.Filters
    @Environment(\.dismiss) var dismiss

    let hasActiveFilters: Bool
    let apply: () -> Void
    let clear: () -> Void

    var body: some View {
        NavigationStack {
            List {
                DatePicker(selection: $filters.start, displayedComponents: [.date]) {
                    Text("scree.launch-filter.start.title")
                }
                DatePicker(selection: $filters.end, displayedComponents: [.date]) {
                    Text("scree.launch-filter.start.title")
                }
            }.toolbar {
                if hasActiveFilters {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .destructive) { clear() }
                    }
                } else {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel) { dismiss() }
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(role: .confirm) { apply() }
                }
            }
            .navigationTitle("screen.launch-filter.title")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}
