import Foundation
import SwiftUI

/// A function to fetch all the courses that this teacher has / is teaching.
func getAllCourses() -> [Course] {
    // Creating a `URLRequest` object.
    var urlRequest = URLRequest(
        url: URL(string: "http://192.168.1.127:8080/api/teacher/courses/all")!
    )
    // Configuring request parameters.
    urlRequest.httpMethod = "GET"
    
    // Received array of `Courses` object.
    var courses: [Course]
    
    let (data, response, _) = syncDataTaskWithURLRequest(urlRequest)
    
    switch response.statusCode {
    case 200:
        courses = decodeJSON(data: data)
    default:
        fatalError("[Teacher/AllCourses] - Unexpected status code.")
    }
    
    return courses
}
