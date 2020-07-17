import SwiftUI

struct CourseDetail: View {
    @ObservedObject var courseProvider: CourseDetailProvider
    @Binding var hideNavigationBar: Bool
    
    private var isLoading: Binding<Bool> {
        Binding(
            get: { self.courseProvider.isLoading },
            set: { _ in }
        )
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading) {
                    // Header for this course.
                    HStack(alignment: .top) {
                        // Course detail image.
                        self.courseProvider.course.image
                            .resizable()
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
                    .padding()
                    
                    Group {
                        Text("Videos")
                            .font(.caption)
                            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                            .background(Color.gray.opacity(0.4))
                    }
                    
                    // Videos subview.
                    LoadingView(showLoading: self.isLoading, onDisappearHandler: {}) {
                        ForEach(self.courseProvider.course.videos, id: \.id) { video in
                            NavigationLink(
                                destination: EmptyView()
                            ) {
                                VStack {
                                    HStack {
                                        Image(systemName: "play.circle")
                                        Text(video.title)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
        
                                        Spacer()
        
                                        Text("13:45")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    
                                    Divider()
                                        .padding(.leading)
                                        .edgesIgnoringSafeArea(.trailing)
                                }
                            }
                        }
                        .disabled(self.isLoading.wrappedValue)
                    }
                }
            }
        }
        .onAppear {
            // Unhide the navigation bar.
            self.hideNavigationBar = false
            
            // Load the course from the provider.
            self.courseProvider.loadCourse()
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
