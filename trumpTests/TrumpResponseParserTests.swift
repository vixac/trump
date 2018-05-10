
import XCTest
@testable import Trump

class TrumpResponseParserTests: XCTestCase {
    
    let bundle : Bundle = Bundle(for: TrumpResponseParserTests.self)
    
    func testComments() {
        
        
        let file = write("# A Comment:", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        let response = try! rp.parseFile(at: file)
        
        XCTAssertEqual(response.url, nil)
        
    }
    
    func testRequestKeyword() {
        
        
        let file = write("REQUEST", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        XCTAssertNoThrow(try rp.parseFile(at: file))
        
        
    }

    func testResponseKeyword() {
        
        
        let file = write("RESPONSE", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        XCTAssertNoThrow(try rp.parseFile(at: file))
        
    }
    
    func testDoubleComments() {
        
        
        let file = write("## more Comments:", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        
        XCTAssertNoThrow(try rp.parseFile(at: file))
        
    }

    func testBareKeywords() {
        
        let keywords = ["+url:", "+method:", "+status:", "+data:", "+count:", "+someKeyword:"]
        
        keywords.forEach(_testKeyword(_:))
        
    }
    
    func _testKeyword(_ k: String) {
        
        
        let file = write(k, to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        XCTAssertThrowsError(try rp.parseFile(at: file))
        
    }
    
    func testGoodRequestKeywords() {
        
        let acceptedKeywords = ["+url: a", "+method: POST"]
        
        acceptedKeywords.forEach { s in
            
            
            let file = write("REQUEST\n\(s)", to: "testFile")
            let rp = MarkdownPairParser("testFile", bundle: bundle)
            do {
                XCTAssertNoThrow(try rp.parseFile(at: file))
            } catch {
                XCTFail()
            }
        }
        
    }
    
    func testWrongRequestKeywords() {
        
        let notValidKeywords = ["+data: a", "+status: 200"]
        
        notValidKeywords.forEach { s in
            
            
            let file = write("REQUEST\n\(s)", to: "testFile")
            let rp = MarkdownPairParser("testFile", bundle: bundle)
            
            do {
                XCTAssertThrowsError(try rp.parseFile(at: file))
            } catch {
                print("all good")
            }
        }
        
    }
    
    
    func testURLKeywordWithQuotes() {
        
        
        let file = write("REQUEST\n+url:`www.url.com`", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        let response = try! rp.parseFile(at: file)
        
        XCTAssertEqual(response.url, "www.url.com")
        
    }
    
    func testURLKeywordNoQuotes() {
        
        
        let file = write("REQUEST\n+url: www.url.com", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        let response = try! rp.parseFile(at: file)

        XCTAssertEqual(response.url, "www.url.com")
        
    }
    
    func testURLKeywordEmpty() {
        
        
        let file = write("REQUEST\n+url: ", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        XCTAssertThrowsError(try rp.parseFile(at: file))
        
    }
    
    func testMethodKeywordNoQuotes() {
        
        
        let file = write("REQUEST\n+method: POST", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        let response = try! rp.parseFile(at: file)
        
        
        XCTAssertEqual(response.method, "POST")
        
    }
    
    func testMethodKeywordWithQuotes() {
        
        
        let file = write("REQUEST\n+method: `POST`", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        let response = try! rp.parseFile(at: file)
        
        XCTAssertEqual(response.method, "POST")
        
    }
    
    func testMethodKeywordEmpty() {
        
        
        let file = write("REQUEST\n+method: ", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        XCTAssertThrowsError(try rp.parseFile(at: file))
        
        
    }
    
    func testStatusKeywordNoQuotes() {
        
        
        let file = write("RESPONSE\n+status: 400", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        let response = try! rp.parseFile(at: file)

        
        XCTAssertEqual(response.status, 400)
        
    }
    
    func testStatusKeywordWithQuotes() {
        
        
        let file = write("RESPONSE\n+status: `400`", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        let response = try! rp.parseFile(at: file)
        
        XCTAssertEqual(response.status, 400)
        
    }
    
    func testStatusKeywordEmpty() {
        
        
        let file = write("RESPONSE\n+status: ", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        XCTAssertThrowsError(try rp.parseFile(at: file))
        
        
    }
    
    func testDataKeywordNoQuotes() {
        
        
        let file = write("RESPONSE\n+data: someData", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        let response = try! rp.parseFile(at: file)
        
        XCTAssertEqual(response.data, "someData")
        
    }
    
    func testDataKeywordWithQuotes() {
        
        
        let file = write("RESPONSE\n+data: ```someData```", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        let response = try! rp.parseFile(at: file)
        
        
        
        
        
        XCTAssertEqual(response.data, "someData")
        
    }
    
    func testMultilineDataKeywordNoQuotes() {
        
        
        let file = write("RESPONSE\n+data: someData\nmoreData\nevenmoredata", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        
        let response = try! rp.parseFile(at: file)

        XCTAssertEqual(response.data, "someData\nmoreData\nevenmoredata")
        
    }
    
    func testultilineDataKeywordWithQuotes() {
        
        
        let file = write("RESPONSE\n+data: ```someData\nmoreData\nevenmoredata```", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        let response = try! rp.parseFile(at: file)
        
        
        
        XCTAssertEqual(response.data, "someData\nmoreData\nevenmoredata")
        
    }

    
    func testDataKeywordEmpty() {
        
        
        let file = write("RESPONSE\n+data: ", to: "testFile")
        let rp = MarkdownPairParser("testFile", bundle: bundle)
        
        let response = try! rp.parseFile(at: file)

        XCTAssertNil(response.data)
        
        
    }
    
    
    func write(_ content: String, to file: String) -> String {
        
        let bundle = Bundle(for:TestPlanParserTests.self).bundlePath
        let path = URL(fileURLWithPath: bundle, isDirectory: true).appendingPathComponent(file)
        
        _ = try! content.write(to: path, atomically: true, encoding: .utf8)
        
        return path.relativePath
        
    }
    
}
