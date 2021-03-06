//
//  SQLiteManager.swift
//  FJAddressPickerDemo
//
//  Created by jun on 2017/6/22.
//  Copyright © 2017年 JUN. All rights reserved.
//

import UIKit
import FMDB

/// 屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.width
/// 屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.height

class FJSQLiteUtils: NSObject {
    /// 单例
    static let instance = FJSQLiteUtils()
    
    
    /// 选中的
    var itemArray:[FJAddressModel] = []
    
    
    /// 配置信息
    var arribute = AddressAttribute()
    
    /// 数据库
    var db:FMDatabase!
    
    /// sql文件名称
    var sqlName = "tp_region"
    
    /// 数据库名称
    var databaseName = "location.db"
    
    /// 表名
    var tableName = "tp_region"
    
    override init() {
        super.init()
    }

    // MARK: ------ 查询操作
    
    /// 查询全部省份
    ///
    /// - Returns: return value description
    func queryAllProvince() -> [FJAddressModel] {
        if db.open() {
            let sql = "SELECT * FROM \(tableName) WHERE `level` = 1"
            let rs = try? db.executeQuery(sql, values: nil)
            var dataArray:[FJAddressModel] = []
            if let result = rs {
                while result.next() {
                    let model = FJAddressModel()
                    model.id = Int(result.int(forColumn: "id"))
                    model.parent_id = Int(result.int(forColumn: "parent_id"))
                    model.name = result.string(forColumn: "name")
                    model.level = Int(result.int(forColumn: "level"))
                    dataArray.append(model)
                }
                return dataArray
            }
            db.close()
        }
        return []
    }
    
    /// 查询下一级数据
    ///
    /// - Parameters:
    ///   - level: level description
    ///   - parent_id: parent_id description
    /// - Returns: return value description
    func queryData(level:Int,parent_id:Int) -> [FJAddressModel] {
        if db.open() {
            let sql = "SELECT * FROM \(tableName) WHERE `level` = \(level) and `parent_id` =  \(parent_id)"
            let rs = try? db.executeQuery(sql, values: nil)
            var dataArray:[FJAddressModel] = []
            if let result = rs {
                while result.next() {
                    let model = FJAddressModel()
                    model.id = Int(result.int(forColumn: "id"))
                    model.parent_id = Int(result.int(forColumn: "parent_id"))
                    model.name = result.string(forColumn: "name")
                    model.level = Int(result.int(forColumn: "level"))
                    dataArray.append(model)
                }
                return dataArray
            }
            db.close()
        }
        return []
    }
    func queryData(id:Int) -> [FJAddressModel] {
        if db.open() {
            let sql = "SELECT name FROM %@ WHERE `id` = \(id)"
            let rs = try? db.executeQuery(sql, values: nil)
            var dataArray:[FJAddressModel] = []
            if let result = rs {
                while result.next() {
                    let model = FJAddressModel()
                    model.id = Int(result.int(forColumn: "id"))
                    model.parent_id = Int(result.int(forColumn: "parent_id"))
                    model.name = result.string(forColumn: "name")
                    model.level = Int(result.int(forColumn: "level"))
                    dataArray.append(model)
                }
                return dataArray
            }
            db.close()
        }
        return []
    }
}
extension FJSQLiteUtils{
    // MARK: ------ 数据库管理
    // 初始化数据
    func setupData() {
        if isTableOK() {
            return
        }
        if createTable() {
            insertRecords()
        }
    }
    /// 数据库初始化
    func dbInit() {
        let dbPath = self.pathForName(name: databaseName)
        print(dbPath)
        db = FMDatabase(path: dbPath)
        setupData()
    }
    /// 删除数据库
    func dbDelete() {
        let dbPath = pathForName(name: databaseName)
        try? FileManager.default.removeItem(atPath: dbPath)
    }
    
    /// 本地路径
    ///
    /// - Parameter name: name description
    /// - Returns: return value description
    func pathForName(name:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths.last
        let dbPath = "\(documentDirectory!)/\(name)"
        return dbPath
    }
    /// 表是否存在
    ///
    /// - Returns: return value description
    func isTableOK() -> Bool {
        
        let openSuccess = db.open()
        if openSuccess {
            let rs = try? db.executeQuery("SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", values: [tableName])
            while (rs?.next())! {
                let count = rs?.int(forColumn: "count")
                if count == 0 {
                    db.close()
                    return false
                }
                else
                {
                    db.close()
                    return true
                }
            }
        }
        else
        {
            
        }
        db.close()
        return false
    }
    
    /// 插入数据
    func insertRecords() {
        if db.open() && db.beginTransaction() {
            do {
                let filePath = Bundle.main.path(forResource: sqlName, ofType: "sql")
                let sql = try String(contentsOfFile: filePath!, encoding: String.Encoding.utf8)
                let isSuccess = db.executeUpdate(sql, withArgumentsIn: [])
                if isSuccess {
                    db.commit()
                    print("插入信息成功")
                    
                }
                else{
                    print("插入信息失败")
                }
                
            } catch{
                print("插入信息失败")
            }
        }
        db.close()
    }
    /// 创建表
    ///
    /// - Returns: return value description
    func createTable() -> Bool{
        var rs = false
        let openSuccess = db.open()
        if openSuccess {
            let sql = "create table if not exists \(tableName) (id int primary key,name text,level int,parent_id int);"
            rs = db.executeUpdate(sql, withArgumentsIn: [])
            if rs {
                print("创建地址表成功")
            }
            else{
                print("创建地址表失败")
            }
        }
        db.close()
        return rs
    }
    
    /// 删除表
    ///
    /// - Returns: return value description
    func delTable() -> Bool {
        var rs = false
        let openSuccess = db.open()
        if openSuccess {
            let sql = "DROP TABLE \(tableName)"
            rs = db.executeStatements(sql)
            if rs {
                print("删除地址表成功")
            }
            else{
                print("删除地址表失败")
            }
        }
        db.close()
        return rs
    }

}
