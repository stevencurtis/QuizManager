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
    func providePages(withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[[String]], Error>) -> Void) {
        //
    }
    
    func provideQuizzes(withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[[String]], Error>) -> Void) {
        //
    }
    
    func provideDbVersion(withdbpathfunc: (() -> String?)?) -> Int {
        //
        return -1
    }
    
//    func provideQuizzes<T>(with type: T.Type, withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Quiz<T>], Error>) -> Void) where T : QuestionProtocol {
//        //
//    }
    
//    func providePages<T>(with type: T.Type, withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Page<T>], Error>) -> Void) where T : PageProtocol {
//        //
//    }
    
//    func provideQuizzes<T>(with type: T.Type, withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Quiz<T>], Error>) -> Void) where T : QuestionProtocol {
//        //
//    }

    

    




    
    
}
