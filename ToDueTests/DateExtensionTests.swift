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
    
    func testIsSameDayAs() throws {
        let calendar = Calendar.current
        
        var date = calendar.date(from: DateComponents(year: 2023, month: 7, day: 8, hour: 4, minute: 54))!
        var otherDate = calendar.date(from: DateComponents(year: 2023, month: 7, day: 8, hour: 1, minute: 24))!
        XCTAssertTrue(date.isSameDayAs(otherDate))
        
        date = calendar.date(from: DateComponents(year: 2023, month: 7, day: 4, hour: 4, minute: 54))!
        otherDate = calendar.date(from: DateComponents(year: 2023, month: 7, day: 8, hour: 1, minute: 24))!
        XCTAssertFalse(date.isSameDayAs(otherDate))
        
        date = calendar.date(from: DateComponents(year: 2023, month: 7, day: 4))!
        otherDate = calendar.date(from: DateComponents(year: 2023, month: 7, day: 4, hour: 1, minute: 24))!
        XCTAssertTrue(date.isSameDayAs(otherDate))
        
        date = calendar.date(from: DateComponents(year: 2022, month: 7, day: 4))!
        otherDate = calendar.date(from: DateComponents(year: 2023, month: 7, day: 4))!
        XCTAssertFalse(date.isSameDayAs(otherDate))
        
        date = calendar.date(from: DateComponents(year: 2023, month: 6, day: 4))!
        otherDate = calendar.date(from: DateComponents(year: 2023, month: 7, day: 4))!
        XCTAssertFalse(date.isSameDayAs(otherDate))
    }

}
