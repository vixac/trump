
import XCTest
@testable import Trump

class TrumpResponseStackTests: XCTestCase {
    
    
    var serve : TrumpResponseStack!
    override func setUp() {
        super.setUp()
        serve = TrumpResponseStack()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testEmpty() {
        
        let request = TrumpRequest(method: TrumpHttpMethod.get, endpoint: "testEndpoint")
        let  result = serve.handle(request)
        if case .noMatch = result {
            //Success finding no match.
        }
        else {
            XCTFail()
        }
    }
    
    func testOne() {
        let request = TrumpRequest(method: .get, endpoint: "testEndpoint")
        let data = try! JSONSerialization.data(withJSONObject: ["data": "value"], options: [])
        let response = TrumpResponse(statusCode: 200, data: data)
        serve.addPair(request: request, response: response)
        
        let result = serve.handle(request)
        if case let .success(outputResponse) = result {
            XCTAssertEqual(outputResponse.statusCode, 200)
            let data  = outputResponse.dataToJson() as! [String: Any]
            let str = data["data"]
            XCTAssertNotNil(str)
        }
        else {
            XCTFail()
        }
        if case  .noMatch = serve.handle(request) {
            //Success, can't retrieve same thing twice.
        }
        else {
            XCTFail()
        }
    }
    
    func testTrumpInitWithPairs() {

        let dupRequest = TrumpRequest(method: .get, endpoint: "test1")
        let data1 = try! JSONSerialization.data(withJSONObject:  ["data" : "1"], options: [])
        let data2 = try! JSONSerialization.data(withJSONObject:  ["data": "2"], options: [])
        let data3 = try! JSONSerialization.data(withJSONObject:  ["data": "3"], options: [])
        let pairs = [
            TrumpPair(request: dupRequest  , response: TrumpResponse(statusCode: 200, data: data1)),
            TrumpPair(request:  TrumpRequest(method: .post, endpoint: "test2"), response: TrumpResponse(statusCode: 201, data: data2 )),
            TrumpPair(request: dupRequest ,  response: TrumpResponse(statusCode: 202, data: data3))        ]
        serve = TrumpResponseStack(with: pairs)
        
        let result = serve.handle(dupRequest)
        if case let .success(output) = result {
            XCTAssertEqual(output.statusCode, 200)
            let d = output.dataToJson() as! [String: Any]
            let str = d["data"] as? String
            XCTAssertNotNil(str)
            XCTAssertEqual(str!, "1")
        } else {
            XCTFail()
        }
        
        let result2 = serve.handle(dupRequest)
        if case let .success(output) = result2 {
            XCTAssertEqual(output.statusCode, 202)
            let d = output.dataToJson() as! [String: Any]
            let str = d["data"] as? String
            XCTAssertNotNil(str)
            XCTAssertEqual(str!, "3")
        } else {
            XCTFail()
        }
        
        
        let result3 = serve.handle(dupRequest)
        if case .success = result3 {
            XCTFail()
        }
        
        let result4 = serve.handle(pairs[1].request)
            
        if case let .success(output) = result4 {
            XCTAssertEqual(output.statusCode, 201)
            let d = output.dataToJson() as! [String: Any]
            let str = d["data"] as? String
            XCTAssertNotNil(str)
            XCTAssertEqual(str!, "2")
        } else {
            XCTFail()
        }
    }
    
    func testTrumpRegex() {
    
        let dupRequest = TrumpRequest(method: .get, endpoint: "test1/test.*/experiment1")
        let data1 = try! JSONSerialization.data(withJSONObject:  ["data" : "1"], options: [])
        let data2 = try! JSONSerialization.data(withJSONObject:  ["data": "2"], options: [])
        let data3 = try! JSONSerialization.data(withJSONObject:  ["data": "3"], options: [])
        let pairs = [
            TrumpPair(request: dupRequest  , response: TrumpResponse(statusCode: 200, data: data1)),
            TrumpPair(request:  TrumpRequest(method: .post, endpoint: "test2/userid=.*/date=today"), response: TrumpResponse(statusCode: 201, data: data2 )),
            TrumpPair(request: dupRequest ,  response: TrumpResponse(statusCode: 202, data: data3))        ]
        serve = TrumpResponseStack(with: pairs)
        

        XCTAssertEqual(serve.remainingResponses(), 3)
        let result = serve.handle(TrumpRequest(method: .get, endpoint: "test1/test1/experiment1"))
        if case let .success(output) = result {
            XCTAssertEqual(output.statusCode, 200)
            let d = output.dataToJson() as! [String: Any]
            let str = d["data"] as? String
            XCTAssertNotNil(str)
            XCTAssertEqual(str!, "1")
        } else {
            XCTFail("failure, wrong result: \(result)")
        }
        
        let result2 = serve.handle(TrumpRequest(method: .get, endpoint: "test1/test2/experiment1"))
        if case let .success(output) = result2 {
            XCTAssertEqual(output.statusCode, 202)
            let d = output.dataToJson() as! [String: Any]
            let str = d["data"] as? String
            XCTAssertNotNil(str)
            XCTAssertEqual(str!, "3")
        } else {
            XCTFail("failure, wrong result: \(result)")
        }
        
        let result3 = serve.handle(TrumpRequest(method: .post, endpoint: "test2/userid=123/date=today"))
        if case let .success(output) = result3 {
            XCTAssertEqual(output.statusCode, 201)
            let d = output.dataToJson() as! [String: Any]
            let str = d["data"] as? String
            XCTAssertNotNil(str)
            XCTAssertEqual(str!, "2")
        } else {
            XCTFail("failure, wrong result: \(result)")
        }
        XCTAssertEqual(serve.remainingResponses(), 0)
    }
}
