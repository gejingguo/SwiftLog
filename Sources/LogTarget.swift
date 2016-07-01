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
        self.fileHandle = FileHandle(forWritingAtPath: filePath)
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
            fh.seekToEndOfFile()
            fh.write(str.data(using: String.Encoding.utf8)!)
        }
    }
    
    ///check trans this to file.log.x
    func checkTransFile() {
        if let fh = fileHandle {
            let fileSize = fh.seekToEndOfFile()
            if fileSize > UInt64(self.maxFileSize) {
                transFile()
                fh.truncateFile(atOffset: 0)
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

///date target type
public enum DateFileLogTargetType {
    case Daily
    case Hourly
}

///date file target support day file and hour file
public class DateFileLogTarget: LogTarget {
    
    ///log file path
    public var filePath = ""
    
    ///write file handler
    private var fileHandle: FileHandle? = nil
    
    ///last trans time
    private var lastTransDate = Date()
    
    ///date type
    public var dateType = DateFileLogTargetType.Daily
    
    ///init constructor
    public init(filePath: String) {
        self.filePath = filePath
        self.fileHandle = FileHandle(forWritingAtPath: filePath)
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
            fh.seekToEndOfFile()
            fh.write(str.data(using: String.Encoding.utf8)!)
        }
    }

    ///check trans this to file.log.x
    func checkTransFile() {
        var needTrans = false
        let date = Date()
        switch dateType {
        case .Daily:
            needTrans = date.isInSameDay(date: lastTransDate)
            break
        case .Hourly:
            needTrans = date.isInSameHour(date: lastTransDate)
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
        /*
        lastTransExtNum = transNum
        let newFilePath = "\(filePath).\(lastTransExtNum)"
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.copyItemAtPath(filePath, toPath: newFilePath)
        } catch _ {
        }*/
    }
}

extension Date {
    
    func isInSameDay(date: Date) -> Bool {
        return true
    }
    
    func isInSameHour(date: Date) -> Bool {
        return true
    }
}
