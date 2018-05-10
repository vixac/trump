// test

import Foundation



extension FileStream : Sequence {
    func makeIterator() -> AnyIterator<String> {
        return AnyIterator {
            return self.nextLine()
        }
    }
}

enum ParserError: Error {
    
    case expecting(String, ParserInfo)
    case notExpecting(String, ParserInfo)
    case responseCount(Int, Int, ParserInfo)
    case cannotOpenFile(String)
    
}

struct ParserInfo {
    
    let currentLine: Int
    let currentFile: String
}


class FileParser {
    
    enum ParserState {
        case nothing
        case request
        case response
        case keyword
        case testCase
        case data
    }
    
    enum ParserToken : String {
        
        case comment  = "#"
        case request  = "REQUEST"
        case response = "RESPONSE"
        case testCase = "CASE"
        
        case url    = "+url:"
        case status = "+status:"
        case count  = "+count:"
        case method = "+method:"
        case data   = "+data:"
        case file   = "+file:"
        case trash
        
        static let allTokens = [comment, request, response, url, status, count, method, data, file, testCase]
    }
    
    struct TokenizedString {
        
        let token: ParserToken
        let rest: String?
        
    }
    
    var parsingInfo = ParserInfo(currentLine: -1, currentFile: "")
    
    func tokenize(_ string: String, currentState: ParserState) -> TokenizedString {
        
        let keywork = normalize(string)
        
        for t in ParserToken.allTokens {
            if keywork.hasPrefix(t.rawValue) {
                let lastChar = t.rawValue.characters.last
                if let index = string.characters.index(of: lastChar!) {
                    let startIndex = string.index(index, offsetBy: 1)
                    let range = startIndex..<string.endIndex
                    let rest = string[range].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    return TokenizedString(token: t, rest: rest)
                }
            }
        }
        
        if currentState == .data {
            return TokenizedString(token: .data, rest: string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        }
        
        return TokenizedString(token: .trash, rest: string)
    }
    
    func errorString(for error: ParserError) -> String {
        switch error {
            
        case let .expecting(cause, info):
            return "Failed to parse line: \(info.currentLine) in file \(info.currentFile): Expecting \(cause)"
            
        case let .notExpecting(cause, info):
            return "Failed to parse line: \(info.currentLine) in file \(info.currentFile): Not Expecting \(cause)"
            
        case let .responseCount(current, expected, info):
            return "Failed to parse responses: \(info.currentLine) in file \(info.currentFile): Expecting 1 or \(expected) responses, got \(current)"
            
        case let .cannotOpenFile(path):
            return "Cannot open file at path: \(path)"
            
        }
    }
    
    private func normalize(_ string: String) -> String {
        return string.replacingOccurrences(of: " ", with: "")
    }
    
    
    
}


class FileStream {
    
    let filePath: String
    let encoding : String.Encoding
    let chunkSize : Int
    var fileHandle : FileHandle!
    let delimiterData : Data
    var buffer : Data
    var atEof : Bool
    
    init?(path: String, delimiter: String = "\n", encoding: String.Encoding = .utf8,
          chunkSize: Int = 4096) {
        
        guard let fileHandle = FileHandle(forReadingAtPath: path),
            let delimData = delimiter.data(using: encoding) else {
                return nil
        }
        self.filePath = path
        self.encoding = encoding
        self.chunkSize = chunkSize
        self.fileHandle = fileHandle
        self.delimiterData = delimData
        self.buffer = Data(capacity: chunkSize)
        self.atEof = false
    }
    
    deinit {
        self.close()
    }
    
    func nextLine() -> String? {
        
        guard fileHandle != nil else {
            return nil
        }
        
        while !atEof {
            if let range = buffer.range(of: delimiterData) {
                let line = String(data: buffer.subdata(in: 0..<range.lowerBound), encoding: encoding)
                buffer.removeSubrange(0..<range.upperBound)
                return line
            }
            let tmpData = fileHandle.readData(ofLength: chunkSize)
            if tmpData.count > 0 {
                buffer.append(tmpData)
            } else {
                atEof = true
                if buffer.count > 0 {
                    let line = String(data: buffer as Data, encoding: encoding)
                    buffer.count = 0
                    return line
                }
            }
        }
        return nil
    }
    
    
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
    
}
