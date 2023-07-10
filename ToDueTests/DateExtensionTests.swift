//
//  ToDueTests.swift
//  ToDueTests
//
//  Created by Niklas Kuder on 10.07.23.
//

import XCTest

final class DateExtensionTests: XCTestCase {
    
    func testDateExtensionStartOfMonth() throws {
        var date = Calendar.current.date(from: DateComponents(year: 2023, month: 7, day: 8))!
        var actualStartOfMonth = Calendar.current.date(from: DateComponents(year: 2023, month: 7, day: 1))!
        var startOfMonth = date.startOfThisMonth
        XCTAssertEqual(startOfMonth, actualStartOfMonth)
        
        date = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 31))!
        actualStartOfMonth = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        startOfMonth = date.startOfThisMonth
        XCTAssertEqual(startOfMonth, actualStartOfMonth)
        
        date = Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 1))!
        actualStartOfMonth = Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 1))!
        startOfMonth = date.startOfThisMonth
        XCTAssertEqual(startOfMonth, actualStartOfMonth)
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
