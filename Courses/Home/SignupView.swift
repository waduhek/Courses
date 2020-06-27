import SwiftUI

struct SignupView: View {
    @EnvironmentObject var userSession: UserSession
    @Binding var hideNavigationBar: Bool
    
    // MARK: Text field and password field states.
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    // MARK: Show password states.
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    // MARK: Alert related states.
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    // MARK: Button related states.
    @State private var signupPressed: Bool = false
    // MARK: Account type related states and variables.
    @State private var accountTypeSelectionIndex: Int = 0
    private var accountTypes: [String] {
        return ["Student", "Teacher"]
    }
    // MARK: Navigation related states and bindings.
    @State private var showHomeView: Int? = 0
    private var showLoading: Binding<Bool> {
        Binding(
            get: { (self.userSession.status == .unknown) && self.signupPressed },
            set: { _ in }
        )
    }
    // MARK: Field error states.
    @State private var usernameError: Bool = false
    @State private var passwordError: Bool = false
    @State private var confirmPasswordError: Bool = false
    @State private var emailError: Bool = false
    @State private var firstNameError: Bool = false
    @State private var lastNameError: Bool = false
    
    var body: some View {
        LoadingView(
            showLoading: self.showLoading,
            onDisappearHandler: {
                if self.userSession.status == .authorised {
                    // Sign up was successful, show the home view.
                    self.showHomeView = 1
                }
                else if self.userSession.status == .usernameTaken {
                    // Tell the user that the username is taken.
                    self.alertTitle = "Username Taken."
                    self.alertMessage = "The requested username is taken. Please try again."
                    self.showAlert = true
                }
                else if self.userSession.status == .unauthorised {
                    // Sign up failed. Have the user try again.
                    // Reset the state of the app.
                    self.signupPressed = false
                    self.userSession.status = .unknown
                    
                    // Setup and show an alert to the user.
                    self.alertTitle = "Sign up failed."
                    self.alertMessage = "Please try again."
                    self.showAlert = true
                }
            }
        ) {
            GeometryReader { proxy in
                VStack {
                    // Username field.
                    TextFieldWithDivider(
                        fieldValue: self.$username,
                        showError: self.$usernameError,
                        placeholder: "Username",
                        image: Image(systemName: "person.fill"),
                        textContentType: .username
                    )
                    
                    // Email field.
                    TextFieldWithDivider(
                        fieldValue: self.$email,
                        showError: self.$emailError,
                        placeholder: "Email",
                        image: Image(systemName: "envelope.fill"),
                        textContentType: .emailAddress,
                        keyboardType: .emailAddress
                    )
                    
                    // New password field.
                    PasswordField(
                        password: self.$password,
                        showPassword: self.$showPassword,
                        showError: self.$passwordError,
                        placeholder: "Password",
                        passwordFieldType: .newPassword
                    )
                    
                    // Confirm password field.
                    PasswordField(
                        password: self.$confirmPassword,
                        showPassword: self.$showConfirmPassword,
                        showError: self.$confirmPasswordError,
                        placeholder: "Confirm Password",
                        passwordFieldType: .password
                    )
                    
                    // First name field.
                    TextFieldWithDivider(
                        fieldValue: self.$firstName,
                        showError: self.$firstNameError,
                        placeholder: "First Name",
                        image: Image(systemName: "person.fill"),
                        textContentType: .name
                    )
                    
                    // Last name field.
                    TextFieldWithDivider(
                        fieldValue: self.$lastName,
                        showError: self.$lastNameError,
                        placeholder: "Last Name",
                        image: Image(systemName: "person.fill"),
                        textContentType: .familyName
                    )
                    
                    // Account type picker.
                    VStack(alignment: .leading) {
                        Text("Register as")
                        Picker(selection: self.$accountTypeSelectionIndex, label: Text("Account Type")) {
                            ForEach(0..<self.accountTypes.count) { i in
                                Text(self.accountTypes[i]).tag(i)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Hidden navigation link.
                    NavigationLink(
                        destination: HomeView(hideNavigationBar: self.$hideNavigationBar),
                        tag: 1, selection: self.$showHomeView
                    ) {
                        EmptyView()
                    }
                    
                    Spacer()
                    
                    // Sign up button.
                    Button(
                        action: {
                            // Perform basic field validation before sending a request.
                            // Check if any of the fields is empty.
                            if (self.username.count == 0 || self.password.count == 0 ||
                                self.confirmPassword.count == 0  || self.email.count == 0 ||
                                self.firstName.count == 0 || self.lastName.count == 0) {
                                
                                self.alertTitle = "Empty field(s)."
                                self.alertMessage = "Please fill in the empty fields."
                                
                                // Check if the username field is filled in
                                if self.username.count == 0 {
                                    self.usernameError = true
                                }
                                
                                // Check which field is empty.
                                if self.password.count == 0 {
                                    self.passwordError = true
                                }
                                
                                if self.confirmPassword.count == 0 {
                                    self.confirmPasswordError = true
                                }
                                
                                // Check if email field is empty.
                                if self.email.count == 0 {
                                    self.emailError = true
                                }
                                
                                // Check if first name field is empty.
                                if self.firstName.count == 0 {
                                    self.firstNameError = true
                                }
                                    
                                if self.lastName.count == 0 {
                                    self.lastNameError = true
                                }
                                
                                self.showAlert = true
                            }
                            // Check if both the password field match.
                            else if self.password != self.confirmPassword {
                                self.alertTitle = "Invalid fields."
                                self.alertMessage = "The password fields do not match"
                                self.showAlert = true
                            }
                            // Everything is ok. Proceed to sending sign up request to server.
                            else {
                                // Signal that the button is tapped.
                                self.signupPressed = true
                                
                                var isTeacher: Bool {
                                    if self.accountTypes[self.accountTypeSelectionIndex].lowercased() == "teacher" {
                                        return true
                                    }
                                    else {
                                        return false
                                    }
                                }
                                
                                let userCredentials = UserSignup(
                                    firstName: self.firstName, lastName: self.lastName,
                                    username: self.username, email: self.email,
                                    password: self.password, confirmPassword: self.confirmPassword,
                                    isTeacher: isTeacher
                                )
                                
                                self.userSession.signupUser(userCredentials: userCredentials)
                            }
                        }
                    ) {
                        Text("Sign Up")
                            .frame(width: proxy.size.width * 0.8)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(Color.white)
                            .cornerRadius(30)
                    }
                    .padding(.bottom, 15)
                }
                .padding(.all)
                .navigationBarTitle("Sign Up")
                .navigationBarHidden(self.hideNavigationBar)
                .onAppear {
                    self.hideNavigationBar = false
                }
                .onDisappear {
                    self.hideNavigationBar = true
                }
            }
        }
        // General purpose alert.
        .alert(isPresented: self.$showAlert) {
            Alert(
                title: Text(self.alertTitle),
                message: Text(self.alertMessage)
            )
        }
    }
}

// MARK:- Preview.
struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(hideNavigationBar: .constant(false))
            .environmentObject(UserSession())
    }
}
