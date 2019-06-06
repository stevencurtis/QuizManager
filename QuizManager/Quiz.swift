//
//  AnyQuiz.swift
//  QuizManager
//
//  Created by Steven Curtis on 03/06/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation

public class Quiz<T> {
    // each quiz contains a set of anything that conforms to the question protocol (nothing!)
    private let questions : [T]
    
    private let name : String
    
    init(name: String, questions: [T]) {
        self.name = name
        self.questions = questions
    }
    
    public func getQuestions() -> [T] {
        return questions
    }
    
    func getName() -> String {
        return name
    }
    
    
}
