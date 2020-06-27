import SwiftUI

struct TextFieldWithDivider: View {
    @Binding var fieldValue: String
    @Binding var showError: Bool
    var placeholder: String
    var dividerColour: Color = .primary
    var dividerErrorColour: Color = .red
    var dividerHeight: CGFloat = 0.5
    var dividerErrorHeight: CGFloat = 1
    var image: Image?
    var textContentType: UITextContentType
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack {
            HStack {
                if self.image != nil {
                    self.image
                }
                
                TextField(self.placeholder, text: self.$fieldValue)
                    .padding(.horizontal)
                    .textContentType(self.textContentType)
                    .keyboardType(self.keyboardType)
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

struct RectangleDivider: View {
    @Binding var showError: Bool
    var colour: Color
    var height: CGFloat
    var errorColour: Color
    var errorHeight: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(self.showError ? self.errorColour : self.colour)
            .frame(height: self.showError ? self.errorHeight : self.height)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct TextFieldWithDivider_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldWithDivider(
            fieldValue: .constant(""),
            showError: .constant(false),
            placeholder: "Test",
            dividerColour: .primary,
            image: Image(systemName: "person.fill"),
            textContentType: .emailAddress,
            keyboardType: .emailAddress
        )
    }
}
