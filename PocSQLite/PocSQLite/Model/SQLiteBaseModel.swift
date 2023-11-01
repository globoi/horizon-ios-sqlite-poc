//
//  SQLiteBaseModel.swift
//  POCSQLight
//
//  Created by alessandro on 18/10/23.
//

import Foundation

class SQLiteBaseModel: SQLiteType {
    
    var manager: SQLiteManagerType?
    var db: OpaquePointer?
    
    func createTableString(name: String) -> String {
        
        let mirror = Mirror(reflecting: self)
        var columns = [String]()
        
        for child  in mirror.children {
            
            if let label = child.label {
                if label != "id" {
                    let column = "\(label) \(type(of: child.value) == Int.self ? "INTEGER" : "TEXT")"
                    columns.append(column)
                }
            }
        }
        
        let columnsString = columns.joined(separator: ", ")
        let createTableSQL = "CREATE TABLE IF NOT EXISTS \(name) (id INTEGER PRIMARY KEY, \(columnsString));"
        print(createTableSQL)
        return(createTableSQL)
    }
    
    func setManagerAndDB (manager: SQLiteManagerType, db: OpaquePointer){
        self.manager = manager
        self.db = db
    }
}
