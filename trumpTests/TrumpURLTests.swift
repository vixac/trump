
import XCTest
@testable import Trump


class TrumpURLTests: XCTestCase {
    
    
    var mockDelegate: MockTrumpURLResponder!
    override func setUp() {
        
        super.setUp()
        URLProtocol.registerClass(TrumpURL.self)
        mockDelegate = MockTrumpURLResponder()
        TrumpURL.trumpDelegate = mockDelegate
    }
    
    override func tearDown() {
        TrumpURL.trumpDelegate = nil
        super.tearDown()
    }
    
    func testHitGoogle() {

        let url = URL(string: "http://google.com")!
        let expectation = self.expectation(description: "ping")
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            let httpResponse = response as! HTTPURLResponse
            XCTAssertEqual(httpResponse.statusCode, 123)
            XCTAssertEqual(httpResponse.url?.absoluteString ?? "", "http://mockTrumpURLResponse.com")
            expectation.fulfill()
        }
        task.resume()
        waitForExpectations(timeout: 5, handler: nil)
    }
}


class MockTrumpURLResponder : TrumpURLResponder {
    func respondTo(request: URLRequest, with client: URLProtocolClient, urlProtocol: URLProtocol) {
        
        let response = HTTPURLResponse(url: URL(string: "http://mockTrumpURLResponse.com")!, statusCode: 123, httpVersion: "HTTP/1.1", headerFields: [:])!
        client.urlProtocol(urlProtocol, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        
        client.urlProtocolDidFinishLoading(urlProtocol)
    }
}
