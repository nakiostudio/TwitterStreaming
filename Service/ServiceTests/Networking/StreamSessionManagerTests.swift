//
//  Created by Carlos Vidal Pallin on 15/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import XCTest
@testable import Service

class StreamSessionManagerTests: XCTestCase {

    private let streamQueue = dispatch_queue_create("com.nakiostudio.stream", nil)
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testThatTheExpectedNumberOfMessagesIsReceivedBeforeExpectationTimesOut() {
        // given
        let expectation = self.expectationWithDescription("stream manager")
        let manager = StreamSessionManager(dispatchQueue: self.streamQueue)
        let request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:9001/connect")!)
        request.HTTPMethod = "GET"
        var counter = 0
        
        // when
        manager.connect(withRequest: request, responseClosure: { (data, error) in
            if let data = data, _ = String(data: data, encoding: 4) {
                counter += 1
            }
            else if let _ = error {
                XCTFail()
            }
          
            // then
            if counter >= 2 {
                expectation.fulfill()
            }
        })
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testThatCloseErrorIsTriggeredWhenTaskIsInvalidatedAndPropertyIsUnSet() {
        // given
        let expectation = self.expectationWithDescription("stream manager")
        let manager = StreamSessionManager(dispatchQueue: self.streamQueue)
        let request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:9001/connect")!)
        request.HTTPMethod = "GET"
        
        // when
        manager.connect(withRequest: request, responseClosure: { (data, error) in
            if let error = error {
                XCTAssertTrue(error.localizedDescription == "cancelled")
                XCTAssertNil(manager.currentTask)
                expectation.fulfill()
            }
        })
        
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            manager.disconnect()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testThatCloseErrorIsTriggeredWhenSessionBecomesInvalid() {
        // given
        let expectation = self.expectationWithDescription("stream manager")
        let manager = StreamSessionManager(dispatchQueue: self.streamQueue)
        let request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:9001/connect")!)
        request.HTTPMethod = "GET"
        
        // when
        manager.connect(withRequest: request, responseClosure: { (data, error) in
            if let error = error {
                XCTAssertTrue(error.localizedDescription == "cancelled")
                XCTAssertNil(manager.currentTask)
                expectation.fulfill()
            }
        })
        
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            manager.session.invalidateAndCancel()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testThatConnectionClosedClosureIsTriggeredEvenWhenTaskIsInvalidatedStraightAway() {
        // given
        let expectation = self.expectationWithDescription("stream manager")
        let manager = StreamSessionManager(dispatchQueue: self.streamQueue)
        let request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:9001/connect")!)
        request.HTTPMethod = "GET"
        
        // when
        manager.connect(withRequest: request, responseClosure: { (data, error) in
            if let error = error {
                XCTAssertTrue(error.localizedDescription == "cancelled")
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        })
        manager.disconnect()
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    
}
