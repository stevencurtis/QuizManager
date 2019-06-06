//
//  GameManager.swift
//  sociologygcse
//
//  Created by Steven Curtis on 26/04/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation

//public protocol QMProtocol {
//    func getAllQs<T: QuestionProtocol>(with type: T.Type, _ forDatabase: String?, withCompletionHandler completion: @escaping (Result<[QuestionProtocol], Error>) -> Void)
//    func getNextQFromSet() -> (question: QuestionProtocol, answers: [String])?
//    func answeredQFromSet(withAnswer answers: [Int], recordAnswer: Bool?,withCompletionHandler completion: @escaping (Result<(isCorrect: Bool, isLast: Bool), Error>) -> Void)
//    func getQuestionSetProgress() -> (question: [QuestionProtocol], correctAnswerIndex: [String], givenAnswers: [String], givenAnswerIndex: [String])?
//    func getQuestionSetStats() -> (numberOfQs: Int, answered: Int, totalCorrect: Int, totalWrong: Int)?
//    func setQuestionsRandomly<T: QuestionProtocol>(with type: T.Type, numberQuestions no: Int, shufflefunction: (([(question: QuestionProtocol, answerGiven: Int?)]) -> (() -> [(question: QuestionProtocol, answerGiven: Int?)]))?, withCompletionHandler completion: @escaping (Result<Bool, Error>) -> Void)
//    func clearQuestionSet()
//    func getCurrentQuestion() -> QuestionProtocol?
//}

public protocol GameManagerProtocol {
    func switchAnswerer()
    func startGame<T: QuestionProtocol>(with type: T.Type, players: Int, withCompletionHandler completion: @escaping (Result<(question: QuestionProtocol, answers: [String])?, Error>) -> Void)
    func nextQ() -> QuestionProtocol?
    func currentQ() -> QuestionProtocol?
    func rollDice(randFuncDie1: ((ClosedRange<Int>) -> Int), randFuncDie2: ((ClosedRange<Int>) -> Int)) -> (dice1: Int, dice2: Int, losePointsTurn: Bool, losePointsGame: Bool)
    func getButtonStatus() -> (ButtonStatus)
    func getScores () -> (GameScores)
    func getCurrentPlayer() -> (Int)
    func getNumberPlayers() -> (Int)
    func scores() -> (GameScores)
    func answer(_ answers: [Int], withCompletionHandler completion: @escaping (Result<(scores: GameScores, correct: Bool), Error>) -> Void)
}

public struct GameScores: Equatable {
    public var player1ScoreTurn: Int
    public var player2ScoreTurn: Int
    public var player1ScoreGame: Int
    public var player2ScoreGame: Int
}

public struct ButtonStatus: Equatable {
    public var rollEnabled: Bool
    public var answerEnabled: Bool
    public var passEnabled: Bool
}

public class GameManager {
    private var quizMngr : QuizManagerProtocol!
    
    private var player1ScoreTurn: Int = 0
    private var player2ScoreTurn: Int = 0
    
    // currentPlayer is zero-indexed
    private var currentPlayer: Int = 0
    
    private var player1ScoreGame: Int = 0
    private var player2ScoreGame: Int = 0
    
    private var rollEnabled : Bool = true
    private var answerEnabled : Bool = false
    private var passEnabled : Bool = false
    
    private var dice1 : Int = 0
    private var dice2 : Int = 0
    
    
    public init(quizManager: QuizManagerProtocol?) {
        quizMngr = quizManager
    }
    
    init (quizManager: QuizManagerProtocol?, dice1: Int, dice2: Int, player1ScoreTurn: Int, player2ScoreTurn: Int, player1ScoreGame: Int, player2ScoreGame: Int, currentPlayer: Int) {
        quizMngr = quizManager
        self.dice1 = dice1
        self.dice2 = dice2
        self.player1ScoreTurn = player1ScoreTurn
        self.player1ScoreGame = player1ScoreGame
        self.player2ScoreTurn = player2ScoreTurn
        self.player2ScoreGame = player2ScoreGame
        self.currentPlayer = currentPlayer
    }
    
    public func getCurrentPlayer() -> (Int) {
        return currentPlayer
    }
    
    public func getNumberPlayers() -> (Int) {
        return numberPlayers
    }
    
    // roll the dice. We will then update the UI as needed (ui update needs player 1 and player 2 scores)
    public func rollDice(randFuncDie1: ((ClosedRange<Int>) -> Int) = Int.random, randFuncDie2: ((ClosedRange<Int>) -> Int) = Int.random) -> (dice1: Int, dice2: Int, losePointsTurn: Bool, losePointsGame: Bool) {
        rollEnabled = false
        answerEnabled = true
        passEnabled = true
        
        dice1 = randFuncDie1(0...5)
        dice2 = randFuncDie2(0...5)
        
        var isTurnZero = false
        var isGameZero = false
        
        if ((dice1 == 1) && (dice2 == 1)) {
            // lose all of your points
            if (currentPlayer == 0) {
                player1ScoreGame = 0
            } else {
                player2ScoreGame = 0
            }
            isGameZero = true
        } else if ((dice1 == 1) || (dice2 == 1)) {
            // lose all your points for that turn
            if (currentPlayer == 0) {
                player1ScoreTurn = 0
            } else {
                player2ScoreTurn = 0
            }
            
            isTurnZero = true
        }

        return (dice1, dice2, isTurnZero, isGameZero)
    }
    
    // Roll the dice. Answer the questions - and get points if you answer the question correctly.
    // Roll a 1 - lose your points for that turn. Roll a double 1 - lose all your points.
    
    public func nextQ() -> QuestionProtocol? {
       return quizMngr.getNextQFromSet()?.question
    }
    
    public func currentQ() -> QuestionProtocol? {
        return quizMngr.getCurrentQuestion()
    }
    
    public func scores() -> (GameScores) {
        return GameScores(player1ScoreTurn: player1ScoreTurn, player2ScoreTurn: player2ScoreTurn, player1ScoreGame: player1ScoreGame, player2ScoreGame: player2ScoreGame)
    }
    
    // func getButtonStatus() -> (rollEnabled: Bool, answerEnabled: Bool, passEnabled: Bool) {
    public func getButtonStatus() -> (ButtonStatus) {
        return ButtonStatus(rollEnabled: rollEnabled, answerEnabled: answerEnabled, passEnabled: passEnabled)
    }
    
    func passButton() {
        swapPlayer()
    }
    
    var numberPlayers = 1
    
    public func startGame<T: QuestionProtocol>(with type: T.Type, players: Int, withCompletionHandler completion: @escaping (Result<(question: QuestionProtocol, answers: [String])?, Error>) -> Void) {
        guard players <= 2 else { fatalError("One or two players only") }
        numberPlayers = players
        quizMngr.setQuestionsRandomly(with: type, numberQuestions: 100, shufflefunction: Array.shuffled, withCompletionHandler: {result in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success: completion(.success(self.quizMngr.getNextQFromSet()))
            }
        })

    }
    
    func addToTurnScore() {
        if currentPlayer == 0 {
            player1ScoreTurn += (dice1 + dice2)
        } else {
            player2ScoreTurn += (dice1 + dice2)
        }
    }
    
    func addToGameScore() {
        if currentPlayer == 0 {
            player1ScoreGame += player1ScoreTurn
            player1ScoreTurn = 0
        } else {
            player2ScoreGame += player1ScoreTurn
            player2ScoreTurn = 0
        }
        swapPlayer()
    }
    
    func swapPlayer() {
        if currentPlayer == 0 {
            currentPlayer = 1
        } else {
            currentPlayer = 0
        }
    }
    
    private func resetButtonState(){
        rollEnabled = false
        answerEnabled = true
        passEnabled = true
    }
    
    /// TODO: get it to work for an array of answers
    public func answer(_ answers: [Int], withCompletionHandler completion: @escaping (Result<(scores: GameScores, correct: Bool), Error>) -> Void) {
        quizMngr.answeredQFromSet(withAnswer: answers, recordAnswer: false, withCompletionHandler: {
            result in
            switch result {
            case .failure: print ("error")
            case .success(let result):
                if result.isCorrect {
                    self.addToTurnScore()
                    self.resetButtonState()
                } else {
                    self.addToGameScore()
                    self.swapPlayer()
                }
                completion(.success((self.scores(), result.isCorrect)))
            }
        })
    }
    
    public func getScores () -> (GameScores) {
        return GameScores(player1ScoreTurn: player1ScoreTurn, player2ScoreTurn: player2ScoreTurn, player1ScoreGame: player1ScoreGame, player2ScoreGame: player2ScoreGame)
    }
    
    public func switchAnswerer() {
        // TODO: fix the current scores
        swapPlayer()
        rollEnabled = false
        answerEnabled = true
        passEnabled = false
    }

}

extension GameManager: GameManagerProtocol { }

