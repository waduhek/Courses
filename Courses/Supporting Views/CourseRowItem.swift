import SwiftUI
import UIKit.UIScreen

struct CourseRowItem: View {
    @LengthLimitedString var courseName = "Lorem Lorem Lorem Lorem Lorem Lorem Lorem Lorem "
    var photo = Image("defaultPhoto", bundle: Bundle.main)
    
    var body: some View {
        VStack(alignment: .leading) {
            self.photo
                .renderingMode(.original)
                .resizable()
                .frame(width: UIScreen.main.bounds.width * 0.42, height: UIScreen.main.bounds.width * 0.42)
                .cornerRadius(5)
            
            Text(self.courseName)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.leading, 15)
    }
}

struct CourseRowItem_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CourseRowItem()
        }
    }
}

// MARK: - LengthLimitedString property wrapper.

@propertyWrapper
struct LengthLimitedString {
    private var string: String
    private var maxLength: Int
    
    var wrappedValue: String {
        set { self.string = newValue }
        get {
            var validString: String?
            // Make sure that the lenght of the line does not exceed `maxLength`.
            if self.string.count > self.maxLength {
                // Truncate the line to contain `maxLength - 3` characters.
                validString = String(self.string.prefix(self.maxLength - 3))
                // Fill in the remaining space with an ellipsis.
                validString!.append("...")
            }
            
            return validString ?? self.string
        }
    }
    
    init() {
        self.string = ""
        self.maxLength = 25
    }
    
    init(wrappedValue: String) {
        self.string = wrappedValue
        self.maxLength = 25
    }
    
    init(wrappedValue: String, maxLength: Int) {
        self.string = wrappedValue
        self.maxLength = maxLength
    }
}
