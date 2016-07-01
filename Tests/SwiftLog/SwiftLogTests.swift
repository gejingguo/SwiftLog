import XCTest
@testable import SwiftLog

class SwiftLogTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //XCTAssertEqual(SwiftLog().text, "Hello, World!")
        let logger = Logger(level: LogLevel.Info)
        let fileTarget = FileLogTarget(filePath: "./test.log", maxFileSize: 10000)
        logger.append(target: fileTarget)
        
        logger.debug("hello", "world", 5)
        logger.info("hello", "world", 5)
        logger.error("hello world 5")
        logger.fatal("hello world 6")
        print("hello here")
    }


    static var allTests : [(String, (SwiftLogTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
