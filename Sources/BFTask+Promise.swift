#if !PMKCocoaPods
import PromiseKit
#endif
import Bolts

extension Promise {
    /**
     The provided closure is executed when this promise is resolved.
     */
    public func then<U>(on q: DispatchQueue? = conf.Q.map, body: @escaping (T) -> BFTask<U>) -> Promise<U?> {
        return then(on: q) { tee -> Promise<U?> in
            let tokenSource = BFCancellationTokenSource()
            let task = body(tee)
            return Promise<U?>(cancellableTask: tokenSource) { seal in
                task.continueWith(block: { task in
                    if task.isCompleted {
                        seal.fulfill(task.result)
                    } else if let error = task.error {
                        seal.reject(error)
                    } else {
                        seal.reject(PMKError.invalidCallingConvention)
                    }
                    return nil
                }, cancellationToken: tokenSource.token)
            }
        }
    }
}

/// Extend BFCancellationTokenSource to be a CancellableTask
extension BFCancellationTokenSource: CancellableTask {
    public var isCancelled: Bool {
        return token.isCancellationRequested
    }
}

extension CancellablePromise {
    /**
     The provided closure is executed when this cancellable promise is resolved.
     */
    public func then<U>(on q: DispatchQueue? = conf.Q.map, body: @escaping (T) -> BFTask<U>) -> CancellablePromise<U?> {
        return cancellable(promise.then(on: q, body: body), cancelContext: self.cancelContext)
    }
}
