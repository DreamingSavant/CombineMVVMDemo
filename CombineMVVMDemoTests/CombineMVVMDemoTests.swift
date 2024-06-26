//
//  CombineMVVMDemoTests.swift
//  CombineMVVMDemoTests
//
//  Created by Roderick Presswood on 4/17/24.
//

import XCTest
import Combine
@testable import CombineMVVMDemo

final class CombineMVVMDemoTests: XCTestCase {
    
    var sut: QuoteViewModel!
    var quoteService: MockQuoteServiceType!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        quoteService = MockQuoteServiceType()
        sut = QuoteViewModel(quoteServiceType: quoteService)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}


class MockQuoteServiceType: QuoteServiceType {
    
    var value: AnyPublisher<Quote, Error>?
    
    func getRandomQuote() -> AnyPublisher<Quote, Error> {
        <#code#>
    }
    
}
