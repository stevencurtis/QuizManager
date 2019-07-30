//
//  QuizManager.swift
//  sociologygcse
//
//  Created by Steven Curtis on 23/04/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation

public protocol QuizManagerProtocol {
    func getAllQs<T: QuestionProtocol>(with type: T.Type, _ forDatabase: String?, withCompletionHandler completion: @escaping (Result<[T], Error>) -> Void)
    func getNextQFromSet<T: QuestionProtocol>(with type: T.Type) -> (question: T, answers: [String])?
    func answeredQFromSet<T: QuestionProtocol>(with type: T.Type, withAnswer answers: [Int], recordAnswer: Bool?, withCompletionHandler completion: @escaping (Result<(isCorrect: Bool, isLast: Bool), Error>) -> Void)
    func getQuestionSetProgress<T: QuestionProtocol>(with type: T.Type) -> (question: [QuestionProtocol], correctAnswerIndex: [String], givenAnswers: [String], givenAnswerIndex: [String])?
    func getQuestionSetStats<T: QuestionProtocol> (with type: T.Type) -> (numberOfQs: Int, answered: Int, totalCorrect: Int, totalWrong: Int)?
    func setQuestionsRandomly<T>(with type: T.Type, numberQuestions no: Int, shufflebool: Bool, shufflefunction: (([(question: Any, answerGiven: Int?)]) -> (() -> [(question: Any, answerGiven: Int?)]))?, withCompletionHandler completion: @escaping (Result<Bool, Error>) -> Void) where T : QuestionProtocol
    func clearQuestionSet()
    func getCurrentQuestion<T: QuestionProtocol>(with type: T.Type) -> T?
    func getSpecificQuestionFromSet<T: QuestionProtocol>(with type: T.Type, locationNumber: Int) -> T?
}

public class QuizManager {
    
    // Chosen as <Any> because storing QuestionProtocol does not allow all the fields to be stored
    // <T> is not possible and therefore we store it as "Any"
    private var anyquizzes = [Quiz<Any>]()
    var repos = [RepositoryProtocol]()
    
    /// Current set of questions. question and answer given
    private var questionSet : [(question: Any, answerGiven: Int?)]?
    
    private var currentQuestion : QuestionProtocol?
    
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
    
    public func getCurrentQuestion<T: QuestionProtocol>(with type: T.Type) -> T? {
        if let currentQuestion = currentQuestion {
            return currentQuestion as? T
        }
        return getNextQFromSet(with: type)?.question
    }
    
    public func getSpecificQuestionFromSet<T: QuestionProtocol>(with type: T.Type, locationNumber: Int) -> T? {
        
        guard let questionSet = questionSet else { return nil }
        
        if locationNumber <= questionSet.count {
            let question = questionSet[locationNumber]
            return question.question as? T
        }

        return nil
    }
    
    public func clearQuestionSet() {
        if var _ = questionSet {
            questionSet!.removeAll()
        }
    }
    
    /// should be able to get all Qs for a specific quiz. Quizzes guarentee to have questions
    // TODO: Name the databases
    public func getAllQs<T: QuestionProtocol>(with type: T.Type, _ forDatabase: String? = nil, withCompletionHandler completion: @escaping (Result<[T], Error>) -> Void) {
        
        if anyquizzes.count == repos.count {
            if let allQs = anyquizzes.first!.getQuestions() as? [T]
            {
                completion(.success( allQs ) )
                //completion(.success( quizzes.map{$0.getQuestions()}.flatMap{ $0 } ) )
            }
            
            let error = NSError(domain:"", code:-2000, userInfo:[ NSLocalizedDescriptionKey: "Unknown error"]) as Error; completion(.failure(error))
            return
        }
        
        // if we have not got all of the quizzes, reinitialize
        // should be easy to find which of the repos that we need to reinitialize - through the name then append the results
        // this will add more quizzes into the array
        initializeQuizzes(with: type, withCompletionHandler: {result in
            switch result {
            case .failure(let error): completion(.failure(error) )
            case .success(let result):
                var qs = [T]()
                for res in result {
                    qs += res.getQuestions()
                }
                self.anyquizzes.append( Quiz(name: "TestQuiz", questions: qs)  )
                completion(.success( result.map{$0.getQuestions()}.flatMap{ $0 } ) )
            }
        })
    }
    
    /// returns n questions from the total questions
    private func nQuestions<T: QuestionProtocol>(with type: T.Type, n: Int, shuffle: Bool = false) -> [QuestionProtocol]? {
        var totalqs = [Any]()
        for res in anyquizzes {
            if let questionsAsArrayT = res.getQuestions() as? [T]
            { totalqs += questionsAsArrayT.compactMap { $0 } }
        }
        
        guard n <= totalqs.count else { return nil }

        if shuffle {
            totalqs = totalqs.shuffled()
        }
        
        var timesAnswered = 0
        var qs = [QuestionProtocol]()
        while qs.count < n {
            let newQ = Array(totalqs.filter{($0 as? T)?.answered == timesAnswered}.prefix(n)) as! [T]
            qs += newQ
            timesAnswered += 1
        }
        return qs
    }
    
    // return the next question from the current question set
    //    public func getNextQFromSet() -> (question: QuestionProtocol, answers: [String])? {
    public func getNextQFromSet<T: QuestionProtocol>(with type: T.Type) -> (question: T, answers: [String])? {
        
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
        }
        return nil
    }
    
    
    // this can only be called ONCE for each question!! - so needs a check
    // TODO: Get this to work properly for multiple answers: need to know the format of this that I previously used in the databases
    /// answer the currently presented question
    public func answeredQFromSet<T: QuestionProtocol>(with type: T.Type, withAnswer answers: [Int], recordAnswer: Bool? = true, withCompletionHandler completion: @escaping (Result<(isCorrect: Bool, isLast: Bool), Error>) -> Void) {
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
                
                if let qsAnswer = questionSet?[q.offset].question {
                    let ans = qsAnswer as! T
                    if ( (answer + 1) == Int(ans.solution) ) {
                        completion(.success( (true, last)))
                        return
                    } else {
                        completion(.success( (false, last)))
                        return
                    }
                }
                let er = NSError(domain: "Could not provide quizzes", code: -1009, userInfo: nil)
                completion(.failure(er))
                return
            }
        }
    }
    
    // questions are set from the interface produce randomquestions
    private func setQuestionSet<T: QuestionProtocol>(with type: T.Type,_ no: Int, shuffle: Bool, shufflefunction : (([(question: Any, answerGiven: Int?)]) -> (() -> [(question: Any, answerGiven: Int?)])) = Array.shuffled) {
        


        if let randomQs = nQuestions(with: type,  n: no, shuffle: shuffle) {
            let number = randomQs.count
            let firstPart = randomQs as [Any]
            let secondPart = Array<Int?>(repeating: nil, count: number )
            questionSet = shufflefunction( Array( zip( firstPart, secondPart) ) ) ()
        }
    }
    
    /// get the progress through the question set
    // correctAnswerIndex are the Srings of the index of the correct answers
    // givenAnswers are the Strings of the Index of the user given answers
    // returns 1-indexed arrays
    public func getQuestionSetProgress<T: QuestionProtocol>(with type: T.Type) -> (question: [QuestionProtocol], correctAnswerIndex: [String], givenAnswers: [String], givenAnswerIndex: [String])? {
        guard questionSet != nil && questionSet!.count > 0 else {return nil}
        let correctans = questionSet!.map{ ($0.question as! T).solution }
        var correctAnswers = [String]()
        var givenAnswersIndex = [String]()
        for q in questionSet!.enumerated() {
            if let question = q.element.question as? T {
                let answers = [(question).qa, (question).qb, (question).qc, (question).qd]
                correctAnswers.append(answers[(q.element.question as! T).answered])
                if let answerGiven = q.element.answerGiven {
                    givenAnswersIndex.append( String( abs( answerGiven) ) )
                }
            }
        }
        return ( questionSet!.map{ $0.question as! T } ,correctans,correctAnswers,givenAnswersIndex)
    }
    
    
    public func getQuestionSetStats<T: QuestionProtocol> (with type: T.Type) -> (numberOfQs: Int, answered: Int, totalCorrect: Int, totalWrong: Int)? {
        guard questionSet != nil && questionSet!.count > 0 else {return nil}
        let number = questionSet!.count
        let answered = questionSet!.filter{ $0.answerGiven != nil && abs($0.answerGiven ?? -1) >= 0 }.count
        let correct: [(Int?, Int?)]
        correct = Array ( zip(questionSet!.map{ Int( ($0.question as? T)?.solution ?? "") }, questionSet!.map{ $0.answerGiven }) )
        let correctAnswers = correct.filter{ abs($0.0 ?? 10) == ( ( abs($0.1 ?? 10) ) )}.count
        let wrong = number - correctAnswers
        return (numberOfQs: number, answered: answered, totalCorrect: correctAnswers, totalWrong: wrong)
    }
    
    // Set up the questionset quiz with random questions
    

        
    public func setQuestionsRandomly<T>(with type: T.Type, numberQuestions no: Int, shufflebool: Bool, shufflefunction: (([(question: Any, answerGiven: Int?)]) -> (() -> [(question: Any, answerGiven: Int?)]))?, withCompletionHandler completion: @escaping (Result<Bool, Error>) -> Void) where T : QuestionProtocol {
        
        if anyquizzes.count == repos.count {
            setQuestionSet(with: type, no, shuffle: shufflebool, shufflefunction: shufflefunction!)
            completion(.success( true ) )
            return
        }
        // if we have not got all of the quizzes, reinitialize
        // should be easy to find which of the repos that we need to reinitialize - through the name then append the results
        // this will add more quizzes into the array
        initializeQuizzes(with: type, withCompletionHandler: {result in
            switch result {
            case .failure(let error):
                completion(.failure(error) )
            case .success:
                self.setQuestionSet(with: type, no, shuffle: shufflebool, shufflefunction: shufflefunction!)
                if self.questionSet == nil || self.questionSet!.count > no {
                    completion(.failure(NSError(domain: "Insufficient questions", code: -1, userInfo: nil)) )
                } else {
                    completion(.success( true ) )
                }
            }
        })
    }
    
    public func initializeQuizzes<T: QuestionProtocol>(with type: T.Type, withCompletionHandler completion: ((Result<[Quiz<T>], Error>) -> Void)?)  {
        for repo in repos {

            repo.provideQuizzes(with: type, withdbpathfunc: nil, withCompletionHandler: {result in
                switch result {
                case .failure(let error):
                    if let completion = completion {
                        completion(.failure(error) )
                    }
                case .success(let result):
                    
                    var qs = [T]()
                    for res in result {
                        qs += res.getQuestions()
                    }
                    self.anyquizzes.append( Quiz(name: "Quiz", questions: qs)  )
                    
                    if let completion = completion {
                        completion(.success(result))
                    }
                }
            })
        }
    }
    
}



extension QuizManager : QuizManagerProtocol { }
