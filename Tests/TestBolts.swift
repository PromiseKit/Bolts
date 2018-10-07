import PromiseKit
import PMKBolts
import XCTest
import Bolts

class TestBolts: XCTestCase {
    func test() {
        let ex = expectation(description: "")

        let value = { NSString(string: "1") }

        firstly { () -> Promise<Void> in
            return Promise()
        }.then { _ -> BFTask<NSString> in
            return BFTask(result: value())
        }.done { obj in
            XCTAssertEqual(obj, value())
            ex.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

//////////////////////////////////////////////////////////// Cancellation

extension TestBolts {
    func testCancel() {
        let ex = expectation(description: "")

        let value = { NSString(string: "1") }
        var task: BFTask<NSString>?
        
        let p = firstly { () -> CancellablePromise<Void> in
            return CancellablePromise()
        }
        p.then { _ -> BFTask<NSString> in
            task = BFTask(result: value())
            p.cancel()
            return task!
        }.done { obj in
            XCTAssertEqual(obj, value())
            XCTFail()
        }.catch(policy: .allErrors) {
            $0.isCancelled ? ex.fulfill() : XCTFail()
        }

        waitForExpectations(timeout: 1)
    }
}

