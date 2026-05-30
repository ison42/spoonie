import SwiftUI

@main
struct SpoonieApp: App {
    @StateObject private var store = SpoonieStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
