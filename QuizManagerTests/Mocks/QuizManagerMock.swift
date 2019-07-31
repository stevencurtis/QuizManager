//
//  QuizManagerMock.swift
//  QuizManagerTests
//
//  Created by Steven Curtis on 02/06/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

@testable import QuizManager


//typealias QuizManagerMockProtocol = QMProtocol

protocol QuizManagerMockProtocol {
    func setCorrectAnswers(answers: [Int])
}

class QuizManagerMock : QuizManagerProtocol {
    func getSpecificQuestionFromSet<T>(with type: T.Type, locationNumber: Int) -> T? where T : QuestionProtocol {
        return nil
    }


    
    
    /// Current set of questions. question and answer given
    private var questionSet : [(question: Any, answerGiven: Int?)]?
    private var currentQuestion : QuestionProtocol?
    
    func getNextQFromSet<T>(with type: T.Type) -> (question: T, answers: [String])? where T : QuestionProtocol {
        guard let questionSet = questionSet else { return nil }
        for q in questionSet.enumerated() {
            // ignore the "temporary" answerGiven
            // TODO: consider how we will store the temporary answers
            
            
            if q.element.answerGiven == nil {
                if let question = q.element.question as? T {
                    currentQuestion = question
                    let answers = [question.qa, question.qb, question.qc, question.qd]
                    return (question, answers)
                }
            }
//            if q.element.answerGiven == nil {
//                currentQuestion = q.element.question as! T
//                let question = q.element.question
//                let answers = [question.qa, question.qb, question.qc, question.qd]
//                return (q.element.question as! T, answers)
//            }
//            
            
        }
        return nil
    }
    
    func getQuestionSetProgress<T>(with type: T.Type) -> (question: [QuestionProtocol], correctAnswerIndex: [String], givenAnswers: [String], givenAnswerIndex: [String])? where T : QuestionProtocol {
        return nil
    }
    
    func setQuestionsRandomly<T>(with type: T.Type, numberQuestions no: Int, shufflebool: Bool, shufflefunction: (([(question: Any, answerGiven: Int?)]) -> (() -> [(question: Any, answerGiven: Int?)]))?, withCompletionHandler completion: @escaping (Result<Bool, Error>) -> Void) where T : QuestionProtocol {
//        let questions : [QuestionProtocol] = [q1,q2]
        let questions : [[String]] = [q1,q2]
//        questionSet = Array(zip(questions, Array(repeating: nil, count: questions.count)))
        
        var qs = [T]()
        for q in questions {
            if let question = T.init(fields: q) {
                qs.append(question)
            }
        }
        
        questionSet =  shufflefunction!( Array( zip( qs as [Any], Array<Int?>(repeating: nil, count: questions.count ) ) ) ) ()
        
        completion(.success( true ) )
    }
    
    func getCurrentQuestion<T>(with type: T.Type) -> T? where T : QuestionProtocol {
        return nil
    }
    
    func getAllQs<T>(with type: T.Type, _ forDatabase: String?, withCompletionHandler completion: @escaping (Result<[T], Error>) -> Void) where T : QuestionProtocol {
        //
    }
    
    var answers = [0]
    
    func setCorrectAnswers(answers: [Int]) {
        self.answers = answers
    }

    
    func answeredQFromSet<T>(with type: T.Type, withAnswer answers: [Int], recordAnswer: Bool?, withCompletionHandler completion: @escaping (Result<(isCorrect: Bool, isLast: Bool), Error>) -> Void) where T : QuestionProtocol {
        if self.answers == answers {
            completion(.success((true, false)))
        } else {
            completion(.success((false, false)))
        }
        return
    }
    
    func getQuestionSetStats<T>(with type: T.Type) -> (numberOfQs: Int, answered: Int, totalCorrect: Int, totalWrong: Int)? where T : QuestionProtocol {
        return nil
    }
    
    func clearQuestionSet() {
        return
    }
    
}
