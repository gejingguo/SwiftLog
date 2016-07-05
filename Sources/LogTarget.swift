//
//  LogTarget.swift
//  swift-log
//
//  Created by andyge on 16/1/21.
//  Copyright © 2016年 gejingguo. All rights reserved.
//

import Foundation

public protocol LogTarget {
    func write(str: String)
}

///console stdout target
public class ConsoleLogTarget: LogTarget {

    ///
    public func write(str: String) {
        print(str)
    }
}

///file target
public class FileLogTarget: LogTarget {

    ///log file path
    public var filePath = ""

    ///max size for log file, default size 1M
    public var maxFileSize = 1024*1024

    ///write file handler
    private var fileHandle: FileHandle? = nil
    
    ///last trans file ext num
    private var lastTransExtNum = 0


    ///init constructor
    public init(filePath: String) {
        self.filePath = filePath
        self.fileHandle = FileHandle(forUpdatingAtPath: self.filePath)
        if let fh = self.fileHandle {
            fh.seekToEndOfFile()
        }
    }
    
    public convenience init(filePath: String, maxFileSize: Int) {
        self.init(filePath: filePath)
        self.maxFileSize = maxFileSize
    }

    ///deinit
    deinit {
        //if let fh = fileHandle {
        //    fh.closeFile()
        //}
    }

    ///target write implement
    public func write(str: String) {
        checkTransFile()
        if fileHandle == nil {
            print("new file")
            let fileManager = FileManager.default()
            if !fileManager.fileExists(atPath: filePath) {
                do {
                    try "".write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
                } catch _ {
                }
            }
            fileHandle = FileHandle(forUpdatingAtPath: self.filePath)
        }

        if fileHandle != nil {
            //fh.seekToEndOfFile()
            //print("write log:", str)
            let msg = str + "\n"
            if let data = msg.data(using: String.Encoding.utf8) {
                fileHandle?.write(data)
                //fh.seekToEndOfFile()
                print("fh fd:", fileHandle?.fileDescriptor, fileHandle)
            }
        }
    }
    
    ///check trans this to file.log.x
    func checkTransFile() {
        if let fh = fileHandle {
            let fileSize = fh.seekToEndOfFile()
            if fileSize > UInt64(self.maxFileSize) {
                transFile()
                fh.truncateFile(atOffset: 0)
                print("log truncate file.")
                return
            }
        }
    }
    
    ///trans file
    func transFile() {
        lastTransExtNum = transNum
        let newFilePath = "\(filePath).\(lastTransExtNum)"
        let fileManager = FileManager.default()
        do {
            try fileManager.copyItem(atPath: filePath, toPath: newFilePath)
        } catch _ {
        }
    }
    
    ///trans file ext num
    var transNum: Int {
        if lastTransExtNum > 0 {
            return lastTransExtNum + 1
        }
        
        var num = 0
        let fileManager = FileManager.default()
        while true {
            num += 1
            let checkFilePath = "\(filePath).\(num)"
            if !fileManager.fileExists(atPath: checkFilePath) {
                break
            }
        }
        return num
    }
}


///date file target support day file and hour file
public class DateFileLogTarget: LogTarget {
    ///date target type
    public enum TargetType {
        case Daily
        case Hourly
    }
    
    ///log file path
    public var filePath = ""
    
    ///write file handler
    private var fileHandle: FileHandle? = nil
    
    ///last trans time
    private var lastTransDate = Date()
    
    ///date type
    public var dateType = TargetType.Daily
    
    ///init constructor
    public init(filePath: String, dateType: TargetType) {
        self.filePath = filePath
        self.fileHandle = FileHandle(forWritingAtPath: filePath)
        self.dateType = dateType
    }
    
    ///deinit
    deinit {
        if let fh = fileHandle {
            fh.closeFile()
        }
    }
    
    ///target write implement
    public func write(str: String) {
        checkTransFile()
        
        if fileHandle == nil {
            let fileManager = FileManager.default()
            if !fileManager.fileExists(atPath: filePath) {
                do {
                    try "".write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
                } catch _ {
                }
            }
            fileHandle = FileHandle(forWritingAtPath: filePath)
        }
        
        if let fh = fileHandle {
            //fh.seekToEndOfFile()
            let msg = str + "\n"
            fh.write(msg.data(using: String.Encoding.utf8)!)
        }
    }

    ///check trans this to file.log.x
    func checkTransFile() {
        var needTrans = false
        let date = Date()
        switch dateType {
        case .Daily:
            print(#function, needTrans, ".Daily")
            needTrans = !self.isInSameDay(date1: date, date2: lastTransDate)
            break
        case .Hourly:
            needTrans = !self.isInSameHour(date1: date, date2: lastTransDate)
            print(#function, needTrans, ".Hourly")
        }
        if needTrans {
            if let fh = fileHandle {
                transFile()
                fh.truncateFile(atOffset: 0)
                lastTransDate = date
            }
        }
    }
    
    ///trans file
    func transFile() {
        
        let newFilePath = "\(filePath).\(suffixName())"
        let fileManager = FileManager.default()
        do {
            try fileManager.copyItem(atPath: filePath, toPath: newFilePath)
        } catch _ {
        }
    }
    
    ///文件名后缀
    func suffixName() -> String {
        switch dateType {
        case .Daily:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: Date())
        case .Hourly:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH"
            return dateFormatter.string(from: Date())
        }
    }
}

private extension DateFileLogTarget {
    
    func isInSameDay(date1: Date, date2: Date) -> Bool {
        return getDayIdStr(date: date1) == getDayIdStr(date: date2)
    }
    
    func isInSameHour(date1: Date, date2: Date) -> Bool {
        return getHourIdStr(date: date1) == getHourIdStr(date: date2)
    }
    
    func getDayIdStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func getHourIdStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH"
        return dateFormatter.string(from: Date())
    }
}
