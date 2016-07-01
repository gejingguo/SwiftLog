//
//  Logger.swift
//  swift-log
//
//  Created by andyge on 16/1/21.
//  Copyright © 2016年 gejingguo. All rights reserved.
//

import Foundation

public enum LogLevel: Int {
    case Debug = 1
    case Info
    case Warn
    case Error
    case Fatal
}

public class Logger {
    var logLevel = LogLevel.Debug
    var formatter: Formatter
    var targets = [LogTarget]()
    var seperator = ","
    var terminator = ""
    
    public required init(level: LogLevel, formatter: Formatter, seperator: String, terminator: String) {
        self.logLevel = level
        self.formatter = formatter
        self.seperator = seperator
        self.terminator = terminator
    }
    
    public convenience init(level: LogLevel) {
        let fmt = Formatter(format: "%@|%@:%@|%@|%@", components: [
            .Date("yyyy-MM-dd HH:mm:ss.SSS"),
            .File(fullPath: false),
            .Line,
            .Level,
            .Message
            ])
        self.init(level: level, formatter: fmt, seperator: ",", terminator: "")
        self.targets.append(ConsoleLogTarget())
    }
    
    //public convenience init() {
        //self.init(level: LogLevel.Debug, showLevel: true, showTime: true, seperator: "|")
    //}
    
    /// 增加输出目标
    public func append(target: LogTarget) {
        targets.append(target)
    }
    
    /// 输出到所有目标
    func writeToTargets(str: String) {
        for target in targets {
            target.write(str: str)
        }
    }
    
    public func debug(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        if logLevel.rawValue > LogLevel.Debug.rawValue {
            return
        }
        
        let msg = formatter.format(level: LogLevel.Debug, items: items, separator: self.seperator, terminator: self.terminator, file: file, line: line, function: function, date: Date())
        self.writeToTargets(str: msg)
    }
    
    public func info(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        if logLevel.rawValue > LogLevel.Info.rawValue {
            return
        }
        let msg = formatter.format(level: LogLevel.Info, items: items, separator: self.seperator, terminator: self.terminator, file: file, line: line, function: function, date: Date())
        self.writeToTargets(str: msg)
    }
    
    public func warn(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        if logLevel.rawValue > LogLevel.Warn.rawValue {
            return
        }
        let msg = formatter.format(level: LogLevel.Warn, items: items, separator: self.seperator, terminator: self.terminator, file: file, line: line, function: function, date: Date())
        self.writeToTargets(str: msg)
    }
    
    public func error(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        if logLevel.rawValue > LogLevel.Error.rawValue {
            return
        }
        let msg = formatter.format(level: LogLevel.Error, items: items, separator: self.seperator, terminator: self.terminator, file: file, line: line, function: function, date: Date())
        self.writeToTargets(str: msg)
    }
    
    public func fatal(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        if logLevel.rawValue > LogLevel.Fatal.rawValue {
            return
        }
        let msg = formatter.format(level: LogLevel.Fatal, items: items, separator: self.seperator, terminator: self.terminator, file: file, line: line, function: function, date: Date())
        self.writeToTargets(str: msg)
    }
}
