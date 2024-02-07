//
//  Async.swift
//
//
//  Created by 吴哲 on 2024/2/7.
//

import Foundation

final class Async {
    private let counter = UnsafeMutablePointer<Int64>.allocate(capacity: 0)
    private let queues: [DispatchQueue]

    static let queue = Async()

    var display: DispatchQueue {
        let count = OSAtomicIncrement64(counter)
        return queues[Int(count % Int64(queues.count))]
    }

    var release: DispatchQueue {
        return .global(qos: .default)
    }

    private init() {
        counter.initialize(to: 0)
        let queueCount = max(1, min(8, ProcessInfo.processInfo.activeProcessorCount))
        var queues: [DispatchQueue] = []
        for index in 0 ..< queueCount {
            let queue = DispatchQueue(label: "com.asyncdrawingkit.render\(index)", qos: .userInitiated, attributes: .initiallyInactive)
            queues.append(queue)
        }
        self.queues = queues
    }

    deinit {
        counter.deinitialize(count: 1)
        counter.deallocate()
    }
}
