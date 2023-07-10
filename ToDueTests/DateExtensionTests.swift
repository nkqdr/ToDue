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
    
    func testRemoveTimestamp() throws {
        var date = try! Date("2023-07-10T12:25:52Z", strategy: .iso8601)
        var dateWithoutTimestamp = date.removeTimeStamp!
        XCTAssertEqual(dateWithoutTimestamp.ISO8601Format(), "2023-07-09T22:00:00Z")
        
        date = try! Date("2023-07-10T22:00:00Z", strategy: .iso8601)
        dateWithoutTimestamp = date.removeTimeStamp!
        XCTAssertEqual(dateWithoutTimestamp.ISO8601Format(), "2023-07-10T22:00:00Z")
        
        date = try! Date("2023-07-10T22:0:01Z", strategy: .iso8601)
        dateWithoutTimestamp = date.removeTimeStamp!
        XCTAssertEqual(dateWithoutTimestamp.ISO8601Format(), "2023-07-10T22:00:00Z")
    }

}
