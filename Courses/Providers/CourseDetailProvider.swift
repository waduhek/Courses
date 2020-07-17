import Foundation

final class CourseDetailProvider: ObservableObject {
    @Published var course: Course = Course()
    @Published var isLoading: Bool = false
    private let courseID: UInt
    private let url: URL
    
    init(courseID: UInt) {
        self.courseID = courseID
        
        guard let url = URL(
            string: "http://192.168.1.127:8080/api/course/detail/\(self.courseID)/"
        ) else {
                fatalError("[Course/Detail] - Could not construct URL.")
        }
        
        self.url = url
    }
    
    func loadCourse() {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        // Indicate the beginning of the data task.
        self.isLoading = true

        dataTaskWithURLRequest(urlRequest) { (data, response, _) in
            switch response.statusCode {
            case 200:
                DispatchQueue.main.async {
                    self.course = decodeJSON(data: data)
                }
                print("\(self.course.videos.count)")

                // Indicate end of loading.
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                    
            default:
                fatalError("[Course/Detail] - Could not fetch course video information.")
            }
        }
    }
}
