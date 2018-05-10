
import Foundation


class JsonPairLoader : TrumpPairLoader {
    private let fileName: String
    private let bundle: Bundle
    init(_ fileName: String, bundle: Bundle) {
        self.fileName = fileName
        self.bundle = bundle
    }
    
    func loadPair() throws -> TrumpPair {
        let json = try TrumpJsonLoaderUtil.fileToJson(fileName, bundle: bundle)
        guard let pair = TrumpJsonLoaderUtil.jsonToDict(json) else {
            throw TrumpException.invalidFile(name: fileName, error: "unable to find request response pair object.")
            
        }
        
        guard let request = pair["request"] as? [String: Any] else {
            throw TrumpException.invalidFile(name: fileName, error: "unable to find request in pair: \(pair)")
        }
        guard let response = pair["response"] as? [String: Any] else {
            throw TrumpException.invalidFile(name: fileName, error: "unable to find response in pair: \(pair)")
            
        }
        guard let trumpRequest = self.toTrumpRequest(request) else {
            throw TrumpException.invalidFile(name: fileName, error: "unable to parse request in pair: \(pair)")
        }
        guard let trumpResponse = self.toTrumpResponse(response) else {
            throw TrumpException.invalidFile(name: fileName, error: "unable to parse response in pair: \(pair)")
        }
        
        return TrumpPair(request: trumpRequest, response: trumpResponse)
    }
    
    private func toTrumpRequest(_ dict: [String: Any]) -> TrumpRequest? {
        guard let method = TrumpHttpMethod(rawValue:  (dict["method"] as? String) ?? "") else {
            TrumpError.log("missing or invalid method in Trump request: \(dict ). Should be GET or POST.")
            return nil
        }
        guard let endpoint = dict["endpoint"] as? String else {
            TrumpError.log("missing endpoint in Trump request: \(dict )")
            return nil
        }
        return TrumpRequest(method: method, endpoint: endpoint)
    }
    
    private  func toTrumpResponse(_ dict: [String: Any]) -> TrumpResponse? {
        guard let statusCode = dict["statusCode"] as? Int else {
            TrumpError.log("missing statusCode in Trump response: \(dict)")
            return nil
        }
        guard let dataDict = dict["data"] else {
            TrumpError.log("missing data in Trump response: \(dict)")
            return nil
        }
        let data = try! JSONSerialization.data(withJSONObject: dataDict, options: [])
        return TrumpResponse(statusCode: statusCode, data: data)
    }

}

