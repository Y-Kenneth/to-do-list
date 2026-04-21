import SwiftUI
import Firebase

@main
struct to_do_listApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isSignedIn {
                    ContentView(authViewModel: authViewModel)
                } else {
                    LoginView(authViewModel: authViewModel)
                }
            }
            .animation(.easeInOut, value: authViewModel.isSignedIn)
        }
    }
}
