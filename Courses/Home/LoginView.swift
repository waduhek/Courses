import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userSession: UserSession
    
    // MARK: User information related states.
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    // MARK: Buttons and views related states.
    @State private var loginPressed: Bool = false
    @State private var showHomeView: Int? = 0
    // MARK: Alert related states.
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    /* This binding is used to display the loading view when the login button
     * is pressed and the status of the request is `unknown`.
    */
    private var showLoading: Binding<Bool> {
        Binding(
            get: { (self.userSession.status == .unknown) && self.loginPressed },
            set: { _ in }
        )
    }
    // MARK: HACK: Really horrible method to hide the navigation bar. Change it ASAP.
    @State private var hideNavigationBar: Bool = true
    // MARK: Field error states.
    @State private var usernameError: Bool = false
    @State private var passwordError: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            // Master navigation view.
            NavigationView {
                LoadingView(
                    showLoading: self.showLoading,
                    onDisappearHandler: {
                        if self.userSession.status == .authorised {
                            self.showHomeView = 1
                        }
                        else if self.userSession.status == .unauthorised {
                            // Reset the states of the app to allow another login attempt
                            // Set alert message.
                            self.alertTitle = "Login failed"
                            self.alertMessage = "Invalid user credentials."
                            self.showAlert = true
                            
                            self.loginPressed = false
                            self.userSession.status = .unknown
                        }
                    }
                ) {
                    // Enclose all elements of the login page vertically.
                    VStack {
                        Spacer()
                        
                        // Username and password vertical stack.
                        VStack {
                            // Username field.
                            TextFieldWithDivider(
                                fieldValue: self.$username,
                                showError: self.$usernameError,
                                placeholder: "Username",
                                image: Image(systemName: "person.fill"),
                                textContentType: .username
                            )
                            
                            // Password field.
                            PasswordField(
                                password: self.$password,
                                showPassword: self.$showPassword,
                                showError: self.$passwordError,
                                placeholder: "Password",
                                passwordFieldType: .password
                            )
                        }
                        .padding(.bottom, 15)
                        
                        /* MARK: This manner of navigation link is very interesting.
                         * Hidden navigation link. This navigation link will only be
                         * triggered when `showHomeView` becomes 1.
                        */
                        NavigationLink(
                            destination: HomeView(hideNavigationBar: self.$hideNavigationBar),
                            tag: 1,
                            selection: self.$showHomeView
                        ) {
                            EmptyView()
                        }
                        
                        // Login button.
                        Button(
                            action: {
                                // Perfom shome very basic client side validation of the data.
                                // Check if either the username or password field is empty.
                                if self.username.count == 0 || self.password.count == 0 {
                                    // Either of the fields is empty. Set an appropriate title.
                                    self.alertTitle = "Empty Field(s)."
                                    self.alertMessage = "Please enter your credentials."
                                    
                                    // Check if any of the username or password fields are empty.
                                    if self.username.count == 0 {
                                        self.usernameError = true
                                    }
                                    
                                    if self.password.count == 0 {
                                        self.passwordError = true
                                    }
                                    
                                    self.showAlert = true
                                }
                                // Everything is OK. Proceed to login the user.
                                else {
                                    self.loginPressed = true
                                    
                                    let userCredentials = UserCredentials(
                                        username: self.username, password: self.password
                                    )
                                    self.userSession.loginUser(credentials: userCredentials)
                                }
                            }
                        ) {
                            Text("Login")
                                .frame(width: proxy.size.width * 0.8)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(Color.white)
                                .cornerRadius(30)
                        }
                        
                        Spacer()
                        
                        // Signup section.
                        VStack {
                            Text("New to Courses?")
                                .font(.caption)
                            NavigationLink(
                                destination: SignupView(hideNavigationBar: self.$hideNavigationBar)
                            ) {
                                Text("Click here to join!")
                                    .font(.caption)
                                    .padding(.bottom)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                // A general purpose alert for showing any errors during sign in.
                // MARK: TODO: Replace this with more intuitive methods of displaying errors.
                .alert(isPresented: self.$showAlert) {
                    Alert(
                        title: Text(self.alertTitle),
                        message: Text(self.alertMessage)
                    )
                }
                .navigationBarTitle("Login")
                .navigationBarHidden(self.hideNavigationBar)
            }
        }
        .onAppear {
            self.userSession.status = .unknown
            self.hideNavigationBar = true
            
            // Check if the session ID is already set.
            if !self.userSession.sessionID.isEmpty {
                // There is no need to login, proceed to the home view.
                self.showHomeView = 1
            }
        }
    }
}

// MARK:- Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserSession())
    }
}

// MARK:- Subviews
struct ActivityIndicatorOverlay: View {
    var body: some View {
        ActivityIndicator(isAnimating: .constant(true), activityIndicatorStyle: .large)
    }
}
