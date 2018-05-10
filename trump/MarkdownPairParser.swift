
import Foundation

struct ResponseParsingResult {
    
    var url:    String? = nil
    var method: String  = "GET"
    var status: Int     = 200
    var data:   String? = nil
    
    func setURL(url: String) -> ResponseParsingResult {
        return ResponseParsingResult(url: url, method: method, status: status, data: data)
    }
    
    func setMethod(method: String) -> ResponseParsingResult {
        return ResponseParsingResult(url: url, method: method, status: status, data: data)
    }
    
    func setStatus(status: Int) -> ResponseParsingResult {
        return ResponseParsingResult(url: url, method: method, status: status, data: data)
    }
    
    func setData(data: String) -> ResponseParsingResult {
        return ResponseParsingResult(url: url, method: method, status: status, data: data)
    }
    
    func resetResponse() -> ResponseParsingResult {
        return ResponseParsingResult(url: url, method: method, status: 200, data: nil)
    }
}

extension TrumpPair {
    
    init?(_ parsedResponse: ResponseParsingResult) {
        guard let url  = parsedResponse.url,
            let method = TrumpHttpMethod(rawValue: parsedResponse.method),
            let data   = parsedResponse.data?.data(using: .utf8) else { return nil }
        
        self.request = TrumpRequest(method: method, endpoint: url)
        self.response = TrumpResponse(statusCode: parsedResponse.status, data: data) 
    }
    
}


class MarkdownPairParser : TrumpPairLoader {

    let fileParser: FileParser = FileParser()
    
    var state: FileParser.ParserState = .nothing
    
    private let fileName: String
    private let bundle: Bundle
    init(_ fileName: String, bundle: Bundle) {
        self.fileName = fileName
        self.bundle = bundle
    }
    
    func loadPair() throws -> TrumpPair {
        guard let path =  bundle.path(forResource: fileName, ofType: nil) else  {
            throw TrumpException.invalidFile(name: fileName, error: "Error finding markdown file path for '\(fileName)' in bundle: \(bundle.bundleURL.absoluteString)")
        }
        let response = try  self.parseFile(at: path)
        guard let pair = TrumpPair(response) else {
            throw TrumpException.invalidFile(name: fileName, error: "unable to create a trump pair from Response Parsing result: \(response)") //TODO make client friendly.
        }
        return pair
    }
    
    func parseFile(at path: String) throws -> ResponseParsingResult {
        guard let streamer = FileStream(path: path) else {
            throw ParserError.cannotOpenFile(path)
        }
        return try parse(with: streamer)
    }
    
    func errorString(for error: ParserError) -> String {
        return fileParser.errorString(for:error)
    }
    
    private func parse(with streamer: FileStream) throws -> ResponseParsingResult {
        
        var currentLine = 0
        var response = ResponseParsingResult()
        

        for line in streamer {
            
            currentLine += 1
            fileParser.parsingInfo = ParserInfo(currentLine: currentLine, currentFile: streamer.filePath)
            response = try parseResponse(line, response: response)
            
        }
        
        return response
    }
    
    private func parseResponse(_ line: String, response: ResponseParsingResult) throws -> ResponseParsingResult {
        
        let p = fileParser.tokenize(line, currentState: state)
        
        switch p.token {
            
        case .comment:
            return response
            
        case .request:
            state = .request
            return response
            
        case .response:
            
            //It not a new response
            if state != .request && state != .nothing {
                // save the current one and create a copy
                state = .response
                return response.resetResponse()
            }
            
            state = .response
            return response
            
        case .data:
            
            guard state == .response || state == .data else { throw ParserError.notExpecting("'data'", fileParser.parsingInfo) }
            
            state = .data
            return try self.parseData(p.rest, response: response)
            
        case .url:
            return try self.parseURL(p.rest, response: response)
            
        case .status:
            return try self.parseStatus(p.rest, response: response)
            
        case .method:
            return try self.parseMethod(p.rest, response: response)
            
        case .trash:
            if let rest = p.rest,
                rest != "" {
                TrumpError.log("Unexpected token: '\(rest)'")
                throw ParserError.notExpecting(rest, fileParser.parsingInfo)
            } else {
                return response
            }
            
        default:
            throw ParserError.notExpecting(p.token.rawValue, fileParser.parsingInfo)
            
        }
        
    }
    
    private func parseURL(_ urlString: String?, response: ResponseParsingResult) throws -> ResponseParsingResult {
        
        guard state == .request else {
            TrumpError.log("Not expecting 'state'")
            throw ParserError.notExpecting("'state'", fileParser.parsingInfo)
        }
        
        guard let str = urlString,
            str.count > 0 else {
                TrumpError.log("Expecting url or regexp")
                throw ParserError.expecting("url or regexp", fileParser.parsingInfo)
        }
        
        return response.setURL(url: str.replacingOccurrences(of: "`", with: ""))
    }
    
    
    private func parseMethod(_ method: String?, response: ResponseParsingResult) throws -> ResponseParsingResult {
        
        guard state == .request else {
            TrumpError.log("Not expecting 'method'")
            throw ParserError.notExpecting("'method'", fileParser.parsingInfo)
        }
        
        if let m = dequote(method?.lowercased())  {
            switch m {
            case "post":
                return response.setMethod(method: "POST")
                
            case "get":
                return response.setMethod(method: "GET")
                
            case "put":
                return response.setMethod(method: "PUT")
                
            case "delete":
                return response.setMethod(method: "DELETE")
                
            default:
                break
            }
        }
        
        TrumpError.log("Expected 'method' to be one of GET, POST, PUT, DELETE")
        throw ParserError.expecting("'method' to be one of GET, POST, PUT, DELETE", fileParser.parsingInfo)
    }
    
    private func parseStatus(_ status: String?, response: ResponseParsingResult) throws -> ResponseParsingResult {
        
        guard state == .response else {
            TrumpError.log("Not expecting 'status'")
            throw ParserError.notExpecting("'status'", fileParser.parsingInfo)
        }
        
        guard let st = dequote(status),
            let s = Int(st) else {
                TrumpError.log("Expecting an Int")
                throw ParserError.expecting("an Int", fileParser.parsingInfo)
        }
        
        return response.setStatus(status: s)
    }
    
    private func parseData(_ data: String?, response: ResponseParsingResult) throws -> ResponseParsingResult {
        
        guard state == .data else {
            TrumpError.log("Not expecting 'data'")
            throw ParserError.notExpecting("'data'", fileParser.parsingInfo)
        }
        
        guard let d = dequote(data) else {
            TrumpError.log("Expecting some data")
            throw ParserError.expecting("some string data", fileParser.parsingInfo)
        }
        
        if d == "" { //ignore newLine and empty data
            return response
        }
        
        if let previousData = response.data {
            return response.setData(data: "\(previousData)\n\(d)")
        } else {
            return response.setData(data: d)
        }
    }
    
    private func dequote(_ string: String?) -> String? {
        return string?.replacingOccurrences(of: "`", with: "")
    }
    
}
