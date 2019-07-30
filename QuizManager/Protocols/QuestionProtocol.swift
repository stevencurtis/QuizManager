//
//  QuestionProtocol.swift
//  QuizManager
//
//  Created by Steven Curtis on 03/06/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation

public protocol QuestionProtocol : BaseDataProtocol {
    init?(fields: [String] )
    var description: String {get}
    var question: String {get}
    var solution: String {get}
    var explainAnswer: String {get}
    var answered: Int {get set}
    var qa: String {get}
    var qb: String {get}
    var qc: String {get}
    var qd: String {get}
}
