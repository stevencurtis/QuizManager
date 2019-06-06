//
//  SQliteManager.swift
//  sociologygcse
//
//  Created by Steven Curtis on 23/04/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation
import SQLite3

public protocol RepositoryProtocol{
    func provideQuizzes<T: QuestionProtocol>(with type: T.Type,withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Quiz<QuestionProtocol>], Error>) -> Void)
}

public class SQLiteManager {
    static let shared = SQLiteManager(Constants.dbName)
    var dbases = [String]()
    var quizManager: QuizManager?
    var fetching = false
    private var quizzes = [Quiz<QuestionProtocol>]()
    
    private var anyquizzes = [Quiz<QuestionProtocol>]()
    
    public func provideQuizzes<T: QuestionProtocol>(with type: T.Type,withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Quiz<QuestionProtocol>], Error>) -> Void)
    {
        guard fetching == false else {return}
        fetching = true
        for dbName in dbases {
            let dbPath: String?
            if withdbpathfunc == nil {
                dbPath = createDBPath()
            } else {
                dbPath = withdbpathfunc!()
            }
            let db = openDatabase(dbPath!)
            
            let qs = readQuestionsFromDB(with: type, db!)
            // create a new Quiz, and add to the array of quizzes
            anyquizzes.append(Quiz(name: dbName, questions: qs))
        }
        completion(.success(anyquizzes))
        fetching = false
    }

    // initialize these databases
    public init(_ sqlitedbNames: String..., urlStrings: [String]? = nil) {
        for dbName in sqlitedbNames {
            self.dbases.append(dbName)
        }
    }

    func openDatabase(_ databasePath: String) -> OpaquePointer? {
        var db: OpaquePointer? = nil
        if sqlite3_open_v2(databasePath,&db, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK{
            print("Successfully opened connection to database at \(Constants.dbName)")
            return db
        } else {
            print("Unable to open database. Verify that you created the directory described " +
                "in the Getting Started section.")
            return nil
        }
    }

    public func createDBPath() -> String?
    {
        if let filepath = Bundle.main.path(forResource: Constants.dbName, ofType: "sqlite") {
            return filepath
        }
        fatalError("Database not found")
    }
    
    func readQuestionsFromDB<T: QuestionProtocol>(with type: T.Type, tableName: String = "Questions", _ dbpointer: OpaquePointer) -> [T] {
        let querySql = "select * from \(tableName);"
        var sqliteStatement: OpaquePointer? = nil
        var questions = [T]()
        if sqlite3_prepare_v2(dbpointer, querySql, -1, &sqliteStatement, nil) == SQLITE_OK {
            while(sqlite3_step(sqliteStatement) == SQLITE_ROW) {
                var idx = 0
                var questionData = [String]()
                while let dta =  sqlite3_column_text(sqliteStatement, Int32(idx)) {
                    questionData.append( String(cString: dta) )
                    idx += 1
                }
                if let question = T.init(fields: questionData) {
                    questions.append(question)
                }
            }
        } else {
            print("SQL statement could not be prepared")
        }
        
        sqlite3_finalize(sqliteStatement)
        return questions
    }
    
}

extension SQLiteManager : RepositoryProtocol { }
