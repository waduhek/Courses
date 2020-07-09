import SwiftUI

struct AllCourses: View {
    @State private var showLoading: Bool = false
    @State private var courses: [Course] = []
    
    var body: some View {
        ZStack {
            if self.showLoading {
                ActivityIndicator(isAnimating: self.$showLoading, activityIndicatorStyle: .large)
            }
            
            if !self.showLoading {
                List {
                    ForEach(self.courses) { course in
                        Text(course.name)
                    }
                }
                .disabled(self.showLoading)
            }
        }
        .onAppear {
            self.showLoading = true
            
            var urlRequest = URLRequest(url: URL(string:"http://192.168.1.127:8080/api/teacher/course/all/")!)
            urlRequest.httpMethod = "GET"
            
            dataTaskWithURLRequest(urlRequest) { (data, response, _) in
                switch response.statusCode {
                    case 200:
                        self.courses = decodeJSON(data: data)
                        self.showLoading = false
                    default:
                        fatalError("[AllCourses] - Could not get courses.")
                }
            }
        }
    }
}

struct AllCourses_Previews: PreviewProvider {
    static var previews: some View {
        AllCourses()
    }
}
