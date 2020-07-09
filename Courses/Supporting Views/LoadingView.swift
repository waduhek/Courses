import SwiftUI

struct LoadingView<Content: View>: View {
    @Binding var showLoading: Bool
    var onDisappearHandler: () -> Void
    var content: () -> Content
    
    init(showLoading: Binding<Bool>,
         onDisappearHandler: @escaping () -> Void,
         @ViewBuilder content: @escaping () -> Content
    ) {
        self._showLoading = showLoading
        self.onDisappearHandler = onDisappearHandler
        self.content = content
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                self.content()
                    .disabled(self.showLoading)
                
                if self.showLoading {
                    ActivityIndicator(isAnimating: self.$showLoading, activityIndicatorStyle: .large)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .background(
                            Color(red: 182 / 255, green: 182 / 255, blue: 182 / 255)
                        )
                        .opacity(self.showLoading ? 0.5 : 0)
                        .onDisappear(perform: self.onDisappearHandler)
                }
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(
            showLoading: .constant(true),
            onDisappearHandler: {}
        ) {
            List {
                ForEach(0..<50) { item in
                    Text("Item \(item)")
                }
            }
        }
    }
}
