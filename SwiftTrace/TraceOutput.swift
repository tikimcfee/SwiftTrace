//
//  TraceOutput.swift
//  SwiftTrace
//
//  Created by Ivan Lugo on 4/22/22.
//  Copyright © 2022 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/TraceOutput.swift#56 $
//

import Foundation

public enum TraceOutput: CustomDebugStringConvertible {
    case entry(invocation: SwiftTrace.Swizzle.Invocation, method: Method?, decorated: String, subLog: Bool)
    case exit (invocation: SwiftTrace.Swizzle.Invocation, method: Method?, decorated: String, subLog: Bool)
    
    public var decorated: String {
        switch self {
        case .entry(_, _, let decorated, _): return decorated
        case .exit(_, _, let decorated, _): return decorated
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .entry(let invocation, _, let decorated, let subLog):
            return """
            \(subLog ? "\n" : "")\(indent(from: invocation))\(decorated)
            """
        case .exit(let invocation, let method, let decorated, let subLog):
            let subLine = invocation.subLogged
                ? "\n\(indent(from: invocation))<-"
                : method != nil ? " ->" : ""
            return """
            \(subLine)\(decorated)\(elapsed(from: invocation))\(subLog ? "" : "\n")
            """
        }
    }
    
    private func indent(from invocation: SwiftTrace.Swizzle.Invocation) -> String {
        String(repeating: SwiftTrace.traceIndent, count: invocation.stackDepth)
    }
    
    private func elapsed(from invocation: SwiftTrace.Swizzle.Invocation) -> String {
        let delta = SwiftTrace.Swizzle.Invocation.usecTime() - invocation.timeEntered
        return String(format: SwiftTrace.timeFormat, delta * 1000.0)
    }
}

public class TraceOutputLog {
    public var onOutput: ((TraceOutput) -> Void)?
    
    func log(_ output: TraceOutput) {
        onOutput?(output)
        ?? debugPrint(output, terminator: "")
    }
}
