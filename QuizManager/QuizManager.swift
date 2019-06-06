//
//  QuizManager.swift
//  sociologygcse
//
//  Created by Steven Curtis on 23/04/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation

public protocol QuizManagerProtocol {
    func getAllQs<T: QuestionProtocol>(with type: T.Type, _ forDatabase: String?, withCompletionHandler completion: @escaping (Result<[QuestionProtocol], Error>) -> Void)
    func getNextQFromSet() -> (question: QuestionProtocol, answers: [String])?
    func answeredQFromSet(withAnswer answers: [Int], recordAnswer: Bool?,withCompletionHandler completion: @escaping (Result<(isCorrect: Bool, isLast: Bool), Error>) -> Void)
    func getQuestionSetProgress() -> (question: [QuestionProtocol], correctAnswerIndex: [String], givenAnswers: [String], givenAnswerIndex: [String])?
    func getQuestionSetStats() -> (numberOfQs: Int, answered: Int, totalCorrect: Int, totalWrong: Int)?
    func setQuestionsRandomly<T: QuestionProtocol>(with type: T.Type, numberQuestions no: Int, shufflefunction: (([(question: QuestionProtocol, answerGiven: Int?)]) -> (() -> [(question: QuestionProtocol, answerGiven: Int?)]))?, withCompletionHandler completion: @escaping (Result<Bool, Error>) -> Void)
    func clearQuestionSet()
    func getCurrentQuestion() -> QuestionProtocol?
}

public class QuizManager {
    
    private var quizzes = [Quiz<QuestionProtocol>]()
    
    var repos = [RepositoryProtocol]()
    
    public init(repo: RepositoryProtocol? = nil) {
        if let repo = repo {
            repos.append(repo)
        }
    }
    
    // Create multi repo
    public init(repositories: [RepositoryProtocol]) {
        for repo in repositories {
            repos.append(repo)
        }
    }
    
    /// Current set of questions. question and answer given
    private var questionSet : [(question: QuestionProtocol, answerGiven: Int?)]?
    
    private var currentQuestion : QuestionProtocol?
    
    public func getCurrentQuestion() -> QuestionProtocol? {
        if let currentQuestion = currentQuestion {
            return currentQuestion
        }
        return getNextQFromSet()?.question
    }
    
    public func clearQuestionSet() {
        if var _ = questionSet {
         questionSet!.removeAll()
        }
    }

    /// should be able to get all Qs for a specific quiz. Quizzes guarentee to have questions
    // TODO: Name the databases
    public func getAllQs<T: QuestionProtocol>(with type: T.Type, _ forDatabase: String? = nil, withCompletionHandler completion: @escaping (Result<[QuestionProtocol], Error>) -> Void) {
    
        if quizzes.count == repos.count {
            completion(.success( quizzes.map{$0.getQuestions()}.flatMap{ $0 } ) )
            return
        }
        
        // if we have not got all of the quizzes, reinitialize
        // should be easy to find which of the repos that we need to reinitialize - through the name then append the results
        // this will add more quizzes into the array
        initializeQuizzes(with: type, withCompletionHandler: {result in
            switch result {
            case .failure(let error): fatalError(error.localizedDescription)
            case .success(let result): self.quizzes = result; completion(.success( result.map{$0.getQuestions()}.flatMap{ $0 } ) )
            }
        })
    }
    
    /// returns n questions from the total questions
    private func nQuestions(n: Int) -> [QuestionProtocol]? {
        let totalqs = quizzes.map{$0.getQuestions()}.flatMap{ $0 }
        guard n <= totalqs.count else { return nil }
        var timesAnswered = 0
        var qs = [QuestionProtocol]()
        while qs.count < n {
            qs += totalqs.filter{$0.answered == timesAnswered}.prefix(n)
            timesAnswered += 1
        }
        return qs
    }
    
    // return the next question from the current question set
    public func getNextQFromSet() -> (question: QuestionProtocol, answers: [String])? {
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
    

    // this can only be called ONCE for each question!! - so needs a check
    
    // TODO: Get this to work properly for multiple answers: need to know the format of this that I previously used in the databases
    /// answer the currently presented question
    public func answeredQFromSet(withAnswer answers: [Int], recordAnswer: Bool? = true, withCompletionHandler completion: @escaping (Result<(isCorrect: Bool, isLast: Bool), Error>) -> Void) {
        var last = false
        let answer = answers[0]
        guard questionSet != nil else { return completion(.failure (NSError(domain: "No question to be answered", code: -1, userInfo: nil)) ) }
        
        for q in questionSet!.enumerated() {
            if q.element.answerGiven == nil {
                if q.offset == questionSet!.count - 1 {
                    last = true
                }
                
                if recordAnswer! {
                    // we store the answer ans 1 - indexed, and the database has these stored as 1-indexed too
                    questionSet![q.offset].answerGiven = answer + 1
                } else {
                    // make it negative so we can then "temporarily" store the answer
                    questionSet![q.offset].answerGiven = -abs(answer + 1)
                }
                
                if ( (answer + 1) == Int(questionSet![q.offset].question.solution)!) {
                    completion(.success( (true, last)))
                } else {
                    completion(.success( (false, last)))
                }
                return
            }
        }
    }
    
    // questions are set from the interface produce randomquestions
    private func setQuestionSet(_ no: Int, shufflefunction : (([(question: QuestionProtocol, answerGiven: Int?)]) -> (() -> [(question: QuestionProtocol, answerGiven: Int?)])) = Array.shuffled) {
        if let randomQs = nQuestions(n: no) {
            questionSet = shufflefunction( Array( zip(randomQs, Array(repeating: nil, count: randomQs.count) ) ) ) ()
        }
    }
    
    /// get the progress through the question set
    // correctAnswerIndex are the Srings of the index of the correct answers
    // givenAnswers are the Strings of the Index of the user given answers
    // returns 1-indexed arrays
    public func getQuestionSetProgress() -> (question: [QuestionProtocol], correctAnswerIndex: [String], givenAnswers: [String], givenAnswerIndex: [String])? {
        guard questionSet != nil && questionSet!.count > 0 else {return nil}
        
        let correctans = questionSet!.map{ $0.question.solution }
        var correctAnswers = [String]()
        var givenAnswersIndex = [String]()
        for q in questionSet!.enumerated() {
            let answers = [q.element.question.qa, q.element.question.qb, q.element.question.qc, q.element.question.qd]
            correctAnswers.append(answers[q.element.question.answered])
            if let answerGiven = q.element.answerGiven {
                givenAnswersIndex.append( String( abs( answerGiven) ) )
            }
        }
        return ( questionSet!.map{ $0.question } ,correctans,correctAnswers,givenAnswersIndex)
    }

    
    public func getQuestionSetStats() -> (numberOfQs: Int, answered: Int, totalCorrect: Int, totalWrong: Int)? {
        guard questionSet != nil && questionSet!.count > 0 else {return nil}
        let number = questionSet!.count
        let answered = questionSet!.filter{ $0.answerGiven != nil && $0.answerGiven ?? 0 >= 0 }.count
        let correct = Array ( zip(questionSet!.map{ Int( $0.question.solution) }, questionSet!.map{ $0.answerGiven }) )
        let correctAnswers = correct.filter{ $0.0 == ( ($0.1 ?? 10) + 1)}.count
        let wrong = number - correctAnswers
        return (numberOfQs: number, answered: answered, totalCorrect: correctAnswers, totalWrong: wrong)
    }
    
    // Set up the questionset quiz with random questions
    public func setQuestionsRandomly<T: QuestionProtocol> (with type: T.Type, numberQuestions no: Int = 5, shufflefunction: (([(question: QuestionProtocol, answerGiven: Int?)]) -> (() -> [(question: QuestionProtocol, answerGiven: Int?)]))? = Array.shuffled, withCompletionHandler completion: @escaping (Result<Bool, Error>) -> Void) {
        if quizzes.count == repos.count {
            setQuestionSet(no, shufflefunction: shufflefunction!)
            completion(.success( true ) )
            return
        }
        // if we have not got all of the quizzes, reinitialize
        // should be easy to find which of the repos that we need to reinitialize - through the name then append the results
        // this will add more quizzes into the array
        initializeQuizzes(with: type, withCompletionHandler: {result in
            switch result {
            case .failure(let error): fatalError(error.localizedDescription)
            case .success:
                self.setQuestionSet(no, shufflefunction: shufflefunction!)
                if self.questionSet == nil || self.questionSet!.count > no {
                    completion(.failure(NSError(domain: "Insufficient questions", code: -1, userInfo: nil)) )
                } else {
                    completion(.success( true ) )
                }
            }
        })
    }
    
    public func initializeQuizzes<T: QuestionProtocol>(with type: T.Type, withCompletionHandler completion: ((Result<[Quiz<QuestionProtocol>], Error>) -> Void)?)  {
        for repo in repos {
            repo.provideQuizzes(with: type, withdbpathfunc: nil, withCompletionHandler: {result in
                switch result {
                case .failure(let error):
                    if let completion = completion {
                        completion(.failure(error) )
                    }
                case .success(let result):
                    self.quizzes += result;
                    if let completion = completion {
                         completion(.success(self.quizzes))
                    }
                }
            })
        }
    }
}

extension QuizManager : QuizManagerProtocol {}
