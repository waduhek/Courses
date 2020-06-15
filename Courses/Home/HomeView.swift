import SwiftUI

struct HomeView: View {
    @Binding var hideNavigationBar: Bool
    @EnvironmentObject var userSession: UserSession
    // MARK: View states
    @State private var showLoginView: Int? = 0
    @State private var logoutPressed: Bool = false
     // A binding to show the loading view.
    private var showLoading: Binding<Bool> {
        Binding(
            get: { self.userSession.status == .unknown && self.logoutPressed },
            set: { _ in }
        )
    }
    
    var body: some View {
        LoadingView(
            showLoading: self.showLoading,
            onDisappearHandler: {
                if self.userSession.status == .authorised {
                    self.showLoginView = 1
                }
                else {
                    self.logoutPressed = false
                }
            }
        ) {
            VStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Hello, \(self.userSession.firstName)")
                    Text("Session ID: \(self.userSession.sessionID)")
                    Text("Session Exp: \(self.userSession.sessionExpiryDate)")
                }
                
                Spacer()
                
                NavigationLink(
                    destination: LoginView(),
                    tag: 1,
                    selection: self.$showLoginView
                ) {
                    EmptyView()
                }
                
                Button(
                    action: {
                        self.logoutPressed = true
                        
                        // Request a logout.
                        self.userSession.logoutUser()
                    }
                ) {
                    Text("Logout")
                }
                
                Spacer()
            }
        }
        .navigationBarTitle("Test")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.hideNavigationBar = false
            // Reset the status of `userSesison`
            self.userSession.status = .unknown
        }
        .onDisappear {
            self.hideNavigationBar = true
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(hideNavigationBar: .constant(false))
            .environmentObject(UserSession())
    }
}
