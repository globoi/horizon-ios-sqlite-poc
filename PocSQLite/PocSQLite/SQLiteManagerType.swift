//
//  SQLightManagerType.swift
//  POCSQLight
//
//  Created by alessandro on 09/10/23.
//

import Foundation

protocol SQLiteManagerType {
    var databasePath: String { get set }
    func openOrCreateDatabase(databaseName: String) -> (db: OpaquePointer?, path: String)
    func createTableFromModel(modelName: String, in db: OpaquePointer) -> Bool
}

protocol SQLiteType {
    func createTableString(name: String) -> String
}
