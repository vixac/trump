
import Foundation

 protocol TrumpURLResponder {
    func respondTo(request: URLRequest, with client: URLProtocolClient, urlProtocol: URLProtocol)
}

public class TrumpURL : URLProtocol {
    
    static var trumpDelegate: TrumpURLResponder? = nil
    
    override open class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    override open class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }
    
    override open func startLoading() {
        guard let client = self.client else {
            TrumpError.log("Error loading client in TrumpURL URLProtocol.")
            return
        }
        
        guard let d = TrumpURL.trumpDelegate else {
            TrumpError.log("TrumpURL needs a TrumpURLResponder to handle requests.")
            return
        }
        d.respondTo(request: self.request, with: client, urlProtocol: self  )
    }
    
    override open func stopLoading() {
    }
    

}
