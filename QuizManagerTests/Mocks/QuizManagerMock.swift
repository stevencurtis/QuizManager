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

    
    
    /// Current set of questions. question and answer given
    private var questionSet : [(question: QuestionProtocol, answerGiven: Int?)]?
    
    private var currentQuestion : QuestionProtocol?

    
    func getNextQFromSet() -> (question: QuestionProtocol, answers: [String])? {
        guard let questionSet = questionSet else { return nil }
        
        for q in questionSet.enumerated() {
            // ignore the "temporary" answerGiven
            // TODO: consider how we will store the temporary answers
            if q.element.answerGiven == nil {
                currentQuestion = q.element.question
                let question = q.element.question
                let answers = [question.qa, question.qb, question.qc, question.qd]
                return (q.element.question, answers)
            }
        }
        return nil
    }
    
    func getQuestionSetProgress() -> (question: [QuestionProtocol], correctAnswerIndex: [String], givenAnswers: [String], givenAnswerIndex: [String])? {
        return nil
    }
    
    
    func setQuestionsRandomly<T>(with type: T.Type, numberQuestions no: Int, shufflefunction: (([(question: QuestionProtocol, answerGiven: Int?)]) -> (() -> [(question: QuestionProtocol, answerGiven: Int?)]))?, withCompletionHandler completion: @escaping (Result<Bool, Error>) -> Void) where T : QuestionProtocol {
        let questions : [QuestionProtocol] = [q1,q2]
        questionSet = Array(zip(questions, Array(repeating: nil, count: questions.count)))
        completion(.success( true ) )
    }
    
    func getCurrentQuestion() -> QuestionProtocol? {
        return nil
    }
    
    func getAllQs<T>(with type: T.Type, _ forDatabase: String?, withCompletionHandler completion: @escaping (Result<[QuestionProtocol], Error>) -> Void) where T : QuestionProtocol {
        //
    }
    
    var answers = [0]
    
    func setCorrectAnswers(answers: [Int]) {
        self.answers = answers
    }

    
    func answeredQFromSet(withAnswer answers: [Int], recordAnswer: Bool?, withCompletionHandler completion: @escaping (Result<(isCorrect: Bool, isLast: Bool), Error>) -> Void) {
        
        if self.answers == answers {
            completion(.success((true, false)))
        } else {
            completion(.success((false, false)))

        }
        
        return
    }
    
    
    func getQuestionSetStats() -> (numberOfQs: Int, answered: Int, totalCorrect: Int, totalWrong: Int)? {
        return nil
    }
    
    func clearQuestionSet() {
        return
    }
    
    
    
}
