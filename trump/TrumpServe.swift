
import Foundation


class TrumpError {
    
    class func log(_ message: String) {
        print("Trump Error: \(message)")
    }
}

 class TrumpServe : TrumpURLResponder {
    
    let stack : TrumpResponseStack
    let failureCallback : (() -> Void)
     init(_ stack: TrumpResponseStack, failureCallback: @escaping (() -> Void)) {
        self.stack  = stack
        self.failureCallback = failureCallback
    }

     func respondTo(request: URLRequest, with client: URLProtocolClient, urlProtocol: URLProtocol)  {
        
        print("Trump asked to handle request: '\(request)'")
        guard let trumpRequest = TrumpServe.toTrumpRequest(request) else {
            TrumpError.log("Error creating TrumpRequest from urlrequest: \(request)")
            return
        }
        let result = self.stack.handle(trumpRequest)
        switch result {
        case .noMatch:
            TrumpError.log("No match remaining for request: \(trumpRequest)")
            self.failureCallback()
        case let .success(trumpResponse):
            guard let httpResponse = TrumpServe.toHttpResponse(trumpRequest, response: trumpResponse) else {
                TrumpError.log("Error converting trumpResponse to URLResponse: \(trumpResponse), intial request was: \(request)")
                return
            }
            client.urlProtocol(urlProtocol, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            client.urlProtocol(urlProtocol, didLoad: trumpResponse.data)
            client.urlProtocolDidFinishLoading(urlProtocol)
            print("Fake news served to \(request)")
        }
        
    }
    
    private static func toTrumpRequest(_ request: URLRequest) -> TrumpRequest? {
        let url = request.url?.absoluteString ?? ""
        guard let method = TrumpHttpMethod(rawValue: request.httpMethod ?? "GET") else {
            print("Dev error converting URLRequest method to TrumpHttpMethod.")
            return nil
        }
        return TrumpRequest(method: method, endpoint: url)
    }
    
    private static func toHttpResponse(_ request: TrumpRequest, response: TrumpResponse) -> HTTPURLResponse? {
        let statusCode = response.statusCode
        let url = URL(string: request.endpoint)!
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: [:])
        
    }
    
    deinit {
        
        if stack.remainingResponses() > 0 {
            failureCallback()
        }
    }
}

