//
//  SQLightManager.swift
//  POCSQLight
//
//  Created by alessandro on 09/10/23.
//

import Foundation
import SQLite3

class SQLiteManager: SQLiteManagerType {
    
    var databasePath: String = ""
    
    func createTableFromModel(modelName: String, in db: OpaquePointer) -> Bool {
        
        var createTableStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, modelName, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                sqlite3_finalize(createTableStatement)
                print("Tabela criada com sucesso!")
                return true
            } else {
                print("Erro ao criar a tabela.")
            }
        } else {
            print("Erro ao preparar a declaração SQL.")
        }
        
        sqlite3_finalize(createTableStatement)
        return false
    }
    
    
    func openOrCreateDatabase(databaseName: String) -> (db: OpaquePointer?, path: String) {
        var db: OpaquePointer?
        
        // Obtenha o caminho para o diretório de documentos do aplicativo
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return (nil, "")
        }
        
        let databaseURL = documentsDirectory.appendingPathComponent(databaseName)
        
        databasePath = databaseURL.path
        
        // Verifique se o arquivo do banco de dados já existe
        if FileManager.default.fileExists(atPath: databaseURL.path) {
            if sqlite3_open(databaseURL.path, &db) == SQLITE_OK {
                print("Banco de dados já existe e foi aberto com sucesso em: \(databaseURL.path)")
                return (db, databaseURL.path)
            } else {
                print("Erro ao abrir o banco de dados.")
                return (nil, "")
            }
        } else {
            // Se o banco de dados não existir, crie-o
            if sqlite3_open(databaseURL.path, &db) == SQLITE_OK {
                print("Banco de dados criado com sucesso em: \(databaseURL.path)")
                return (db, databaseURL.path)
            } else {
                print("Erro ao criar o banco de dados.")
                return (nil, "")
            }
        }
    }
    
}
