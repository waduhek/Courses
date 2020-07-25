import SwiftUI

struct CourseDetail: View {
    @EnvironmentObject var userSession: UserSession
    @ObservedObject var courseProvider: CourseDetailProvider
    @Binding var hideNavigationBar: Bool
    @State private var truncateDescription: Bool = true
    
    private var isLoading: Binding<Bool> {
        Binding(
            get: { self.courseProvider.isLoading },
            set: { _ in }
        )
    }
    
    var body: some View {
        LoadingView(showLoading: self.isLoading, onDisappearHandler: {}) {
            GeometryReader { proxy in
                List {
                    // Course header.
                    Section {
                        HStack(alignment: .top) {
                            // Course detail image.
                            self.courseProvider.course.image
                                .resizable()
                                .renderingMode(.original)
                                .frame(
                                    width: proxy.size.width * 0.33,
                                    height: proxy.size.width * 0.33
                                )
                                .shadow(radius: 5)
                                .padding(.trailing)
                        
                            
                            // Course title and professor name.
                            VStack(alignment: .leading) {
                                Text(self.courseProvider.course.name)
                                    .font(.headline)
                                    .padding(.bottom, proxy.size.width * 0.1)
                                    .lineLimit(3)
                                    .truncationMode(.tail)
                        
                                Text(self.courseProvider.course.teachers.first ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Course description.
                    Section(
                        header: Text("Description")
                            .font(.caption)
                    ) {
                        HStack(alignment: .center) {
                            Text(self.courseProvider.course.description)
                                .lineLimit(self.truncateDescription ? 1 : nil)
                            
                            Spacer()
                            
                            VStack(alignment: .center) {
                                Image(systemName: "chevron.up")
                                    .foregroundColor(.gray)
                                    .rotationEffect(self.truncateDescription ? Angle(degrees: 0) : Angle(degrees: 180))
                                
                                Spacer()
                            }
                        }
                        .gesture(
                            TapGesture()
                                .onEnded {
                                    withAnimation {
                                        self.truncateDescription.toggle()
                                    }
                            }
                        )
                    }
                    
                    // Course videos.
                    Section(
                        header: Text("Videos")
                            .font(.caption)
                    ) {
                        ForEach(self.courseProvider.course.videos, id: \.id) { video in
                            NavigationLink(
                                destination: EmptyView()
                            ) {
                                HStack {
                                    Image(systemName: "play.circle")
                                    Text(video.title)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    
                                    Spacer()
                                    
                                    Text("13:45")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .disabled(self.isLoading.wrappedValue)
        .onAppear {
            // Unhide the navigation bar.
            self.hideNavigationBar = false
        }
        .navigationBarTitle("Course", displayMode: .inline)
    }
}

struct CourseDetail_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            CourseDetail(
                courseProvider: CourseDetailProvider(courseID: 1),
                hideNavigationBar: .constant(false)
            )
        }
    }
}
