//
//  Copyright © Marc Rollin.
//

import Foundation

infix operator .. : MultiplicationPrecedence

@discardableResult
public func .. <T>(object: T, block: (inout T) -> Void) -> T {
    var object = object
    block(&object)
    return object
}

@discardableResult
public func .. <T>(object: T, block: (inout T) throws -> Void) throws -> T {
    var object = object
    try block(&object)
    return object
}

@discardableResult
public func .. <T>(object: T, block: (inout T) async throws -> Void) async throws -> T {
    var object = object
    try await block(&object)
    return object
}
