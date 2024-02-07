//
//  Transaction.swift
//
//
//  Created by 吴哲 on 2024/2/7.
//

import Foundation

public final class Transaction: Hashable {
    static var transactionSet: Set<Transaction> = []

    static var onceSetUp: (() -> Void)? = { Transaction.setUp() }

    static func setUp() {
        let runloop = CFRunLoopGetMain()
        let callback: @convention(c) (CFRunLoopObserver?, CFRunLoopActivity, UnsafeMutableRawPointer?) -> Void = { _, _, _ in
            Transaction.callback()
        }
        let observer = CFRunLoopObserverCreate(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue | CFRunLoopActivity.exit.rawValue, true, 0xFFFFFF, callback, nil)
        CFRunLoopAddObserver(runloop, observer, .commonModes)
    }

    static func callback() {
        guard !transactionSet.isEmpty else { return }
        let currentSet = transactionSet
        transactionSet = .init()
        for transaction in currentSet {
            _ = transaction.target.perform(transaction.selector)
        }
    }

    let target: AnyObject
    let selector: Selector

    public init(target: AnyObject, selector: Selector) {
        self.target = target
        self.selector = selector
    }

    public func commit() {
        Transaction.onceSetUp?()
        Transaction.onceSetUp = nil
        Transaction.transactionSet.insert(self)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(target))
        hasher.combine(selector)
    }

    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.target === rhs.target && lhs.selector == rhs.selector
    }
}
