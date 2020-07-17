import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    var activityIndicatorStyle: UIActivityIndicatorView.Style
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: self.activityIndicatorStyle)
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        self.isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator(isAnimating: .constant(true), activityIndicatorStyle: .medium)
    }
}
