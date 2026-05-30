import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: SpoonieStore

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.spoonieBackground.ignoresSafeArea()

            Group {
                switch store.selectedTab {
                case .today:
                    if store.generationStatus == .loading {
                        GeneratingDeclarationView()
                    } else if let entry = store.todayEntry {
                        DeclarationView(entry: entry)
                    } else {
                        CollectionView()
                    }
                case .drawer:
                    DrawerView()
                case .me:
                    MeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 70)

            SpoonieTabBar(selection: $store.selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
