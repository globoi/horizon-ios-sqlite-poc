//
//  Pessoa.swift
//  POCSQLight
//
//  Created by alessandro on 09/10/23.
//

import Foundation
import SQLite3

class Pessoa: SQLiteBaseModel, SQLiteBaseModelType {
    
    var id: Int
    var nome: String
    var idade: Int
    
    //Placeholder
    init(id: Int = 0, nome: String = "", idade: Int = 0) {
        self.id = id
        self.nome = nome
        self.idade = idade
    }
    
    func createTable(){
        let sqlString = super.createTableString(name: "pessoa")
        if let manager = super.manager, let db = super.db {
            _ = manager.createTableFromModel(modelName: sqlString, in: db)
        }
    }
    
    func insertPeopleInBatch(people: [Pessoa]) -> Bool {
        
        if let manager = manager {
            
            if sqlite3_open(manager.databasePath, &super.db) != SQLITE_OK {
                print("Erro ao abrir o banco de dados.")
                return false
            }
            
            let insertStatementString = "INSERT INTO \("pessoa") (nome, idade) VALUES (?, ?)"
            var insertStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) != SQLITE_OK {
                print("Erro ao preparar a instrução de inserção.")
                return false
            }
            
            sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil) // Iniciar uma transação
            
            for person in people {
                let itemName = person.nome as NSString
                sqlite3_bind_text(insertStatement, 1, itemName.utf8String, -1, nil)
                sqlite3_bind_int(insertStatement, 2, Int32(person.idade))
                
                if sqlite3_step(insertStatement) != SQLITE_DONE {
                    print("Erro ao inserir uma pessoa.")
                    return false
                }
                
                sqlite3_reset(insertStatement)
            }
            
            sqlite3_exec(db, "COMMIT", nil, nil, nil) // Commit da transação
            
            sqlite3_finalize(insertStatement)
            sqlite3_close(db)
        } else {
            return false
        }
        
        print("Pessoas inseridas com sucesso!")
        return true
    }
    
    func selectTopNPeople(limit: Int) -> [Pessoa]? {
        
        var people: [Pessoa] = []

        if sqlite3_open(self.manager?.databasePath, &super.db) != SQLITE_OK {
            print("Erro ao abrir o banco de dados.")
            return nil
        }

        let selectStatementString = "SELECT * FROM \("pessoa") ORDER BY id DESC LIMIT ?"
        var selectStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(super.db, selectStatementString, -1, &selectStatement, nil) != SQLITE_OK {
            print("Erro ao preparar a instrução de seleção.")
            return nil
        }

        sqlite3_bind_int(selectStatement, 1, Int32(limit))

        while sqlite3_step(selectStatement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(selectStatement, 0))
            let name = String(cString: sqlite3_column_text(selectStatement, 1))
            let age = Int(sqlite3_column_int(selectStatement, 2))
            let person = Pessoa(id: id, nome: name, idade: age)
            people.append(person)
        }

        sqlite3_finalize(selectStatement)
        sqlite3_close(db)

        return people
    }
    
    func deleteRowsInBatch(ids: [Int]) -> Bool {
        var db: OpaquePointer? = nil

        if sqlite3_open(self.manager?.databasePath, &super.db) != SQLITE_OK {
            print("Erro ao abrir o banco de dados.")
            return false
        }

        let tableName = "pessoa"
        let deleteStatementString = "DELETE FROM \(tableName) WHERE id IN (\(ids.map { String($0) }.joined(separator: ",")))"

        if sqlite3_exec(super.db, deleteStatementString, nil, nil, nil) != SQLITE_OK {
            print("Erro ao executar a instrução de exclusão em lote.")
            return false
        }

        sqlite3_close(db)

        return true
    }
    
}
