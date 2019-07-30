//
//  PageManager.swift
//  QuizManagerTests
//
//  Created by Steven Curtis on 25/07/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import XCTest
@testable import QuizManager


class PageManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testNewInitializePages() {
        let expectation = XCTestExpectation(description: #function)
        let rp : RepositoryProtocol?
        rp = SQLiteManagerMock()
        let pm = PageManager(repo: rp)
        pm.initializePages(with: PageTestModel.self, withCompletionHandler: { (result) in
            switch result {
                case .failure(let error):
                    print(error)
                    XCTAssertNil(error)
                case .success(let pages):
                    print ( pages[0].getName() )
                    XCTAssertEqual(1, pages.count)
                }
                expectation.fulfill()
        })
            wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testSpecificPage () {
        let expectation = XCTestExpectation(description: #function)

        let rp : SQLiteMock?
        rp = SQLiteManagerMock()
        rp?.setPages(pages: Ps.many)
        let pm = PageManager(repo: rp)
        pm.initializePages(with: PageTestModel.self, withCompletionHandler: { (result) in
            switch result {
            case .failure(let error):
                print(error)
                XCTAssertNil(error)
            case .success(let pages):
                print ( pages[0].getName() )
                XCTAssertEqual( pm.getSpecificPage(with: PageTestModel.self, locationNumber: 0), p1 )
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1.0)

        
    }
    
    
    func testSpecificPageTwo () {
        let expectation = XCTestExpectation(description: #function)
        
        let rp : SQLiteMock?
        rp = SQLiteManagerMock()
        rp?.setPages(pages: Ps.many)
        let pm = PageManager(repo: rp)
        pm.initializePages(with: PageTestModel.self, withCompletionHandler: { (result) in
            switch result {
            case .failure(let error):
                print(error)
                XCTAssertNil(error)
            case .success(let pages):
                print ( pages.count, pages[0].getPages()[1].name)
                XCTAssertEqual( pm.getSpecificPage(with: PageTestModel.self, locationNumber: 1), p2 )
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSubheadings () {
        let rp : SQLiteMock?
        rp = SQLiteManagerMock()
        rp?.setPages(pages: Ps.many)
        let pm = PageManager(repo: rp)
        
        pm.initializePages(with: PageTestModel.self, withCompletionHandler: nil)
        
        
        XCTAssertEqual( pm.getSubHeadings(with: PageTestModel.self), ["TestPages"] )
    }
    
    func testMajorHeadings() {
        let rp : SQLiteMock?
        rp = SQLiteManagerMock()
        rp?.setPages(pages: Ps.many)
        let pm = PageManager(repo: rp)
        
        XCTAssertEqual( pm.getMajorHeadings(), ["Test"] )    }

}
