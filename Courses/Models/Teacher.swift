import Foundation
import SwiftUI

/// A function to fetch all the courses that this teacher has / is teaching.
func getAllCourses() -> [CourseSummary] {
    // Creating a `URLRequest` object.
    guard let url = URL(string: "http://192.168.1.127:8080/api/teacher/courses/all") else {
        fatalError("[Teacher/AllCourses] - Could not construct URL.")
    }
    
    var urlRequest = URLRequest(url: url)
    // Configuring request parameters.
    urlRequest.httpMethod = "GET"
    
    // Received array of `Courses` object.
    var courses: [CourseSummary]
    
    let (data, response, _) = syncDataTaskWithURLRequest(urlRequest)
    
    switch response.statusCode {
    case 200:
        courses = decodeJSON(data: data)
    default:
        fatalError("[Teacher/AllCourses] - Unexpected status code.")
    }
    
    return courses
}
