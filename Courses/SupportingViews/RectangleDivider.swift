import SwiftUI

struct RectangleDivider: View {
    var height: CGFloat = 0.5
    var colour: Color = .primary
    
    var body: some View {
        Rectangle()
            .fill(self.colour)
            .frame(height: self.height)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct RectangleDivider_Previews: PreviewProvider {
    static var previews: some View {
        RectangleDivider(height: 1, colour: .blue)
    }
}
