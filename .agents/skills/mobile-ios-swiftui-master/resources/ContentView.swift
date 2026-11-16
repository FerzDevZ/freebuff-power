// Production SwiftUI View Component (iOS 17+)
import SwiftUI

struct ContentView: View {
    @State private var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.items, id: \.self) { item in
                Text(item)
                    .font(.body)
            }
            .navigationTitle("Live Feed")
            .task {
                await viewModel.loadFeed()
            }
            .refreshable {
                await viewModel.loadFeed()
            }
        }
    }
}
