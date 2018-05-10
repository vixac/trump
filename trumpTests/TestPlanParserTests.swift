
import XCTest
@testable import Trump

class TestPlanParserTests: XCTestCase {
    
    func testComments() {
        
        
        _ = write("# A Comment:", to: "testFile")
        let tpp = MarkdownTestPlanParser("testFile", bundle : Bundle(for:TestPlanParserTests.self) )
        let plans = try! tpp.loadTestPlan()
        XCTAssertNotNil(plans)
        XCTAssertEqual(plans.count, 1)
        
    }
    
    func testDoubleComments() {
        
        
        let file = write("## A double Comment:", to: "testFile")
        let tpp = MarkdownTestPlanParser("testFile", bundle : Bundle(for:TestPlanParserTests.self) )
        
        let plans = try! tpp.parseFile(at: file)
        
        XCTAssertNotNil(plans)
        XCTAssertEqual(plans.count, 1)
        
    }

    
    func testCase() {
        
        
        let file = write("CASE", to: "testFile")
        let tpp = MarkdownTestPlanParser("testFile", bundle : Bundle(for:TestPlanParserTests.self) )
        
        let plans = try! tpp.parseFile(at: file)
        
        XCTAssertNotNil(plans)
        XCTAssertEqual(plans.count, 1)
        
    }
    
    func testFileKeywordFail() {

        let file = write("+ file: `f`\n", to: "FileKeyword")
        let tpp = MarkdownTestPlanParser("FileKeyword", bundle : Bundle(for:TestPlanParserTests.self) )
        
        XCTAssertThrowsError(try tpp.parseFile(at: file))
        
    }
    
    func testFileKeywordSuccess() {
        
        
        let file = write("CASE\n+ file: `ff`\n", to: "FileKeyword")
        let tpp = MarkdownTestPlanParser("FileKeyword", bundle : Bundle(for:TestPlanParserTests.self) )
        
        let r = try! tpp.parseFile(at: file)
        XCTAssertNotNil(r)
        XCTAssertEqual(r.count, 1)
        
        let parserResult = r.first
        XCTAssertEqual(parserResult?.count, 1)
        XCTAssertEqual(parserResult?.filePath, "ff")
        
    }
    
    func testFileKeywordEmpty() {
        
        
        let file = write("+ file:\n", to: "FileKeyword")
        let tpp = MarkdownTestPlanParser("FileKeyword", bundle : Bundle(for:TestPlanParserTests.self) )
        XCTAssertThrowsError(try tpp.parseFile(at: file))
        
    }
    
    func testCountKeywordFail() {
        
        
        let file = write("+ count: 1\n", to: "FileKeyword")
        let tpp = MarkdownTestPlanParser("FileKeyword", bundle : Bundle(for:TestPlanParserTests.self) )
        
        XCTAssertThrowsError(try tpp.parseFile(at: file))
        
    }
    
    func testCountKeywordSuccess() {
        
        
        let file = write("CASE\n+ count: 2\n", to: "FileKeyword")
        let tpp = MarkdownTestPlanParser("FileKeyword", bundle : Bundle(for:TestPlanParserTests.self) )
        
        let r = try! tpp.parseFile(at: file)
        XCTAssertNotNil(r)
        XCTAssertEqual(r.count, 1)
        
        let parserResult = r.first
        XCTAssertEqual(parserResult?.count, 2)
        XCTAssertNil(parserResult?.filePath)
        
    }
    
    func testCountKeywordEmpty() {
        
        
        let file = write("+ count:\n", to: "FileKeyword")
        let tpp = MarkdownTestPlanParser("FileKeyword", bundle : Bundle(for:TestPlanParserTests.self) )
        
        XCTAssertThrowsError(try tpp.parseFile(at: file))
        
    }
    
    func testMultipleCases() {
        
        
        let file = write("CASE\n+ file: `f1`\nCASE\n+ file: `f2`\n", to: "FileKeyword")
        let tpp = MarkdownTestPlanParser("FileKeyword", bundle : Bundle(for:TestPlanParserTests.self) )
        
        let r = try! tpp.parseFile(at: file)
        XCTAssertNotNil(r)
        XCTAssertEqual(r.count, 2)
        
        let parserResult1 = r[0]
        XCTAssertEqual(parserResult1.count, 1)
        XCTAssertEqual(parserResult1.filePath, "f1")

        let parserResult2 = r[1]
        XCTAssertEqual(parserResult2.count, 1)
        XCTAssertEqual(parserResult2.filePath, "f2")

    }
    
    func testMultipleCasesWithCount() {
        
        
        let file = write("CASE\n+ file: `f1`\n+ count: 2\nCASE\n+ file: `f2`\n+ count: 3\n", to: "FileKeyword")
        let tpp = MarkdownTestPlanParser("FileKeyword", bundle : Bundle(for:TestPlanParserTests.self) )
        let r = try! tpp.parseFile(at: file)
        XCTAssertNotNil(r)
        XCTAssertEqual(r.count, 2)
        
        let parserResult1 = r[0]
        XCTAssertEqual(parserResult1.count, 2)
        XCTAssertEqual(parserResult1.filePath, "f1")
        
        let parserResult2 = r[1]
        XCTAssertEqual(parserResult2.count, 3)
        XCTAssertEqual(parserResult2.filePath, "f2")
        
    }
    
    func testNoResponse() {
        
        
        let file = write("RESPONSE\n + file: `f`", to: "testFile")
        let tpp = MarkdownTestPlanParser("testFile", bundle : Bundle(for:TestPlanParserTests.self) )
        
        XCTAssertThrowsError(try tpp.parseFile(at: file))
        
    }
    
    
    func write(_ content: String, to file: String) -> String {
        
        let bundle = Bundle(for:TestPlanParserTests.self).bundlePath
        let path = URL(fileURLWithPath: bundle, isDirectory: true).appendingPathComponent(file)
        
        _ = try! content.write(to: path, atomically: true, encoding: .utf8)
        
        return path.relativePath
        
    }
    
}
