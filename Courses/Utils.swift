// This file defines all utility functions used in this project.

import Foundation

/// Function to decode a `Data` object to a generic type `T` where
/// `T` is a `Decodable`.
/// - Parameter data: The data that has to be decoded.
func decodeJSON<T: Decodable>(data: Data) -> T {
    let decoder = JSONDecoder()
    
    do {
        return try decoder.decode(T.self, from: data)
    }
    catch {
        fatalError("Could not decode data as \(T.self).")
    }
}

/// A utility function that performs an asynchronous data task using `URLSession.shared`.
/// - Parameters:
///     - _: A `URLRequest` object that has the required configuration.
///     - completionHandler: The task to perform after the data task is completed.
func dataTaskWithURLRequest(_ urlRequest: URLRequest,
                            completionHandler: @escaping (Data, HTTPURLResponse, Error?) -> Void) {
    URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        guard error == nil,
            let data = data,
            let response = response as? HTTPURLResponse
            else {
                return
        }
        
        completionHandler(data, response, error)
    }.resume()
}

/// A utility function to perform a synchronous request.
/// - Parameter _: A fully configured `URLRequest` object
func syncDataTaskWithURLRequest(_ urlRequest: URLRequest) -> (Data, HTTPURLResponse, Error?) {
    var returnData: Data = Data()
    var returnResponse: HTTPURLResponse = HTTPURLResponse()
    var returnError: Error?
    
    let semaphore = DispatchSemaphore(value: 0)
    
    let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        guard error == nil,
            let data = data,
            let response = response as? HTTPURLResponse
            else {
                return
        }
        
        returnData = data
        returnResponse = response
        returnError = error
        
        semaphore.signal()
    }
    
    task.resume()
    _ = semaphore.wait(timeout: .distantFuture)
    
    return (returnData, returnResponse, returnError)
}

/// A utility function that returns a serialisable representation of a `Date` object.
/// - Parameter _: The date object that has to be serialisable.
/// - Returns: An RFC3339 representation of the date.
func stringFromDate(_ date: Date) -> String {
    let iso8601Formatter = ISO8601DateFormatter()
    iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0)!
    
    return iso8601Formatter.string(from: date)
}

/// A utility function that converts an RFC3339 date string to a `Date` object.
/// - Parameter _: An RFC3339 representation of date.
func dateFromString(_ string: String) -> Date {
    let iso8601Formatter = ISO8601DateFormatter()
    iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0)!
    
    guard let date = iso8601Formatter.date(from: string) else {
        fatalError("[DateToStringConverter] - Could not obtain a date for the string: '\(string)'.")
    }
    
    return date
}
