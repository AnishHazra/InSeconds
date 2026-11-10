//
// DebugLog.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

nonisolated func debugLog(_ message: @autoclosure () -> String) {
    #if DEBUG
    print(message())
    #endif
}
