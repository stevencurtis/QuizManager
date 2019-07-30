//
//  Page.swift
//  QuizManager
//
//  Created by Steven Curtis on 25/07/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation



public class Page<T> {
    private let pages : [T]
    private let name : String
    
    init(name: String, pages: [T]) {
        self.name = name
        self.pages = pages
    }
    
    public func getPages() -> [T] {
        return pages
    }
    
    func getName() -> String {
        return name
    }
}
