//
//  Question.swift
//  sociologygcse
//
//  Created by Steven Curtis on 23/04/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation
@testable import QuizManager


public struct QuestionTestModel: QuestionProtocol, Codable, Equatable, CustomStringConvertible {
    public var description: String {
        return self.question
    }
    
    public init?(fields: [String] ) {
        guard fields.count >= 18 else {
            return nil
        }
        name = fields[0]
        question = fields[1]
        qa = fields[2]
        qb = fields[3]
        qc = fields[4]
        qd = fields[5]
        solution = fields[6]
        qPic = fields[7]
        qTopic = fields[7]
        difficulty = fields[8]
        examboard = fields[9]
        tip = fields[10]
        explainAnswer = fields[11]
        qSimilar = fields[12]
        wrongOne = fields[13]
        wrongTwo = fields[14]
        wrongThree = fields[15]
        wrongFour = fields[16]
        reference = fields[17]
    }
    
    let name: String
    public let question: String // question posed
    public let qa: String
    public let qb: String
    public let qc: String
    public let qd: String
    public let solution: String
    let qPic: String
    let qTopic: String
    let difficulty: String
    let examboard: String
    let tip: String
    public let explainAnswer: String
    let qSimilar: String
    let wrongOne: String
    let wrongTwo: String
    let wrongThree: String
    let wrongFour: String
    let reference: String
    
    public var answered = 0
    
    init(name: String, question: String, qa: String, qb: String, qc: String, qd: String, solution: String, qPic: String, qTopic: String, difficulty: String, examboard: String, tip: String, explainAnswer: String, qSimilar: String, wrongOne: String, wrongTwo: String, wrongThree: String, wrongFour: String, reference: String) {
        self.name = name
        self.question = question
        self.qa = qa
        self.qb = qb
        self.qc = qc
        self.qd = qd
        self.solution = solution
        self.qPic = qPic
        self.qTopic = qTopic
        self.difficulty = difficulty
        self.examboard = examboard
        self.tip = tip
        self.explainAnswer = explainAnswer
        self.qSimilar = qSimilar
        self.wrongOne = wrongOne
        self.wrongTwo = wrongTwo
        self.wrongThree = wrongThree
        self.wrongFour = wrongFour
        self.reference = reference
    }
    
    // CodingKeys here for future decoding of JSON from API
    private enum CodingKeys: String, CodingKey{
        case name = "Number"
        case question = "Question"
        case qa = "A"
        case qb = "B"
        case qc = "C"
        case qd = "D"
        case solution = "Solution"
        case qPic = "Picture"
        case qTopic = "Topic"
        case difficulty = "Difficulty1to6"
        case examboard = "ExamBoard"
        case qSimilar = "Similarorpaid"
        case tip = "Tip"
        case explainAnswer = "Explain"
        case wrongOne = "wrongone"
        case wrongTwo = "wrongTwo"
        case wrongThree = "wrongThree"
        case wrongFour = "wrongFour"
        case reference = "Reference"
    }
    
    
}
