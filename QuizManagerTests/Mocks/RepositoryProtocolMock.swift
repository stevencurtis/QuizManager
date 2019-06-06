//
//  RepositoryProtocolMock.swift
//  QuizManagerTests
//
//  Created by Steven Curtis on 31/05/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation
@testable import QuizManager

class RepositoryProtocolMock: RepositoryProtocol {
    func provideQuizzes<T>(with type: T.Type, withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Quiz<QuestionProtocol>], Error>) -> Void) where T : QuestionProtocol {
        //
    }
    




    
    
}
