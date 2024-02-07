//
//  Sentinel.swift
//
//
//  Created by 吴哲 on 2024/2/7.
//

import Foundation

final class Sentinel {
    private let counter = UnsafeMutablePointer<Int32>.allocate(capacity: 1)

    var value: Int32 {
        return counter.pointee
    }

    init() {
        counter.initialize(to: 0)
    }

    deinit {
        counter.deinitialize(count: 1)
        counter.deallocate()
    }

    @discardableResult
    func increase() -> Int32 {
        OSAtomicIncrement32(counter)
    }
}
