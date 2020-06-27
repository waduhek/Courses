import SwiftUI

struct PasswordField: View {
    @Binding var password: String
    @Binding var showPassword: Bool
    @Binding var showError: Bool
    var placeholder: String
    var passwordFieldType: UITextContentType
    var dividerColour: Color = .primary
    var dividerHeight: CGFloat = 0.5
    var dividerErrorColour: Color = .red
    var dividerErrorHeight: CGFloat = 1
    
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
            
            RectangleDivider(
                showError: self.$showError,
                colour: self.dividerColour,
                height: self.dividerHeight,
                errorColour: self.dividerErrorColour,
                errorHeight: self.dividerErrorHeight
            )
                .padding(.bottom, 8)
        }
    }
}

struct PasswordField_Previews: PreviewProvider {
    static var previews: some View {
        PasswordField(
            password: .constant("lorem"),
            showPassword: .constant(false),
            showError: .constant(false),
            placeholder: "Password",
            passwordFieldType: .password
        )
    }
}
