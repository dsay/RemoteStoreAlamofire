import Alamofire
import Foundation
import SwiftRepository

open class RemoteStoreAlamofire: RemoteStore {
 
    public var handler: BaseHandler
    public var session: Alamofire.Session
    
    public init(session: Alamofire.Session, handler: BaseHandler) {
        self.session = session
        self.handler = handler
    }
    
    public func send(_ request: RequestProvider) throws -> DataRequest {
       try session.request(request.asURLRequest()).validate()
    }
   
    public func send(request: RequestProvider, responseString: @escaping (Result<String, Error>) -> Void) {
        do {
            try send(request).responseString { (response: AFDataResponse<String>) -> Void in
                responseString(self.handler.handle(response))
            }
        } catch {
            responseString(.failure(error))
        }
    }
    
    public func send(request: RequestProvider, responseData: @escaping (Result<Data, Error>) -> Void) {
        do {
            try send(request).responseData { (response: AFDataResponse<Data>) -> Void in
                responseData(self.handler.handle(response))
            }
        } catch {
            responseData(.failure(error))
        }
    }
    
    public func send(request: RequestProvider, responseJSON: @escaping (Result<Any, Error>) -> Void) {
        do {
            try send(request).responseJSON { (response: AFDataResponse<Any>) -> Void in
                responseJSON(self.handler.handle(response))
            }
        } catch {
            responseJSON(.failure(error))
        }
    }
}
