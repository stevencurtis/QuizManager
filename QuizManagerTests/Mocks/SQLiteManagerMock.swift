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
}

typealias SQLiteMock = RepositoryProtocol & SQLiteManagerMockProtocol

enum Qs {
    case many
    case few
}

let q1 = Question(name: "FirstQ", question: "Hello, how are you?", qa: "Fine", qb: "Tired", qc: "Worried", qd: "Dead", solution: "1", qPic: "no pic", qTopic: "Test Topic", difficulty: "1", examboard: "AQA", tip: "Do What you feel", explainAnswer: "Doing what you feel makes sense", qSimilar: "2", wrongOne: "What were you thinking", wrongTwo: "It's wrong", wrongThree: "We are worried", wrongFour: "If you are dead how do you answer the question", reference: "No reference")

let q2 = Question(name: "SecondQ", question: "Why are you doing this quiz", qa: "You are wrong", qb: "It is fun", qc: "Something to do", qd: "This is not a fair question", solution: "2", qPic: "no pic", qTopic: "Test Topic", difficulty: "1", examboard: "AQA", tip: "Do What you think is right", explainAnswer: "Well, it is something to do", qSimilar: "2", wrongOne: "I agree you are wrong", wrongTwo: "Yes, it is fun", wrongThree: "Don't do things just because it is something to do", wrongFour: "For an unfair question there is no answer", reference: "No reference")

let q3 = Question(name: "ThirdQ", question: "This is the best quiz ever", qa: "You are wrong", qb: "It is fun", qc: "Something to do", qd: "This is not a fair question", solution: "2", qPic: "no pic", qTopic: "Test Topic", difficulty: "1", examboard: "AQA", tip: "Do What you think is right", explainAnswer: "Well, it is something to do", qSimilar: "2", wrongOne: "I agree you are wrong", wrongTwo: "Yes, it is fun", wrongThree: "Don't do things just because it is something to do", wrongFour: "For an unfair question there is no answer", reference: "No reference")

class SQLiteManagerMock: SQLiteMock {

    
    // provide the quizzes from the repos that you have, please

    func provideQuizzes<T>(with type: T.Type, withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Quiz<QuestionProtocol>], Error>) -> Void) where T : QuestionProtocol {
        if questions.count == 0 {
            questions.append(q1)
            questions.append(q2)
        }
        
        var anyquizzes = [Quiz<QuestionProtocol>]()
        
//        let qs = [QuestionProtocol]()
        
        let quiz = Quiz(name: "TestQuiz", questions:questions)
        
        anyquizzes.append(quiz)
        
        if !shouldFail {
            completion(.success(  anyquizzes  ))
        } else {
            let er = NSError(domain: "Could not provide quizzes", code: -1009, userInfo: nil)
            completion(.failure(er))
        }
    }
    
    
    var questions = [QuestionProtocol]()
    
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
    

    
    var shouldFail = false
    
    func setFailure(shouldFail: Bool) {
        self.shouldFail = shouldFail
    }
    
}
