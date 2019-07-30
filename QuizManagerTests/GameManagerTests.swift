//
//  GameManagerTests.swift
//  GameManagerTests
//
//  Created by Steven Curtis on 03/06/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import XCTest
@testable import QuizManager

class GameManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    /// unsure about why this error is generated at the moment
    func testStartGame() {
        let expectation = XCTestExpectation(description: #function)
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm)
        
        gm.startGame(with: QuestionTestModel.self, players: 1, withCompletionHandler: { result in
            switch result {
            case .failure (let error):
                let custerr = error as NSError
                XCTAssertEqual(custerr.code, -2000)
            case .success (let data):
                XCTAssertNotNil(data)
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testGetNumberPlayersOne() {
        let expectation = XCTestExpectation(description: #function)
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm)
        
        gm.startGame(with: QuestionTestModel.self, players: 1, withCompletionHandler: { result in
            switch result {
            case .failure (let error):
                XCTAssertNil(error)
            case .success:
                XCTAssertEqual(gm.getNumberPlayers(), 1)
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testGetNumberPlayersTwo() {
        let expectation = XCTestExpectation(description: #function)
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm)
        gm.startGame(with: QuestionTestModel.self, players: 2, withCompletionHandler: { result in
            switch result {
            case .failure (let error):
                XCTAssertNil(error)
            case .success:
                XCTAssertEqual(gm.getNumberPlayers(), 2)
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testInitialButtonStatement() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 4, dice2: 5, player1ScoreTurn: 5, player2ScoreTurn: 2, player1ScoreGame: 1, player2ScoreGame: 2, currentPlayer: 1)
        let buttonStatus: (ButtonStatus) = ButtonStatus(rollEnabled: true, answerEnabled: false, passEnabled: false)
        XCTAssertEqual(gm.getButtonStatus(), buttonStatus )
    }
    
    func testSwapPlayerOneToZero() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 4, dice2: 5, player1ScoreTurn: 5, player2ScoreTurn: 2, player1ScoreGame: 1, player2ScoreGame: 2, currentPlayer: 1)
        gm.swapPlayer()
        XCTAssertEqual(gm.getCurrentPlayer(), 0)
    }
    
    func testSwapPlayerZeroToOne() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 4, dice2: 5, player1ScoreTurn: 5, player2ScoreTurn: 2, player1ScoreGame: 1, player2ScoreGame: 2, currentPlayer: 0)
        gm.swapPlayer()
        XCTAssertEqual(gm.getCurrentPlayer(), 1)
    }
    
 // swapping player does not update the scores
//    func testSwapPlayerMidTurn() {
//        let qm = QuizManagerMock()
//        let gm = GameManager(quizManager: qm, dice1: 4, dice2: 5, player1ScoreTurn: 5, player2ScoreTurn: 0, player1ScoreGame: 1, player2ScoreGame: 0, currentPlayer: 0)
//        gm.swapPlayer()
//        XCTAssertEqual(gm.scores(), GameScores(player1ScoreTurn: 0, player2ScoreTurn: 5, player1ScoreGame: 1, player2ScoreGame: 0))
//    }
//
    
    func testAddToGameScoreOne() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 4, dice2: 5, player1ScoreTurn: 5, player2ScoreTurn: 2, player1ScoreGame: 1, player2ScoreGame: 2, currentPlayer: 0)
        gm.addToGameScore()
        let expectedAnswer = GameScores(player1ScoreTurn: 0, player2ScoreTurn: 2, player1ScoreGame: 6, player2ScoreGame: 2)
        XCTAssertEqual(gm.getScores(), expectedAnswer)
    }
    
    func testAddToGameScoreTwo() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 4, dice2: 5, player1ScoreTurn: 5, player2ScoreTurn: 2, player1ScoreGame: 1, player2ScoreGame: 2, currentPlayer: 1)
        gm.addToGameScore()
        let expectedAnswer = GameScores(player1ScoreTurn: 5, player2ScoreTurn: 0, player1ScoreGame: 1, player2ScoreGame: 7)
        XCTAssertEqual(gm.getScores(), expectedAnswer)
    }
    
    func testSwitchAnswererOne() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 4, dice2: 5, player1ScoreTurn: 5, player2ScoreTurn: 2, player1ScoreGame: 1, player2ScoreGame: 2, currentPlayer: 1)
        gm.switchAnswerer()
        XCTAssertEqual(gm.getCurrentPlayer(), 0)
    }
    
    func testSwitchAnswererTwo() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 4, dice2: 5, player1ScoreTurn: 5, player2ScoreTurn: 2, player1ScoreGame: 1, player2ScoreGame: 2, currentPlayer: 1)
        gm.switchAnswerer()
        XCTAssertEqual(gm.getCurrentPlayer(), 0)
    }
    
    func testInitialScores() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm)
        gm.startGame(with: QuestionTestModel.self, players: 1, withCompletionHandler: { result in })
        let zeroScores = GameScores(player1ScoreTurn: 0, player2ScoreTurn: 0, player1ScoreGame: 0, player2ScoreGame: 0)
        XCTAssertEqual(gm.getScores(), zeroScores)
    }
    
    func testAddDicePlayerOne() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 4, dice2: 3, player1ScoreTurn: 2, player2ScoreTurn: 0, player1ScoreGame: 3, player2ScoreGame: 4, currentPlayer: 0)
        let _ = gm.rollDice(randFuncDie1: { _ in return 2 }, randFuncDie2: { _ in return 3 })
        
        gm.addToTurnScore()
        let resultantScores = GameScores(player1ScoreTurn: 9, player2ScoreTurn: 0, player1ScoreGame: 3, player2ScoreGame: 4)
        XCTAssertEqual(gm.getScores(), resultantScores)
    }

    func testAddDicePlayerTwo() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 4, dice2: 5, player1ScoreTurn: 0, player2ScoreTurn: 0, player1ScoreGame: 32, player2ScoreGame: 12, currentPlayer: 1)
        let _ = gm.rollDice(randFuncDie1: { _ in return 4 }, randFuncDie2: { _ in return 5 })
        
        gm.addToTurnScore()
        let resultantScores = GameScores(player1ScoreTurn: 0, player2ScoreTurn: 11, player1ScoreGame: 32, player2ScoreGame: 12)
        XCTAssertEqual(gm.getScores(), resultantScores)
    }
    
    /// Double 1's for both die mean lose your score
    func testRollDiceDoubleOnes() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm)
        
        let result = gm.rollDice(randFuncDie1: { _ in
            return 0
        }, randFuncDie2: { _ in
            return 0
        })
        
        _ = GameScores(player1ScoreTurn: 0, player2ScoreTurn: 0, player1ScoreGame: 0, player2ScoreGame: 0)
        XCTAssertEqual(result.losePointsGame, true)
    }
    
    func testRollDiceDoubleOnesCalculate() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 5, dice2: 4, player1ScoreTurn: 9, player2ScoreTurn: 0, player1ScoreGame: 5, player2ScoreGame: 12, currentPlayer: 0)
        gm.addToTurnScore()
        
        let result = GameScores(player1ScoreTurn: 18, player2ScoreTurn: 0, player1ScoreGame: 5, player2ScoreGame: 12)
        XCTAssertEqual(gm.getScores(), result)
    }
    
    /// A single 1 means lose your points for that turn
    func testRollDiceFirstOne() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm)
        
        let result = gm.rollDice(randFuncDie1: { _ in
            return 0
        }, randFuncDie2: { _ in
            return 3
        })
        
        let _ = GameScores(player1ScoreTurn: 0, player2ScoreTurn: 0, player1ScoreGame: 0, player2ScoreGame: 0)
        XCTAssertEqual(result.losePointsTurn, true)
    }
    

    func testAddToGameScore() {
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 5, dice2: 4, player1ScoreTurn: 9, player2ScoreTurn: 0, player1ScoreGame: 5, player2ScoreGame: 12, currentPlayer: 0)
        gm.addToGameScore()
        
        let result = GameScores(player1ScoreTurn: 0, player2ScoreTurn: 0, player1ScoreGame: 14, player2ScoreGame: 12)
        XCTAssertEqual(gm.getScores(), result)
    }
    
    /// A single 1 means lose your points for that turn
    func testRollDiceSecondOne() {
        
    }
    
    func testScoresAnswerQuestionCorrectly() {
        let expectation = XCTestExpectation(description: #function)
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 2, dice2: 2, player1ScoreTurn: 5, player2ScoreTurn: 0, player1ScoreGame: 12, player2ScoreGame: 0, currentPlayer: 0)
        gm.answer(with: QuestionTestModel.self, [0], withCompletionHandler: { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
            case .success (let calculatedScores):
                let scores = GameScores(player1ScoreTurn: 9, player2ScoreTurn: 0, player1ScoreGame: 12, player2ScoreGame: 0)
                XCTAssertEqual(calculatedScores.scores, scores)
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.5)
    }
    
    
//    func testDeliverNewQuestionAnswerQuestionCorrectly() {
//        let expectation = XCTestExpectation(description: #function)
//        let qm = QuizManagerMock()
//        let gm = GameManager(quizManager: qm, dice1: 2, dice2: 2, player1ScoreTurn: 5, player2ScoreTurn: 0, player1ScoreGame: 12, player2ScoreGame: 0, currentPlayer: 0)
//
//        gm.startGame(with: Question.self, players: 1, withCompletionHandler: {_ in })
//        
//        let firstQ = gm.currentQ(with: Question.self)
//        gm.answer(with: Question.self, [0], withCompletionHandler: { result in
//            switch result {
//            case .failure(let error):
//                XCTAssertNotNil(error)
//            case .success (let calculatedScores):
//                let nextQ =  gm.nextQ(with: Question.self)
//
//                XCTAssertNotEqual(firstQ?.question, nextQ?.question)
//
//            }
//            expectation.fulfill()
//        })
//        wait(for: [expectation], timeout: 0.5)
//    }
    
    
    func testScoresAnswerQuestionIncorrectly() {
        let expectation = XCTestExpectation(description: #function)
        let qm = QuizManagerMock()
        let gm = GameManager(quizManager: qm, dice1: 2, dice2: 2, player1ScoreTurn: 5, player2ScoreTurn: 0, player1ScoreGame: 12, player2ScoreGame: 0, currentPlayer: 0)
        gm.answer(with: QuestionTestModel.self, [1], withCompletionHandler: { result in
            switch result {
            case .failure (let error):
                XCTAssertNotNil(error)
            case .success (let calculatedScores):
                let scores = GameScores(player1ScoreTurn: 0, player2ScoreTurn: 0, player1ScoreGame: 17, player2ScoreGame: 0)
                XCTAssertEqual(calculatedScores.scores, scores)
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }

    
}

extension ClosedRange {
    public static func noRand(in range: ClosedRange<Int>) -> Int {
        return 0
    }
}
