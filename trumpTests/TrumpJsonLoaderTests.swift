
import XCTest
@testable import Trump

class TrumpJsonTestLoaderTests: XCTestCase {
    
    let bundle : Bundle = Bundle(for: TrumpJsonTestLoaderTests.self)
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSingleFileTestPlan() {
        let pairs = try!  TrumpLoader.loadTestPlan("TrumpTestPlanFruits.json", bundle: bundle)
        XCTAssertEqual(pairs.count, 1)
        let request = pairs[0].request
        let response = pairs[0].response
        XCTAssertEqual(request.method.rawValue, "GET")
        XCTAssertEqual(request.endpoint, "www.trumpfruittest.com/getfruits")
        
        XCTAssertEqual(response.statusCode, 200)

        let fruits = try! JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
    
        let arrayString = toStringArray(fruits["fruits"]!)
        XCTAssertNotNil(arrayString)
        XCTAssertEqual(arrayString.count, 3)
        XCTAssertEqual(arrayString[0], "apple")
        XCTAssertEqual(arrayString[1], "orange")
        XCTAssertEqual(arrayString[2], "banana")
    }
    
    func testMultipleFileTestPlan() {
        let pairs = try!  TrumpLoader.loadTestPlan("TrumpTestPlanFood.json", bundle: bundle)
        
        XCTAssertEqual(pairs.count, 3)
        
        let fruitsPair = pairs.filter { return $0.request.endpoint == "www.trumpfruittest.com/getfruits" }
        XCTAssertEqual(fruitsPair.count, 1)
        XCTAssertEqual(fruitsPair[0].response.statusCode, 200)
    
        let vegPairs = pairs.filter { return $0.request.endpoint == "www.trumpvegtest.com" }
        XCTAssertEqual(vegPairs.count, 2)
        XCTAssertEqual(vegPairs[0].response.statusCode, 300)
        XCTAssertEqual(vegPairs[1].response.statusCode, 301)
        
    }
    
    //TODO test invalid file names, test invalid files, test bad json etc.
    
    private func toStringArray(_ any: Any) -> [String] {
        let nsarray = any as! NSArray
        let array = Array(nsarray)
        let arrayString : [String] = array.map { return $0 as! String }
        return arrayString
    }
    

}

