//
//  SQLiteManagerMock.swift
//  QuizManagerTests
//
//  Created by Steven Curtis on 01/06/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation
@testable import QuizManager

protocol SQLiteManagerMockProtocol {
    func setQuestions(questions: [[String]])
    func setQuestions(questions: Qs)
    func setFailure(shouldFail: Bool)
    func setPages(pages: [[String]])
    func setPages(pages: Ps)
}

typealias SQLiteMock = RepositoryProtocol & SQLiteManagerMockProtocol

enum Qs {
    case many
    case few
}

enum Ps {
    case many
    case few
}

// solution 1
let q1 = ["FirstQ","1 question","1","2","3","4","1","1","1","1","1","1","1","1","1","1","1","1","1"]

// solution 1
let q2 = ["SECOND","2 question","1","2","3","4","1","1","1","1","1","1","1","1","1","1","1","1","1"]

// solution 2
let q3 = ["THIRD","3 question","1","2","3","4","2","1","1","1","1","1","1","1","1","1","1","1","1"]

let p1 = ["test1"]
let p2 = ["test2"]
let p3 = ["test3"]

class SQLiteManagerMock: SQLiteMock {

    // provide the quizzes from the repos that you have, please
    func providePages(withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[[String]], Error>) -> Void) {
//        var typePs = [T]()
        if pages.count == 0 {
            pages.append(p1)
            pages.append(p2)
            pages.append(p3)

        }
//        typePs.append(p1 as! T)
//        typePs.append(p2 as! T)
//        typePs.append(p3 as! T)

        // let content = Page(name: "TestPages", pages: typePs)

        if !shouldFail {
            completion(.success(  pages  ))
        } else {
            let er = NSError(domain: "Could not provide pages", code: -1009, userInfo: nil)
            completion(.failure(er))
        }
    }
    
    func provideQuizzes(withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[[String]], Error>) -> Void) {
        if questions.count == 0 {
//            questions.append(q1)
//            questions.append(q2)
//            questions.append([["FirstQ"],["Hello, how are you?"]])
//            questions.append([["FirstQ"],["Hello, how are you?"]])
            questions = [["FirstQ","1 question","1","2","3","4","1","1","1","1","1","1","1","1","1","1","1","1","1"],["SECOND","2 question","1","2","3","3","1","1","1","1","1","1","1","1","1","1","1","1","1"]]
        }

//        typeQs.append(q1 as! T)
//        typeQs.append(q2 as! T)

        if !shouldFail {
//            completion(.success(  [quiz]  ))
            completion(.success(  questions ))

        } else {
            let er = NSError(domain: "Could not provide quizzes", code: -1009, userInfo: nil)
            completion(.failure(er))
        }
    }
    
    func provideDbVersion(withdbpathfunc: (() -> String?)?) -> Int {
        return 0
    }

    var pages = [[String]]()
    var questions = [[String]]()


    func setQuestions(questions: [[String]]) {
        self.questions = questions
    }
    
    func setQuestions(questions: Qs) {
        switch questions {
        case .many:
            self.questions = [q1, q2, q3]
        default:
            print ()
            self.questions = [q1, q2]
        }
    }
    
    
    func setPages(pages: [[String]]) {
        self.pages = pages
    }
    
    func setPages(pages: Ps) {
        switch pages {
        case .many:
            self.pages = [p1, p2, p3]
        default:
            self.pages = [p1, p2]
        }
    }

    
    var shouldFail = false
    
    func setFailure(shouldFail: Bool) {
        self.shouldFail = shouldFail
    }
    
}
