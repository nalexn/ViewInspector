//
//  LockExtensions.swift
//  ViewInspector
//
//  Created by Tyler Thompson on 2/4/24.
//

import Foundation

extension NSRecursiveLock {
    @discardableResult func protect<T>(_ instructions: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try instructions()
    }
    
    @discardableResult func protect<T>(_ instructions: @autoclosure () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try instructions()
    }
}
