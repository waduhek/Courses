import SwiftUI

struct CourseRow: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Type")
                .padding(.top, 5)
                .padding(.leading, 15)
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(0..<7) { _ in
                        NavigationLink(destination: EmptyView()) {
                            CourseRowItem()
                        }
                    }
                }
            }
            .frame(height: 185)
        }
    }
}

struct CourseRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CourseRow()
        }
    }
}
