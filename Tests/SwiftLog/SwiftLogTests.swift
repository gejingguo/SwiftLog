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
        let dateFileTarget = DateFileLogTarget(filePath: "./test1.log", dateType: .Hourly);
        logger.append(target: dateFileTarget)
        
        logger.debug("hello", "world", 1)
        logger.info("hello", "world", 2)
        logger.warn("hello warn")
        logger.error("hello world 3")
        logger.fatal("hello world 4")
        print("hello here")
    }


    static var allTests : [(String, (SwiftLogTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
