//
//  PageProtocol.swift
//  QuizManager
//
//  Created by Steven Curtis on 25/07/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation

public protocol PageProtocol: BaseDataProtocol {
    init?(fields: [String] )
    var topic: String {get}
    var page: String {get}
    var name: String {get}

}
