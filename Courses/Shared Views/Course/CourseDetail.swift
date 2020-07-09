import SwiftUI

struct CourseDetail: View {
//    @Binding var courseName: String
//    @Binding var courseImage: Image
    
    @State var courseVideos: [CourseVideo] = []
    @State var teacher: String = ""
    
    var body: some View {
        GeometryReader { proxy in
            List {
                Group {
                    // Header for this course.
                    HStack(alignment: .top) {
                        // Course detail image.
                        Image("defaultPhoto", bundle: Bundle.main)
                            .resizable()
                            .frame(
                                width: proxy.size.width * 0.33,
                                height: proxy.size.width * 0.33
                            )
                            .shadow(radius: 5)
                            .padding(.trailing)
                            
                        
                        // Course title and professor name.
                        VStack(alignment: .leading) {
                            Text("Advanced Machine Learning")
                                .font(.headline)
                                .padding(.bottom, proxy.size.width * 0.1)
                                .lineLimit(3)
                                .truncationMode(.tail)
                            
                            Text(self.teacher)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical)
                
                Group {
                    ForEach(self.courseVideos) { video in
                        NavigationLink(
                            destination: EmptyView()
                        ) {
                            HStack {
                                Image(systemName: "play.circle")
                                Text(video.title)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                                Spacer()
                                
                                Text("\(video.duration)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Course")
        .onAppear {
            // Get the list of all videos from the server just before this screen loads.
            let (data, response, _) = syncDataTaskWithURLRequest(
                // MARK: TODO: Finalise the URL.
                URLRequest(url: URL(string: "192.168.1.127:8080/api/")!)
            )
            
            switch response.statusCode {
            case 200:
                print("OK!")
            default:
                fatalError("[Course/Detail] - Could not fetch course video information.")
            }
        }
    }
}

struct CourseDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CourseDetail()
        }
    }
}
