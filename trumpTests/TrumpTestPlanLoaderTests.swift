
import XCTest
@testable import Trump

class TrumpTestPlanLoaderTests: XCTestCase {
    
    
    let bundle : Bundle = Bundle(for: TrumpTestPlanLoaderTests.self)
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSingleFileTestPlan() {
        let pairs = try! TrumpLoader.loadTestPlan("TrumpTestPlanFruits.ttp.md", bundle: bundle)
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
        
        let pairs = try! TrumpLoader.loadTestPlan("TrumpTestPlanFoods.ttp.md", bundle: bundle)
        print("multi pairs is \(pairs)")
        XCTAssertEqual(pairs.count, 3)
        XCTAssertEqual(pairs[0].request.endpoint, "www.trumpfruittest.com/getfruits")
        XCTAssertEqual(pairs[0].response.statusCode, 200)
        
        XCTAssertEqual(pairs[1].request.endpoint, "www.trumpvegtest.com")
        XCTAssertEqual(pairs[1].response.statusCode, 300)
        
        XCTAssertEqual(pairs[2].request.endpoint, "www.trumpvegtest.com")
        XCTAssertEqual(pairs[2].response.statusCode, 301)
        
    }
    
    //TODO test invalid file names, test invalid files, test bad json etc.
    
    private func toStringArray(_ any: Any) -> [String] {
        let nsarray = any as! NSArray
        let array = Array(nsarray)
        let arrayString : [String] = array.map { return $0 as! String }
        return arrayString
    }
}
