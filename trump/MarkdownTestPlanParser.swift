
import Foundation

class MarkdownTestPlanParser : TrumpTestPlanLoader {
    
    
    private let fileName: String
    private let bundle: Bundle
    init(_ fileName: String, bundle: Bundle) {
        self.fileName = fileName
        self.bundle = bundle
    }
    func loadTestPlan() throws -> [TestPlanParsingResult] {
        guard let path =  bundle.path(forResource: fileName, ofType: nil) else  {
            throw TrumpException.invalidFile(name: fileName, error: "Error json finding file path for '\(fileName)' in bundle: \(bundle.bundleURL.absoluteString). Sometimes your file isn't added into the 'Copy Bundle Resources' in build phases. Check it's there!")
        }
        return try self.parseFile(at: path)
    }
    
    let fileParser: FileParser = FileParser()
    
    var state: FileParser.ParserState = .nothing
    var stack: [TestPlanParsingResult] = []
    
    func parseFile(at path: String) throws -> [TestPlanParsingResult] {
        
        guard let streamer = FileStream(path: path) else {
            throw ParserError.cannotOpenFile(path)
        }
        
        return try parse(with: streamer)
       
    }
    
    func errorString(for error: ParserError) -> String {
        return fileParser.errorString(for:error)
    }

    
    private func parse(with streamer: FileStream) throws -> [TestPlanParsingResult] {
        
        var currentLine = 0
        var result = TestPlanParsingResult()
        for line in streamer {
            
            currentLine += 1
            fileParser.parsingInfo = ParserInfo(currentLine: currentLine, currentFile: streamer.filePath)
            result = try parseCaseLine(line, result: result)
            
        }
        
        stack.append(result)
        
        return stack
    }
    
    
    private func parseCaseLine(_ line: String, result: TestPlanParsingResult) throws -> TestPlanParsingResult {
        
        let p = fileParser.tokenize(line, currentState: state)
        
        switch p.token {
        case .comment:
            return result
            
        case .testCase:
            
            if state == .testCase {
                stack.append(result)
                return TestPlanParsingResult()
            }
            
            state = .testCase
            return result
            
        case .file:
            return try self.parseFileLink(p.rest, result: result)
            
        case .count:
            return try self.parseCount(p.rest, result: result)
            
        case .trash:
            if let rest = p.rest,
                rest != "" {
                TrumpError.log("Unexpected token: '\(rest)'")
                throw ParserError.notExpecting(rest, fileParser.parsingInfo)
            } else {
                return result
            }
            
        default:
            throw ParserError.notExpecting(p.token.rawValue, fileParser.parsingInfo)
        }
        
    }
    
    
    private func parseFileLink(_ filePath: String?, result: TestPlanParsingResult) throws -> TestPlanParsingResult {
        
        guard state == .testCase else {
            TrumpError.log("Not expecting 'file'")
            throw ParserError.notExpecting("'file'", fileParser.parsingInfo)
        }
        
        guard let path = filePath?.replacingOccurrences(of: "`", with: "") else {
            TrumpError.log("Expecting a file path")
            throw ParserError.expecting("a file path", fileParser.parsingInfo)
        }
        
        return result.setFile(path)
        
    }
    
    private func parseCount(_ count: String?, result: TestPlanParsingResult) throws -> TestPlanParsingResult {
        
        guard state == .testCase else {
            TrumpError.log("Not expecting 'count'")
            throw ParserError.notExpecting("'count'", fileParser.parsingInfo)
        }
        
        guard let c = count,
            let int = Int(c) else {
                TrumpError.log("Expecting an Int")
                throw ParserError.expecting("an Int", fileParser.parsingInfo)
        }
        
        return result.setCount(int)
        
    }
    
}
