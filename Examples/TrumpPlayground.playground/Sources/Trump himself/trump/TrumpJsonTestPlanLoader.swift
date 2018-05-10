
import Foundation

class TrumpJsonLoaderUtil {
    
    static func fileToData(_ fileName: String, bundle: Bundle) throws -> Data  {
        guard let path =  bundle.path(forResource: fileName, ofType: nil) else  {
            throw TrumpException.invalidFile(name: fileName, error: "Error finding file path for '\(fileName)' in bundle: \(bundle.bundleURL.absoluteString). Sometimes your file isn't added into the 'Copy Bundle Resources' in build phases. Check it's there!")
        }
        let fileContents = try Data(contentsOf: URL(fileURLWithPath: path))
        return fileContents
    }
    
    static func jsonToStringArray(_ json: Any) -> [String]? {
        guard let array = json as? [String] else {
            return nil
        }
        return array
    }
    
    static func jsonToAnyArray(_ json: Any) -> [Any]? {
        guard let array = json as? [Any] else {
            return nil
        }
        return array
    }
    
    static func jsonToDict(_ json: Any) -> [String: Any]? {
        guard let dict = json as? [String: Any]  else {
            return nil
        }
        return dict
    }
    
    static func dataToJson(_ data: Data) throws -> Any {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return json
    }
    
    static func fileToJson(_ fileName: String, bundle: Bundle) throws -> Any {
        let data = try TrumpJsonLoaderUtil.fileToData(fileName, bundle: bundle)
        let json = try TrumpJsonLoaderUtil.dataToJson(data)
        return json
    }
}

class JsonTestPlanLoader : TrumpTestPlanLoader {
    
    
    private let fileName: String
    private let bundle: Bundle
    init(_ fileName: String, bundle: Bundle) {
        self.fileName = fileName
        self.bundle = bundle
    }
    func loadTestPlan() throws -> [TestPlanParsingResult] {
        
        let json = try TrumpJsonLoaderUtil.fileToJson(fileName, bundle: bundle)
        guard let array = TrumpJsonLoaderUtil.jsonToAnyArray(json) else {
            throw TrumpException.invalidFile(name: fileName, error: "Cannot read json as an array.")
        }
        
        var plan : [TestPlanParsingResult] = []
        
        for(index, element) in array.enumerated() {
            guard let dict = TrumpJsonLoaderUtil.jsonToDict(element) else {
                throw TrumpException.invalidFile(name: fileName, error: "can't read item \(index) in array as an object.")
            }
            guard let name = dict["name"] as? String else {
                throw TrumpException.invalidFile(name: fileName, error: "missing 'name' as a string, for item \(index) in array.")
            }
            guard let count = dict["count"] as? Int else {
                throw TrumpException.invalidFile(name: fileName, error: "missing 'count' as an int,  for item \(index) in array.")
            }
            plan.append(TestPlanParsingResult(filePath: name, count: count))
        }
        return plan
    }
}
