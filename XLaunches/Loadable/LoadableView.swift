import SwiftUI

struct LoadableView<Content, ContentView: View>: View {
    let loadable: Loadable<Content>
    @ViewBuilder let content: (Content) -> ContentView

    var body: some View {
        ZStack {
            switch loadable {
            case .initial:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded(let content):
                self.content(content)
            case .failed(let error, let retry):
                ContentUnavailableView {
                    Label {
                        Text("screen.unavailable.title")
                    } icon: {
                        Image(systemName: "wand.and.rays", variableValue: 0)
                            .symbolEffect(.variableColor.reversing)
                    }
                } description: {
                    Text(error.localizedDescription)
                } actions: {
                    Button("screen.unavailable.button.retry") { Task { await retry() } }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

#Preview {
    LoadableView<String, EmptyView>(
        loadable: .failed(NSError(domain: "com.test", code: 100), retry: {}),
        content: { _ in EmptyView() }
    )
}
