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

}
