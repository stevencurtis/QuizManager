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
    func setQuestions(questions: [QuestionProtocol])
    func setQuestions(questions: Qs)
    func setFailure(shouldFail: Bool)
    func setPages(pages: [PageProtocol])
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

let q1 = QuestionTestModel(name: "FirstQ", question: "Hello, how are you?", qa: "Fine", qb: "Tired", qc: "Worried", qd: "Dead", solution: "1", qPic: "no pic", qTopic: "Test Topic", difficulty: "1", examboard: "AQA", tip: "Do What you feel", explainAnswer: "Doing what you feel makes sense", qSimilar: "2", wrongOne: "What were you thinking", wrongTwo: "It's wrong", wrongThree: "We are worried", wrongFour: "If you are dead how do you answer the question", reference: "No reference")

let q2 = QuestionTestModel(name: "SecondQ", question: "Why are you doing this quiz", qa: "You are wrong", qb: "It is fun", qc: "Something to do", qd: "This is not a fair question", solution: "2", qPic: "no pic", qTopic: "Test Topic", difficulty: "1", examboard: "AQA", tip: "Do What you think is right", explainAnswer: "Well, it is something to do", qSimilar: "2", wrongOne: "I agree you are wrong", wrongTwo: "Yes, it is fun", wrongThree: "Don't do things just because it is something to do", wrongFour: "For an unfair question there is no answer", reference: "No reference")

let q3 = QuestionTestModel(name: "ThirdQ", question: "This is the best quiz ever", qa: "You are wrong", qb: "It is fun", qc: "Something to do", qd: "This is not a fair question", solution: "2", qPic: "no pic", qTopic: "Test Topic", difficulty: "1", examboard: "AQA", tip: "Do What you think is right", explainAnswer: "Well, it is something to do", qSimilar: "2", wrongOne: "I agree you are wrong", wrongTwo: "Yes, it is fun", wrongThree: "Don't do things just because it is something to do", wrongFour: "For an unfair question there is no answer", reference: "No reference")

let p1 = PageTestModel(name: "test1")
let p2 = PageTestModel(name: "test2")
let p3 = PageTestModel(name: "test2")


class SQLiteManagerMock: SQLiteMock {
    func provideDbVersion(withdbpathfunc: (() -> String?)?) -> Int {
        return 0
    }
    
    func providePages<T>(with type: T.Type, withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Page<T>], Error>) -> Void) where T : PageProtocol {

        var typePs = [T]()
        if pages.count == 0 {
            pages.append(p1)
            pages.append(p2)
            pages.append(p3)

        }
        typePs.append(p1 as! T)
        typePs.append(p2 as! T)
        typePs.append(p3 as! T)

        
        let content = Page(name: "TestPages", pages: typePs)
        
        if !shouldFail {
            completion(.success(  [content]  ))
        } else {
            let er = NSError(domain: "Could not provide pages", code: -1009, userInfo: nil)
            completion(.failure(er))
        }
    }
    
    var pages = [PageProtocol]()


    
    var questions = [QuestionProtocol]()

    
    // provide the quizzes from the repos that you have, please

    func provideQuizzes<T>(with type: T.Type, withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Quiz<T>], Error>) -> Void) where T : QuestionProtocol {
        
        var typeQs = [T]()
        
        if questions.count == 0 {
            questions.append(q1)
            questions.append(q2)
        }
        
        typeQs.append(q1 as! T)
        typeQs.append(q2 as! T)
        

        let quiz = Quiz(name: "TestQuiz", questions: typeQs)


        if !shouldFail {
            completion(.success(  [quiz]  ))
        } else {
            let er = NSError(domain: "Could not provide quizzes", code: -1009, userInfo: nil)
            completion(.failure(er))
        }
    }
    
    func setQuestions(questions: [QuestionProtocol]) {
        self.questions = questions
    }
    
    func setQuestions(questions: Qs) {
        switch questions {
        case .many:
            self.questions = [q1, q2, q3]
        default:
            self.questions = [q1, q2]
        }
    }
    
    
    func setPages(pages: [PageProtocol]) {
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
