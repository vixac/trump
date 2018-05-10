
import Foundation

enum TrumpHttpMethod : String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}

struct TrumpRequest {
    var method: TrumpHttpMethod
    var endpoint: String
}

struct TrumpResponse {
    var statusCode : Int
    var data : Data
    
    func dataToJson() -> Any {
        return try! JSONSerialization.jsonObject(with: data, options: [])
    }
}

enum TrumpResult {
    case success(TrumpResponse)
    case noMatch
}

protocol TrumpItem {
    func responseFor(_ request: TrumpRequest) -> TrumpResponse?
}

struct TrumpPair {
    let request: TrumpRequest
    let response: TrumpResponse
}

class TrumpResponseStack {
    
    private var responseStacks: [TrumpHttpMethod: [String: [TrumpResponse]]] = [:]
    
    private var pairCount = 0
    public func addPair(request: TrumpRequest, response: TrumpResponse) {
        if responseStacks[request.method] == nil {
            responseStacks[request.method] = [:]
        }
        
        var responseMethodStack = responseStacks[request.method]!
        
        if responseMethodStack[request.endpoint] == nil {
            responseStacks[request.method]![request.endpoint] = [response]
        }
        else {
             responseStacks[request.method]![request.endpoint]?.insert(response , at: 0)
        }
        pairCount += 1
    }
    
    public func handle(_ request: TrumpRequest) -> TrumpResult {
        
        if let responseMethodStack = responseStacks[request.method] {

                for tentative in responseMethodStack {
                    let url = tentative.key
                    if let regexp = try? NSRegularExpression(pattern: url , options: []) {
                        if regexp.numberOfMatches(in: request.endpoint, options: [], range: NSRange(location: 0, length: request.endpoint.count)) > 0 {
                            if let response = responseStacks[request.method]![url]?.popLast() {
                                pairCount -= 1
                                return .success(response)
                            }
                        }
                }                
            }
        }
        
        return .noMatch
        
    }
    
    public func remainingResponses() -> Int {
        return pairCount
    }
    
    public init() {    
    }
    
    public init(with pairs: [TrumpPair]){
        pairs.forEach {
            self.addPair(request: $0.request, response: $0.response)
        }
    }
}
