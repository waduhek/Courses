import SwiftUI

struct AllCourses: View {
    @Binding var hideNavigationBar: Bool
    
    @State private var showLoading: Bool = false
    @State private var courses: [CourseSummary] = []
    
    var body: some View {
        LoadingView(showLoading: self.$showLoading, onDisappearHandler: {}) {
            List {
                ForEach(self.courses) { course in
                    Text(course.name)
                }
            }
            .disabled(self.showLoading)
        }
        .onAppear {
            // Show the navigation bar.
            self.hideNavigationBar = false
            
            // Indicate the start of the network activity.
            self.showLoading = true
            
            // Fetching all the courses for this teacher from the server.
            var urlRequest = URLRequest(url: URL(string:"http://192.168.1.127:8080/api/teacher/course/all/")!)
            urlRequest.httpMethod = "GET"
            
            dataTaskWithURLRequest(urlRequest) { (data, response, _) in
                switch response.statusCode {
                case 200:
                    DispatchQueue.main.async {
                        self.courses = decodeJSON(data: data)
                        self.showLoading = false
                    }
                default:
                    fatalError("[AllCourses] - Could not get courses.")
                }
            }
        }
        .navigationBarTitle("All Courses")
    }
}

struct AllCourses_Previews: PreviewProvider {
    static var previews: some View {
        AllCourses(hideNavigationBar: .constant(false))
    }
}
