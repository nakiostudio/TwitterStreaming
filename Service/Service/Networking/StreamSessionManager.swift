//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation

/**
 Manager (a.k.a. Handler, Helper, Repository...) in charge of stablishing a data
 connection, resolving possible auth challenges and notifying all possible
 results
 */
class StreamSessionManager: NSObject, URLSessionDataDelegate {
    
    /// Closure alias
    typealias ResponseClosure = (Data?, Error?) -> Void
    
    /// Queue where the session data delegate methods are going to be dispatched
    unowned(unsafe) let dispatchQueue: DispatchQueue
    
    /// Session performing the data tasks created by the current helper
    fileprivate(set) lazy var session: Foundation.URLSession = {
        let operationQueue = OperationQueue()
        operationQueue.underlyingQueue = self.dispatchQueue
        let configuration = URLSessionConfiguration.default
        return Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue:operationQueue)
    }()
    
    /// Data task running
    fileprivate(set) var currentTask: URLSessionDataTask?
    
    /// Closure to be called with the data/errors to notify upon server response
    fileprivate var responseClosure: ResponseClosure?
    
    /**
     Designated initializer
     - parameter dispatchQueue: Queue where the session data delegate methods are
     going to be dispatched
     */
    init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
        super.init()
    }
    
    // MARK: - Public methods
    
    /**
     Establishes a connection with the stream endpoint for the `NSURLRequest`
     - parameter request: Request details, url, parameters, method, headers, etc
     - parameter responseClosure: Closure called upon server response / server error
     - parameter connectionClosedClosure: Closure called when the connection to the
     stream endpoint is closed
     */
    func connect(withRequest request: URLRequest, responseClosure: ResponseClosure?) {
        self.responseClosure = responseClosure
        self.currentTask = self.session.dataTask(with: request)
        self.currentTask?.resume()
    }
    
    /**
     Closes the connection for the current data task, if exists
     */
    func disconnect() {
        self.currentTask?.cancel()
    }
    
}

/**
    NSURLSessionDataDelegate methods
 */
extension StreamSessionManager {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(dataTask.state != .canceling ? .allow : .cancel)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if dataTask.state != .canceling {
            self.responseClosure?(data, nil)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.currentTask = nil
        self.responseClosure?(nil, error)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        // No need to handle this as URLSession(session: task: didCompleteWithError) 
        // will be triggered
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let host = task.originalRequest?.url?.host
        if let serverTrust = challenge.protectionSpace.serverTrust, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust && challenge.protectionSpace.host == host {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
    
}
