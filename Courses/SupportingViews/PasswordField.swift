import SwiftUI

struct PasswordField: View {
    var placeholder: String
    @Binding var password: String
    @Binding var showPassword: Bool
    var passwordFieldType: UITextContentType
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.primary)
                
                if !self.showPassword {
                    SecureField(self.placeholder, text: self.$password)
                        .textContentType(self.passwordFieldType)
                        .padding(.all)
                        .frame(height: 22)
                }
                else {
                    TextField(self.placeholder, text: self.$password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(self.passwordFieldType)
                        .padding(.all)
                        .frame(height: 22)
                }
                
                Button(action: { self.showPassword.toggle() }) {
                    Image(systemName: self.showPassword ? "eye" : "eye.slash")
                }
            }
            .padding(.vertical, 2)
            
            RectangleDivider()
                .padding(.bottom, 8)
        }
    }
}

struct PasswordField_Previews: PreviewProvider {
    static var previews: some View {
        PasswordField(
            placeholder: "Password",
            password: .constant("lorem"),
            showPassword: .constant(false),
            passwordFieldType: .password
        )
    }
}
