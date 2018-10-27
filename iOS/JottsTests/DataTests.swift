//
//  DataTests.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import XCTest
@testable import Jotts

class DataTests: XCTestCase {
    
    func testClassesEmpty() {
        do {
            let core = try ObjectCore()
        
            let classes = try core.classes()
        
            XCTAssertEqual(classes.count, 0, "Should not be be any classes by default")
        } catch {
            XCTFail()
        }
    }
    
    func testNewClassroom() {
        do {
            let core = try ObjectCore()
            
            let classroom = core.newClassroom()
            
            XCTAssertNotNil(classroom)
            XCTAssertNotNil(classroom.schedule)
            
            XCTAssertEqual(classroom.schedule!.count, 1, "Should have single schedule for first class")
            
            let classes = try core.classes()
            
            XCTAssertEqual(classes.count, 1, "Should include new class in classes()")
            XCTAssertEqual(classes[0], classroom, "Should be created class in classes()")
        } catch {
            XCTFail()
        }
    }
    
    func testNewClassroomInvalid() {
        do {
            let core = try ObjectCore()
            
            let classroom = core.newClassroom()
            
            try classroom.validate()
            
            XCTFail()
        } catch let error as NSError {
            XCTAssertNotNil(error)
        }
    }
    
}
