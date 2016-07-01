//
//  Formatter.swift
//  SwiftLog
//
//  Created by andyge on 16/6/28.
//
//

import Foundation

public enum Component {
    case Date(String)
    case Message
    case Level
    case File(fullPath: Bool)
    case Line
    case Function
    case Location
}

public class Formatter {
    /// The formatter format.
    private var format: String
    
    /// The formatter components.
    private var components: [Component]
    
    /// The date formatter.
    private let dateFormatter = DateFormatter()
    
    /// The formatter textual representation.
    internal var description: String {
        return String(format: format, arguments: components.map { (component: Component) -> CVarArg in
            return String(component).uppercased()
            })
    }
    
    public convenience init(format: String, components: Component...) {
        self.init(format: format, components: components)
    }
    
    public init(format: String, components: [Component]) {
        self.format = format
        self.components = components
    }
    
    internal func format(level: LogLevel, items: [Any], separator: String, terminator: String, file: String, line: Int, function: String, date: Date) -> String {
        let arguments = components.map { (component: Component) -> CVarArg in
            switch component {
            case .Date(let dateFormat):
                return format(date: date, dateFormat: dateFormat)
            case .File(let fullPath):
                return format(file: file, fullPath: fullPath)
            case .Function:
                return String(function)
            case .Line:
                return String(line)
            case .Level:
                return String(level).uppercased()
            case .Message:
                return items.map({ String($0) }).joined(separator: separator)
            case .Location:
                return format(file: file, line: line)
            }
        }
        
        return String(format: format, arguments: arguments) + terminator
    }
}

extension Formatter {
    func format(date: Date, dateFormat: String) -> String {
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    func format(file: String, fullPath: Bool) -> String {
        if fullPath {
            return file
        } else {
            let url = URL(fileURLWithPath: file)
            if let f = url.lastPathComponent {
                return f
            } else {
                return ""
            }
        }
    }
    
    func format(file: String, line: Int) -> String {
        return [
            format(file: file, fullPath: true),
            String(line)
            ].joined(separator: ":")
    }
}

