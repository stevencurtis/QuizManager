//
//  SQLiteManagerTests.swift
//  QuizManagerTests
//
//  Created by Steven Curtis on 02/06/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import XCTest
@testable import QuizManager

class SQLiteManagerTests: XCTestCase {
    
//    func testOpenDatabase() {
//        let sq = SQLiteManager("sociologydb")
//        let db = sq.openDatabase("sociologydb")
//        XCTAssertNotNil(db)
//    }
//    
//    func testFailOpenDatabase() {
//        let sq = SQLiteManager()
//        let db = sq.openDatabase("test")
//        XCTAssertNotNil(db)
//    }
    
    override func setUp() {
        //
    }
    
    override func tearDown() {
//        XCUIApplication().terminate()
        super.tearDown()
    }
    
    public func createTestDBPathForTest() -> String?
    {
        let b = Bundle(for: type(of: self))
        if let filepath = b.path(forResource: "sociologydb", ofType: "sqlite") {
            return filepath
        }
        fatalError("Database not found")
    }

    
    func testRead() {
        let expectation = XCTestExpectation(description: #function)
        let sq = SQLiteManager("sociologydb", tableName: "Questions")
        let _ = sq.openDatabase("sociologydb")
        sq.provideQuizzes(with: QuestionTestModel.self, withdbpathfunc: createTestDBPathForTest, withCompletionHandler: { result in
            switch result {
            case .failure (let error) : print (error)
            case .success (let data):
                let a = data[0].getQuestions().first!
                XCTAssertEqual(a.description, "Sociology is the study of society")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 3.0)

    }
    
    
//    public func testDBPages() -> String?
//    {
//        let b = Bundle(for: type(of: self))
//        if let filepath = b.path(forResource: "computingpages", ofType: "sqlite") {
//            return filepath
//        }
//        fatalError("Database not found")
//    }
//
//
//    func testReadPages() {
//        let expectation = XCTestExpectation(description: #function)
//        let sq = SQLiteManager("computingpages", tableName: "Pages")
//        let _ = sq.openDatabase("computingpages")
//        sq.providePages(with: PageTestModel.self, withdbpathfunc: testDBPages, withCompletionHandler: { result in
//            switch result {
//            case .failure (let error) : print (error)
//            case .success (let data):
//                let a = data[0].getPages().first!
//                XCTAssertEqual(a.name, "Test")
//            }
//            expectation.fulfill()
//        })
//
//        wait(for: [expectation], timeout: 3.0)
//
//    }
    
    public func testDBPages() -> String?
    {
        let b = Bundle(for: type(of: self))
        if let filepath = b.path(forResource: "computingpages", ofType: "sqlite") {
            // print (filepath)
            return filepath
        }
        fatalError("Database not found")
    }
    
    
    func testReadPages() {
        
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            print(directoryContents)
            
        } catch {
            print(error)
        }
        
        
        let expectation = XCTestExpectation(description: #function)
        let sq = SQLiteManager("computingpages", tableName: "Pages")
    //    let _ = sq.openDatabase("computingpages")
        sq.providePages(with: PageTestModel.self, withdbpathfunc: testDBPages, withCompletionHandler: { result in
            switch result {
            case .failure (let error) : print (error)
            case .success (let data):
                let a = data[0].getPages().first!
                XCTAssertEqual(a.name, "Test")
            }
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 3.0)
        
    }
    
    
    public func v1DBPages() -> String?
    {
        let b = Bundle(for: type(of: self))
        if let filepath = b.path(forResource: "sociologydbupdatepragma", ofType: "sqlite") {
            return filepath
        }
        fatalError("Database not found")
    }
    
    func testVersion() {
        let sq = SQLiteManager("computingpages", tableName: "Pages")
        XCTAssertEqual(sq.provideDbVersion(withdbpathfunc: v1DBPages), 1)

    }
    
}

