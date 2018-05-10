
import Foundation


typealias TrumpPairs = [TrumpPair]

struct TestPlanParsingResult {
    
    var filePath: String? = nil
    var count: Int = 1
    
    func setFile(_ filePath: String) -> TestPlanParsingResult {
        return TestPlanParsingResult(filePath: filePath, count: count)
    }
    
    func setCount(_ count: Int) -> TestPlanParsingResult {
        return TestPlanParsingResult(filePath: filePath, count: count)
    }
    
}

enum TrumpException : Error {
    case invalidFile(name: String, error: String)
}

protocol TrumpTestPlanLoader {
     func loadTestPlan() throws -> [TestPlanParsingResult]
}

protocol TrumpPairLoader {
     func loadPair() throws -> TrumpPair
}




class TrumpLoader {
    
    enum TrumpFileType {
        case json
        case markdown
    }
    
    private static func getTrumpFileType(_ fileName: String) throws -> TrumpFileType? {
        let lower = fileName.lowercased()
        if lower.range(of:".json") != nil {
            return .json
        }
        else if lower.range(of:".md") != nil {
            return .markdown
        }
        else if lower.range(of: ".trp") != nil {
            return .markdown
        }
        else if lower.range(of: ".ttp") != nil {
            return .markdown
        }
        else if lower.range(of: ".trump") != nil {
            return .markdown
        }
           throw TrumpException.invalidFile(name: fileName, error: "This file  does not have a valid Trump file extension. Is it json or trump markdown?")
    }

    
    static func loadTestPlan(_ fileName: String, bundle: Bundle) throws -> TrumpPairs {

        let fileType = try  TrumpLoader.getTrumpFileType(fileName)
        let testPlanParser : TrumpTestPlanLoader = fileType == .json ? JsonTestPlanLoader(fileName, bundle: bundle) : MarkdownTestPlanParser(fileName, bundle: bundle)
        let testPlan = try testPlanParser.loadTestPlan()
        var pairs: TrumpPairs = []
        try testPlan.forEach { item in
            guard let name = item.filePath else {
                print("TODO ERROR nil filePath. Is this permitted? Does it need to be optional?")
                return
            }
            let count = item.count
            let pairFileType = try TrumpLoader.getTrumpFileType(name)
            let pairParser : TrumpPairLoader = pairFileType == .json ? JsonPairLoader(name, bundle: bundle) : MarkdownPairParser(name, bundle: bundle)
            let pair = try pairParser.loadPair()
            for _ in 1...count {
                pairs.append(pair)
            }
        }
        return pairs
    }
    
    
}
