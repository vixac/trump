
import XCTest
@testable import Trump
class TrumpServeTests: XCTestCase {
    
    let bundle : Bundle = Bundle(for: TrumpServeTests.self)
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(TrumpURL.self)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testIntegrationTest() {
        let pairs = try! TrumpLoader.loadTestPlan("TrumpTestPlanFood.json", bundle: bundle)
        let stack = TrumpResponseStack(with: pairs)
        
        var trumpFailCount = 0
        let serve = TrumpServe(stack, failureCallback: {
            print("Failure callback called.")
            trumpFailCount += 1
        })
        TrumpURL.trumpDelegate = serve
        
        let session = URLSession.shared
        let expectation1 = self.expectation(description: "trumpVegTest")
        let task = session.dataTask(with: URL(string: "www.trumpvegtest.com")!) { data, response, error in
            let httpResponse = response as! HTTPURLResponse
            XCTAssertEqual(httpResponse.statusCode, 300)
            expectation1.fulfill()
            //TODO check data, celery and brocolli
        }
        task.resume()
        
        let expectation2 = self.expectation(description: "trumpVegTest2")
        let task2 = session.dataTask(with: URL(string: "www.trumpvegtest.com")!) { data, response, error in
            let httpResponse = response as! HTTPURLResponse
            XCTAssertEqual(httpResponse.statusCode, 301)
            expectation2.fulfill()
        }
        task2.resume()
        
        
        let expectation3 = self.expectation(description: "trumpVegTest")
        let task3 = session.dataTask(with: URL(string: "www.trumpfruittest.com/getfruits")!) { data, response, error in
            let httpResponse = response as! HTTPURLResponse
            XCTAssertEqual(httpResponse.statusCode, 200)
            expectation3.fulfill()
        }
        task3.resume()
        
        
        XCTAssertEqual(trumpFailCount, 0)
        let task4 = session.dataTask(with: URL(string: "www.trumpfruittest.com/getfruits")!) { data, response, error in
            print("this shouldn't happen at all.")
            XCTFail()
        }
        task4.resume()
        
        let failureExpectation = self.expectation(description: "failure")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { 
            XCTAssertEqual(trumpFailCount, 1)
            failureExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testDeinitCallsFailure() {
        
        var trumpFailCount = 0
        func localTrump() {
            let request = TrumpRequest(method: .get, endpoint: "testEndpoint")
            let data = try! JSONSerialization.data(withJSONObject: ["data": "value"], options: [])
            let response = TrumpResponse(statusCode: 200, data: data)
            let trumpPair = TrumpPair(request: request, response: response)
            
            let serve = TrumpServe(TrumpResponseStack(with: [trumpPair]), failureCallback: {
                print("Failure callback called.")
                trumpFailCount += 1
            })
            
            let _ = serve.stack
        }
        
        XCTAssertEqual(trumpFailCount, 0)
        localTrump()
        XCTAssertEqual(trumpFailCount, 1)
    }
    
    func testArrayAsData() {
        let pairs = try! TrumpLoader.loadTestPlan("TrumpTestPlanAnimals.json", bundle: bundle)
        let stack = TrumpResponseStack(with: pairs)
        var trumpFailCount = 0
        let serve = TrumpServe(stack, failureCallback: {
            trumpFailCount += 1
        })
        
        TrumpURL.trumpDelegate = serve
        
        let session = URLSession.shared
        let expectation1 = self.expectation(description: "trumpAnimalTest")
        let task = session.dataTask(with: URL(string: "www.trumpanimaltest.com")!) { data, response, error in
            let httpResponse = response as! HTTPURLResponse
            XCTAssertEqual(httpResponse.statusCode, 300)
            XCTAssertNotNil(data)
            let json = try! JSONSerialization.jsonObject(with: data!, options: [])
            let array = json as! [String]
            XCTAssertEqual(array[0], "cat")
            XCTAssertEqual(array[1], "dog")
            expectation1.fulfill()
            
        }
        task.resume()
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    

}
