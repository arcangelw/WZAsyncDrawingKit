//
//  AsyncLayer.swift
//
//
//  Created by 吴哲 on 2024/2/7.
//

import UIKit

public protocol AsyncLayerDelegate: AnyObject {
    func createAsyncDisplayTask() -> AsyncLayer.DisplayTask
}

public extension AsyncLayer {
    final class DisplayTask {
        public var isDisplaysAsynchronously = true

        public var willDisplay: ((_ layer: CALayer) -> Void)?

        public var display: ((_ context: CGContext, _ size: CGSize, _ isCancelled: () -> Bool) -> Void)?

        public var didDisplay: ((_ layer: CALayer, _ finished: Bool) -> Void)?
    }
}

public final class AsyncLayer: CALayer {
    private let sentinel = Sentinel()

    override public init() {
        super.init()
        contentsScale = UITraitCollection.current.displayScale
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        sentinel.increase()
    }

    override public func setNeedsDisplay() {
        cancel()
        super.setNeedsDisplay()
    }

    override public func display() {
        super.contents = super.contents
        _display()
    }

    private func _display() {
        guard let delegate = delegate as? AsyncLayerDelegate else {
            return
        }
        let task = delegate.createAsyncDisplayTask()
        let isAsync = task.isDisplaysAsynchronously

        guard task.display != nil else {
            task.willDisplay?(self)
            contents = nil
            task.didDisplay?(self, true)
            return
        }

        let size = bounds.size
        let isOpaque = isOpaque
        let scale = contentsScale
        if size.width < 1 || size.height < 1 {
            let image = contents as! CGImage?
            contents = nil
            if image != nil {
                Async.queue.release.async {
                    _ = image
                }
            }
            task.didDisplay?(self, true)
            return
        }
        if isAsync {
            task.willDisplay?(self)
            let sentinel = sentinel
            let value = sentinel.value
            let isCancelled = {
                sentinel.value != value
            }
            let backgroundColor = isOpaque && backgroundColor != nil ? backgroundColor : nil
            Async.queue.display.async {
                if isCancelled() { return }
                let format = UIGraphicsImageRendererFormat()
                format.opaque = isOpaque
                format.scale = scale
                let renderer = UIGraphicsImageRenderer(size: size, format: format)
                let image = renderer.image { rendererContext in
                    let context = rendererContext.cgContext
                    if isOpaque {
                        context.saveGState()
                        if let backgroundColor = backgroundColor {
                            context.setFillColor(backgroundColor)
                        } else {
                            context.setFillColor(UIColor.clear.cgColor)
                        }
                        context.addRect(.init(origin: .zero, size: size))
                        context.fillPath()
                        context.restoreGState()
                    }
                    task.display?(context, size, isCancelled)
                }
                if isCancelled() {
                    DispatchQueue.main.async {
                        task.didDisplay?(self, false)
                    }
                    return
                }
                DispatchQueue.main.async {
                    if isCancelled() {
                        task.didDisplay?(self, false)
                    } else {
                        self.contents = image.cgImage
                        task.didDisplay?(self, true)
                    }
                }
            }

        } else {
            sentinel.increase()
            task.willDisplay?(self)
            let format = UIGraphicsImageRendererFormat()
            format.opaque = isOpaque
            format.scale = scale
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            let image = renderer.image { rendererContext in
                let context = rendererContext.cgContext
                if isOpaque {
                    context.saveGState()
                    if let backgroundColor = backgroundColor {
                        context.setFillColor(backgroundColor)
                    } else {
                        context.setFillColor(UIColor.clear.cgColor)
                    }
                    context.addRect(.init(origin: .zero, size: size))
                    context.fillPath()
                    context.restoreGState()
                }
                task.display?(context, size, { false })
            }
            contents = image.cgImage
            task.didDisplay?(self, true)
        }
    }

    private func cancel() {
        sentinel.increase()
    }
}
