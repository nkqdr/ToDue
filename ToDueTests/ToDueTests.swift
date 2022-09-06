//
//  ToDueTests.swift
//  ToDueTests
//
//  Created by Niklas Kuder on 06.09.22.
//

import XCTest
import Combine

class ToDueTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCreateTask() {
        let editor = TaskEditor()
        XCTAssertNil(editor.task)
        XCTAssertTrue(editor.saveButtonDisabled, "Save button must be disabled in the beginning.")
        editor.changeTitle(newValue: "Some task")
        XCTAssertFalse(editor.saveButtonDisabled, "Save button must be enabled when title has a valid value.")
        editor.changeTitle(newValue: "")
        XCTAssertTrue(editor.saveButtonDisabled, "Save button must be disabled when task has an invalid value.")
        editor.changeTitle(newValue: "Test task")
        editor.taskDueDate = Date()
        editor.taskDescription = "Some description"
        let tasks: AnyPublisher<[Task], Never> = [].publisher.eraseToAnyPublisher()
        let sut = TaskManager(taskPublisher: tasks)
        sut.saveTask(editor)
        print(sut.tasks)
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
