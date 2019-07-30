//
//  PageManager.swift
//  QuizManager
//
//  Created by Steven Curtis on 25/07/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation

// Takes the pages of data stored and puts them into the format required

public protocol PageManagerProtocol {
//    func getAllPages<T: PageProtocol>(with type: T.Type, _ forDatabase: String?, withCompletionHandler completion: @escaping (Result<[T], Error>) -> Void)
//    func getNextPage<T: PageProtocol> (with type: T.Type) -> (T)?
    
    func getSpecificPage<T: PageProtocol>(with type: T.Type, locationNumber: Int) -> T?
    func getMajorHeadingsWithSubheadings<T: PageProtocol>(with type: T.Type) -> Zip2Sequence<[String], [String]>?
    func getSubHeadings<T: PageProtocol>(with type: T.Type) -> [String] 
}

// currently only supports a single source of information

public class PageManager {
    
    var repos = [RepositoryProtocol]()

    public func getSpecificPage<T: PageProtocol>(with type: T.Type, locationNumber: Int) -> T? {
        if anyContent.count == 0 {return nil}
        if anyContent[0].getPages().count <= locationNumber {
            return nil
        }
        return (anyContent[0].getPages()[locationNumber] as! T)
    }
    
    public func getMajorHeadingsWithSubheadings<T: PageProtocol>(with type: T.Type) -> Zip2Sequence<[String], [String]>? {
        if anyContent.count == 0 {return nil}
        var names = [String]()
        var topics = [String]()

        for res in anyContent {
            if let asanaary = res.getPages() as? [T] {
                names += ( asanaary.compactMap { $0.name } )
                topics += ( asanaary.compactMap { $0.topic  } )
            }
        }

        return zip(names, topics)
    }
    
    public func getSubHeadings<T: PageProtocol>(with type: T.Type) -> [String] {

        var output = [String]()

        
        for res in anyContent {
            if let asanaary = res.getPages() as? [T] {
                output += ( asanaary.compactMap { $0.name } )
            }
        }
        return output
    }
    
    public init(repo: RepositoryProtocol? = nil) {
        if let repo = repo {
            repos.append(repo)
        }
    }
    
    // Create multi repo
    public init(repositories: [RepositoryProtocol]) {
        for repo in repositories {
            repos.append(repo)
        }
    }
    
    private var anyContent = [Page<Any>]()

//    var subHeadings = [String]()
    
    public func initializePages<T: PageProtocol>(with type: T.Type, withCompletionHandler completion: ((Result<[Page<T>], Error>) -> Void)?)  {
        for repo in repos {
            repo.providePages(with: type, withdbpathfunc: nil, withCompletionHandler: {result in
                switch result {
                    case .failure(let error):
                        if let completion = completion {
                            completion(.failure(error) )
                        }
                    case .success(let result):
                        var pages = [T]()
                        
                        for res in result {
                            pages += res.getPages()

                        }
//                        self.subHeadings = headings
                        
                        self.anyContent.append( Page(name: "Page", pages: pages)  )
    
                        if let completion = completion {
                            completion(.success(result))
                        }
                    }
            }
            )
        }
    }

}

extension PageManager : PageManagerProtocol { }
