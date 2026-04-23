//
//  AddressDB.swift
//  SQLiteImageAddress
//
//  Created by electrozone on 3/31/26.
//

import SQLite3 // 패키지 없어도 들어가 있음
import SwiftUI
import Combine

class AddressDB: ObservableObject{ // 클라스로 쓴 이유: SQLite 를 쓸거라
    var db: OpaquePointer? // 포인트 잡는 거
    @Published var addressList: [Address] = []
    
    init() { // 생성자
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("AddressData.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK { // 이게 리턴 값 _ 이상이 있는지 없는지
            print("error opening database")
        }
        
        // Table 만들기
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS address (sid INTEGER PRIMARY KEY AUTOINCREMENT, sname TEXT, sphone TEXT, saddress TEXT, srelation TEXT, simage BLOB)", nil, nil, nil) != SQLITE_OK{  // sqlite는 string 없어서 Text
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table :\(errMsg)")
        }

        loadAddresses()
    }// 생성자
    
    func loadAddresses() {
        addressList = queryDB()
    }
    
    
    func insertDB(name: String, phone: String, address: String, relation: String, image: UIImage) -> Bool{
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
        let queryString = "INSERT INTO address (sname, sphone, saddress, srelation, simage) VALUES (?,?,?,?,?)"
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        sqlite3_bind_text(stmt, 1, name, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, phone, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, address, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 4, relation, -1, SQLITE_TRANSIENT)
        
        let imageData = image.jpegData(compressionQuality: 0.4)! as NSData
        sqlite3_bind_blob(stmt, 5, imageData.bytes, Int32(imageData.length), SQLITE_TRANSIENT)
      
        let result = sqlite3_step(stmt) == SQLITE_DONE
        sqlite3_finalize(stmt)
        
        if result{
            loadAddresses()
            return true
        }else{
            return false
        }
    }

    func queryDB() -> [Address]{
        var stmt: OpaquePointer?
        let queryString = "SELECT * FROM address order by sname"
        var fetchedList: [Address] = []
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select : \(errMsg)")
        }

        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = Int(sqlite3_column_int(stmt, 0))
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let phone = String(cString: sqlite3_column_text(stmt, 2))
            let address = String(cString: sqlite3_column_text(stmt, 3))
            let relation = String(cString: sqlite3_column_text(stmt, 4))
            var image: UIImage = UIImage()
            
            if let dataBlob = sqlite3_column_blob(stmt, 5){
                let dataBlobLength = sqlite3_column_bytes(stmt, 5)
                let data = Data(bytes: dataBlob, count: Int(dataBlobLength))
                image = UIImage(data: data)!
            }
            
            fetchedList.append(Address(id: id, name: name, phone: phone, address: address, relation: relation, image: image))
        }
        
        sqlite3_finalize(stmt)
        return fetchedList

    }
    
    func deleteDB(id: Int) -> Bool{
        var stmt: OpaquePointer?
        let queryString = "DELETE FROM address WHERE sid = ?"
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        sqlite3_bind_int(stmt, 1, Int32(id))

        let result = sqlite3_step(stmt) == SQLITE_DONE
        sqlite3_finalize(stmt)
        
        if result{
            loadAddresses()
            return true
        }else{
            return false
        }

    }
    
    func updateDB(id: Int, name: String, phone: String, address: String, relation: String, image: UIImage) -> Bool{
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                
        let queryString = "UPDATE address SET sname = ?, sphone = ?, saddress = ?, srelation = ?, simage = ? WHERE sid = ?"
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        sqlite3_bind_text(stmt, 1, name, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, phone, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, address, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 4, relation, -1, SQLITE_TRANSIENT)
        
        let imageData = image.jpegData(compressionQuality: 0.4)! as NSData
        sqlite3_bind_blob(stmt, 5, imageData.bytes, Int32(imageData.length), SQLITE_TRANSIENT)
        
        sqlite3_bind_int(stmt, 6, Int32(id))
      
        let result = sqlite3_step(stmt) == SQLITE_DONE
        sqlite3_finalize(stmt)
        
        if result{
            loadAddresses()
            return true
        }else{
            return false
        }

    }

}// AddressDB
