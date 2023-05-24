//
//  ViewModel.swift
//  PrettyPoniesCLPA
//
//  Created by Tiger Nixon on 5/12/23.
//

import Foundation
import SQLite3

actor ViewModel: ObservableObject {
    
    private static let databaseFileName = "ponies.sqlite"
    
    @MainActor @Published var ponies = [Pony]()
    
    lazy var documentsURL: URL = {
        FileManager.default.urls(for: .documentDirectory,
                                 in: .userDomainMask)[0]
    }()
    
    private lazy var databaseURL: URL = {
        documentsURL.appendingPathComponent(Self.databaseFileName)
    }()
    
    init() {
        Task {
            await initializeDatabase()
            await refreshPonies()
        }
    }
    
    func initializeDatabase() {
        
        guard let database = openConnection() else { return }
        
        if sqlite3_exec(database,
                        "CREATE TABLE IF NOT EXISTS PONY (ID INTEGER PRIMARY KEY, NAME TEXT, SUPERPOWER TEXT)", nil, nil, nil) != SQLITE_OK {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Creating Pony Table: \(errorString)")
            closeConnection(pointer: database)
            return
        }
        
        closeConnection(pointer: database)
    }
    
    func createPony(id: String, name: String, superpower: String) {
        guard let id = Int(id) else {
            print("cannot derive id (int) from \(id)")
            return
        }
        createPony(id: id, name: name, superpower: superpower)
    }
    
    func createPony(id: Int, name: String, superpower: String) {
        
        guard let database = openConnection() else { return }
        
        let createPonyQueryString = "INSERT INTO PONY (ID, NAME, SUPERPOWER) VALUES (?, ?, ?)"
        var createPonyStatement: OpaquePointer?
        
        if sqlite3_prepare(database,
                           createPonyQueryString,
                           -1,
                           &createPonyStatement,
                           nil) != SQLITE_OK {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Creating Pony, Preparing Statement: \(errorString)")
            closeConnection(pointer: database)
            return
        }
        
        if sqlite3_bind_int(createPonyStatement,
                            1,
                            Int32(id)) != SQLITE_OK {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Creating Pony, Binding ID: \(errorString)")
            closeConnection(pointer: database)
            return
        }
        
        if sqlite3_bind_text(createPonyStatement,
                             2,
                             NSString(string: name).utf8String,
                             -1,
                             nil) != SQLITE_OK {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Creating Pony, Binding Name: \(errorString)")
            closeConnection(pointer: database)
            return
        }
        
        if sqlite3_bind_text(createPonyStatement,
                             3,
                             NSString(string: superpower).utf8String,
                             -1,
                             nil) != SQLITE_OK {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Creating Pony, Binding Superpower: \(errorString)")
            sqlite3_finalize(createPonyStatement)
            closeConnection(pointer: database)
            return
        }
        
        if sqlite3_step(createPonyStatement) != SQLITE_DONE {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Creating Pony, Statement Step: \(errorString)")
            sqlite3_finalize(createPonyStatement)
            closeConnection(pointer: database)
            return
        }
        
        sqlite3_finalize(createPonyStatement)
        closeConnection(pointer: database)
        
        refreshPonies()
    }
    
    func readPonies() -> [Pony] {
        
        guard let database = openConnection() else { return [ ] }
        
        var ponies = [Pony]()
        
        let fetchAllPoniesQueryString = "SELECT * FROM PONY"
        var fetchAllPoniesStatement: OpaquePointer?
        
        if sqlite3_prepare(database,
                           fetchAllPoniesQueryString,
                           -1,
                           &fetchAllPoniesStatement,
                           nil) != SQLITE_OK {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Fetching Ponies, Preparing Statement: \(errorString)")
            closeConnection(pointer: database)
            return [ ]
        }
        
        while sqlite3_step(fetchAllPoniesStatement) == SQLITE_ROW {
            let id = sqlite3_column_int(fetchAllPoniesStatement, 0)
            let name = String(cString: sqlite3_column_text(fetchAllPoniesStatement, 1))
            let superpower = String(cString: sqlite3_column_text(fetchAllPoniesStatement, 2))
            let pony = Pony(id: Int(id), name: name, superpower: superpower)
            ponies.append(pony)
        }
        
        sqlite3_finalize(fetchAllPoniesStatement)
        closeConnection(pointer: database)
        return ponies
    }
    
    func updatePony(id: String, name: String, superpower: String) {
        guard let id = Int(id) else {
            print("cannot derive id (int) from \(id)")
            return
        }
        updatePony(id: id, name: name, superpower: superpower)
    }
    
    func updatePony(id: Int, name: String, superpower: String) {
        
        guard let database = openConnection() else { return }
        
        let updatePonyQueryString = "UPDATE PONY SET NAME=?, SUPERPOWER=? where ID=\(id)"
        var updatePonyStatement: OpaquePointer?
        
        if sqlite3_prepare(database,
                           updatePonyQueryString,
                           -1,
                           &updatePonyStatement,
                           nil) != SQLITE_OK {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Updating Pony, Preparing Statement: \(errorString)")
            closeConnection(pointer: database)
            return
        }
        
        if sqlite3_bind_text(updatePonyStatement,
                             1,
                             NSString(string: name).utf8String,
                             -1,
                             nil) != SQLITE_OK {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Updating Pony, Binding Name: \(errorString)")
            closeConnection(pointer: database)
            return
        }
        
        if sqlite3_bind_text(updatePonyStatement,
                             2,
                             NSString(string: superpower).utf8String,
                             -1,
                             nil) != SQLITE_OK {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Updating Pony, Binding Superpower: \(errorString)")
            closeConnection(pointer: database)
            return
        }
        
        if sqlite3_step(updatePonyStatement) != SQLITE_DONE {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Updating Pony, Statement Step: \(errorString)")
            sqlite3_finalize(updatePonyStatement)
            closeConnection(pointer: database)
            return
        }
        
        sqlite3_finalize(updatePonyStatement)
        closeConnection(pointer: database)
        
        refreshPonies()
    }
    
    func deletePony(id: String) {
        guard let id = Int(id) else {
            print("cannot derive id (int) from \(id)")
            return
        }
        deletePony(id: id)
    }
    
    func deletePony(id: Int) {
        
        guard let database = openConnection() else { return }
        
        let deletePonyQueryString = "DELETE FROM PONY where ID=\(id)"
        var deletePonyStatement: OpaquePointer?
        
        if sqlite3_prepare(database,
                           deletePonyQueryString,
                           -1,
                           &deletePonyStatement,
                           nil) != SQLITE_OK {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Deleting Pony, Preparing Statement: \(errorString)")
            closeConnection(pointer: database)
            return
        }
        
        if sqlite3_step(deletePonyStatement) != SQLITE_DONE {
            let errorString = String(cString: sqlite3_errmsg(database))
            print("Error Updating Pony, Statement Step: \(errorString)")
            sqlite3_finalize(deletePonyStatement)
            closeConnection(pointer: database)
            return
        }
        
        sqlite3_finalize(deletePonyStatement)
        closeConnection(pointer: database)
        
        refreshPonies()
    }
    
    private func openConnection() -> OpaquePointer? {
        var pointer: OpaquePointer?
        if sqlite3_open(databaseURL.absoluteString,
                        &pointer) != SQLITE_OK {
            print("could not open database connection...")
            return nil
        }
        return pointer
    }
    
    private func closeConnection(pointer: OpaquePointer?) {
        if let pointer = pointer {
            sqlite3_close(pointer)
        }
    }
    
    private func refreshPonies() {
        Task { @MainActor in
            self.ponies = await readPonies()
            print("Ponies updated to: \(self.ponies)")
        }
        
    }
    
}
