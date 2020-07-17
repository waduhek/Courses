import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var userSession: UserSession
    
    // MARK: HACK: Really horrible method to hide the navigation bar. Change it ASAP.
    @State private var hideNavigationBar: Bool = false
    
    var body: some View {
        Group {
            if self.userSession.sessionID.isEmpty {
                NavigationView {
                    LoginView(hideNavigationBar: self.$hideNavigationBar)
                        .navigationBarHidden(self.hideNavigationBar)
                }
            }
            else {
                NavigationView {
//                    AllCourses(hideNavigationBar: self.$hideNavigationBar)
                    CourseDetail(
                        courseProvider: CourseDetailProvider(courseID: 1),
                        hideNavigationBar: self.$hideNavigationBar
                    )
                        .navigationBarHidden(self.hideNavigationBar)
                }
            }
        }
    }
}

struct AppRootView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView()
            .environmentObject(UserSession())
    }
}
