//
//  PageTestModel.swift
//  QuizManagerTests
//
//  Created by Steven Curtis on 25/07/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation
@testable import QuizManager


public struct PageTestModel: PageProtocol, Codable, Equatable, CustomStringConvertible {
    public var topic: String
    
    public var page: String
    
    public init?(fields: [String]) {
        name = fields[0]
        topic = "test topic"
        page = "test page|"
    }
    
    init(name: String) {
        self.name = name
        topic = "test topic"
        page = "test page|"
    }
   
    public var description: String {
        return self.name
    }
    
    public let name: String

}
