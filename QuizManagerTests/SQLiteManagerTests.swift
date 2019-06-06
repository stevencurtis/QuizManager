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
    
    func testOpenDatabase() {
        let sq = SQLiteManager()
        let db = sq.openDatabase("sociologydb")
        XCTAssertNotNil(db)
    }
    
    func testFailOpenDatabase() {
        let sq = SQLiteManager()
        let db = sq.openDatabase("test")
        XCTAssertNotNil(db)
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
        let sq = SQLiteManager("sociologydb")
        let _ = sq.openDatabase("sociologydb")
        sq.provideQuizzes(with: Question.self, withdbpathfunc: createTestDBPathForTest, withCompletionHandler: { result in
            switch result {
            case .failure (let error) : print (error)
            case .success (let data):
                let a = data[0].getQuestions().first! // as! Question
                XCTAssertEqual(a.description, "Sociology is the study of society")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 3.0)

    }
    
}

