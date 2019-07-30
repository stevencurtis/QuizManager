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
    func provideQuizzes<T: QuestionProtocol>(with type: T.Type,withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Quiz<T>], Error>) -> Void)
    func providePages<T: PageProtocol>(with type: T.Type,withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Page<T>], Error>) -> Void)    
    func provideDbVersion(withdbpathfunc: (() -> String?)?) -> Int
}

public class SQLiteManager {
    var dbases = [String]()
    var tableNames = [String]()
    var quizManager: QuizManager?
    var fetching = false
    private var quizzes = [Quiz<QuestionProtocol>]()
    
    public func providePages<T: PageProtocol>(with type: T.Type,withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Page<T>], Error>) -> Void){
        
        guard fetching == false else {return}
        fetching = true
        
        var currentPage = [Page<T>]()
        
        for dbName in dbases {
            var dbPath: String?
            if withdbpathfunc == nil {
                dbPath = createDBPath(dbName)
                dbPath = ( copyDatabaseIfNeeded(databasePath: dbPath!, dbname: dbName) )

            } else {
                dbPath = withdbpathfunc!()
            }
            let db = openDatabase(dbPath!)
            let qs = readQuestionsFromDB(with: type, db!)
            // create a new Quiz, and add to the array of quizzes
            currentPage.append(Page(name: dbName, pages: qs))
        }
        
        completion(.success(currentPage))
        fetching = false
    }
    
    public func provideQuizzes<T: QuestionProtocol>(with type: T.Type,withdbpathfunc: (() -> String?)?, withCompletionHandler completion: @escaping (Result<[Quiz<T>], Error>) -> Void)
    {
        guard fetching == false else {return}
        fetching = true
        
        var currentQuiz = [Quiz<T>]()

        for dbName in dbases {
            var dbPath: String?
            if withdbpathfunc == nil {
                dbPath = createDBPath(dbName)
                dbPath = ( copyDatabaseIfNeeded(databasePath: dbPath!, dbname: dbName) )

            } else {
                dbPath = withdbpathfunc!()
            }
            let db = openDatabase(dbPath!)
            
            let qs = readQuestionsFromDB(with: type, db!)
            // create a new Quiz, and add to the array of quizzes
            currentQuiz.append(Quiz(name: dbName, questions: qs))
        }
        
        completion(.success(currentQuiz))
        fetching = false
    }
    
    public func provideDbVersion(withdbpathfunc: (() -> String?)?) -> Int {
        for dbName in dbases {
            let dbPath: String?
            if withdbpathfunc == nil {
                dbPath = createDBPath(dbName)
            } else {
                dbPath = withdbpathfunc!()
            }
            if let db = openDatabase(dbPath!) {
                return ( versionOfDB(db) ?? 0 )
            }
        }
        return -1
    }

    // initialize these databases
    public init(_ sqlitedbNames: String..., tableName: String, urlStrings: [String]? = nil) {
        for dbName in sqlitedbNames {
            self.dbases.append(dbName)
        }
        self.tableNames.append(tableName)
    }
    

    func clearDiskCache(databasePath: String, dbname: String) {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let diskCacheStorageBaseUrl = myDocuments.appendingPathComponent("/\(dbname).sqlite") //
        do {
            try fileManager.removeItem(at: diskCacheStorageBaseUrl)
        }
        catch {
            print("error during file removal: \(error)")
        }
    }
    
    func copyDatabaseIfNeeded(databasePath: String, dbname: String) -> String {
        var destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        destPath = destPath + "/\(dbname).sqlite"
        let currentDBVersion = provideDbVersion(withdbpathfunc: nil)
        do {
            try FileManager.default.copyItem(atPath: databasePath, toPath: destPath)
            UserDefaults.standard.set(currentDBVersion, forKey: "quizversion")
        }
        catch {
            let err = error as NSError
            if err.code == 516 {
                
                let quizver = UserDefaults.standard.integer(forKey: "quizversion") // default = 0
                print ("currentDBVersion", currentDBVersion, "quizver", quizver)
                if quizver < currentDBVersion {
                    // migrate previous DB for current - first run after an update
                    clearDiskCache(databasePath: databasePath, dbname: dbname)
                    UserDefaults.standard.set(Int.max, forKey: "quizversion")
                    return copyDatabaseIfNeeded(databasePath: databasePath, dbname: dbname)
                }
            }
            
        }
        return destPath
    }

    func openDatabase(_ databasePath: String) -> OpaquePointer? {
        var db: OpaquePointer? = nil
        if sqlite3_open_v2(databasePath,&db, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK{
            print("Successfully opened connection to database at \(self.dbases.first!)")
            print("Database path \(databasePath)")

            return db
        } else {
            print("Unable to open database. Verify that you created the directory described " +
                "in the Getting Started section.")
            return nil
        }
    }

    public func createDBPath(_ dbname: String) -> String?
    {
        if let filepath = Bundle.main.path(forResource: dbname, ofType: "sqlite") {
            return filepath
        }
        fatalError("Database not found")
    }
    
    func versionOfDB(_ dbpointer: OpaquePointer) -> Int? {
        var sqliteStatementTwo: OpaquePointer? = nil
        if sqlite3_prepare_v2(dbpointer, "PRAGMA user_version;", -1, &sqliteStatementTwo, nil) == SQLITE_OK {
            while(sqlite3_step(sqliteStatementTwo) == SQLITE_ROW) {
                let databaseVersion = sqlite3_column_int(sqliteStatementTwo, 0);
                return (Int(databaseVersion))
            }
        }
        return nil
    }
    
    func readQuestionsFromDB<T: BaseDataProtocol>(with type: T.Type, tableName: String? = nil, _ dbpointer: OpaquePointer) -> [T] {
        
        let querySql = "select * from \(tableName ?? self.tableNames.first!);"
        var sqliteStatement: OpaquePointer? = nil

        var questions = [T]()
        if sqlite3_prepare_v2(dbpointer, querySql, -1, &sqliteStatement, nil) == SQLITE_OK {
            while(sqlite3_step(sqliteStatement) == SQLITE_ROW) {
                var idx = 0
                var questionData = [String]()
                while let dta = sqlite3_column_text(sqliteStatement, Int32(idx)) {
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
