import SwiftUI

struct TextFieldWithDivider: View {
    @Binding var fieldValue: String
    var placeholder: String
    var dividerColour: Color = .primary
    var dividerHeight: CGFloat = 0.5
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
            
            RectangleDivider(height: self.dividerHeight, colour: self.dividerColour)
                .padding(.bottom, 8)
        }
    }
}

struct TextFieldWithDivider_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldWithDivider(
            fieldValue: .constant(""),
            placeholder: "Test",
            dividerColour: .primary,
            image: Image(systemName: "person.fill"),
            textContentType: .emailAddress,
            keyboardType: .emailAddress
        )
    }
}
