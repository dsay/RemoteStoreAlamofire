import Alamofire
import Foundation

public protocol Log {
    
    func log<T>(_ response: DataResponse<T, AFError>)
    func success<T>(_ value: T)
    func failure(_ error: Error)
}

public struct DEBUGLog: Log {
    
    let separator = " "
    let empty = "----"
    
    public init(){
    }
    
    public func log<T, E>(_ response: DataResponse<T, E>) {
        divider()
        methodName(response.request?.httpMethod)
        urlPath(response.request?.url?.absoluteString)
        header(response.request?.allHTTPHeaderFields)
        parameters(response.request?.httpBody)
        statusCode(response.response?.statusCode)
        metrics(response.metrics)
        jsonResponse(response.data)
    }
    
    public func success<T>(_ value: T) {
        print("📗 Success:", value, separator: separator, terminator: "\n\n")
        divider()
    }
    
    public func failure(_ error: Error) {
        print("📕 Failure:", error, separator: separator, terminator: "\n\n")
        divider()
    }
    
    private func divider(_ symols: Int = 60) {
        print((0 ... symols).compactMap { _ in return "-" }.reduce("", { divider, add -> String in
            return divider + add
        }))
    }
    
    fileprivate func methodName(_ name: String?) {
        if let name = name {
            print("📘 Method:", name, separator: separator)
        } else {
            print("📓 Method:", empty, separator: separator)
        }
    }
    
    fileprivate func urlPath(_ path: String?) {
        if let path = path {
            print("📘 URL:", path, separator: separator)
        } else {
            print("📓 URL:", empty, separator: separator)
        }
    }
    
    fileprivate func header(_ header: [String: String]?) {
        if let header = header, header.isEmpty == false {
            
            let string = header.compactMap {
                "\($0): \($1)"
            }.joined(separator: "\n           ")
            
            print("📘 Header:", string, separator: separator)
        } else {
            print("📓 Header:", empty, separator: separator)
        }
    }
    
    fileprivate func parameters(_ data: Data?) {
        if let parameters = data.flatMap({ $0.prettyPrintedJSONString }) {
            print("📘 Parameters:", parameters, separator: separator)
        } else {
            print("📓 Parameters:", empty, separator: separator)
        }
    }
    
    fileprivate func statusCode(_ code: NSInteger?) {
        if let code = code {
            switch code {
            case 200..<300:
                print("📗 StatusCode:", code, separator: separator)
                
            case 300..<500:
                print("📕 StatusCode:", code, separator: separator)
                
            default:
                print("📙 StatusCode:", code, separator: separator)
            }
        } else {
            print("📙 StatusCode:", empty, separator: separator)
        }
    }
    
    fileprivate func metrics(_ metrics: URLSessionTaskMetrics?) {
        if let duration = metrics?.taskInterval.duration {
            switch duration {
            case 0..<1:
                print("📗 Duration:", duration, separator: separator)
            case 1..<3:
                print("📙 Duration:", duration, separator: separator)
            default:
                print("📕 Duration:", duration, separator: separator)
            }
        } else {
            print("📙 Duration:", empty, separator: separator)
        }
    }
    
    fileprivate func jsonResponse(_ data: Data?) {
        if let json = data.flatMap({ $0.prettyPrintedJSONString }) {
            print("📓 JSON:", json)
        } else {
            print("📓 JSON:", empty)
        }
    }
}

public struct RELEASELog: Log {
    
    public init(){
    }
    
    public func log<T, E>(_ response: DataResponse<T, E>) {
    }
    
    public func success<T>(_ value: T) {
    }
    
    public func failure(_ error: Error) {
    }
}

extension Data {
    
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
