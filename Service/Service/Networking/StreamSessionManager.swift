//
//  Created by Carlos Vidal Pallin on 15/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation

/**
 Manager (a.k.a. Handler, Helper, Repository...) in charge of stablishing a data
 connection, resolving possible auth challenges and notifying all possible
 results
 */
class StreamSessionManager: NSObject, NSURLSessionDataDelegate {
    
    /// Closure alias
    typealias ResponseClosure = (NSData?, NSError?) -> Void
    
    /// Closure alias
    typealias ConnectionClosedClosure = () -> Void
    
    /// Queue where the session data delegate methods are going to be dispatched
    unowned(unsafe) let dispatchQueue: dispatch_queue_t
    
    /// Session performing the data tasks created by the current helper
    private(set) lazy var session: NSURLSession = {
        let operationQueue = NSOperationQueue()
        operationQueue.underlyingQueue = self.dispatchQueue
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: configuration, delegate: self, delegateQueue:operationQueue)
    }()
    
    /// Data task running
    private(set) var currentTask: NSURLSessionDataTask? {
        didSet {
            if self.currentTask == nil {
                self.connectionClosedClosure?()
            }
        }
    }
    
    /// Closure to be called with the data/errors to notify upon server response
    private var responseClosure: ResponseClosure?
    
    /// Closure to be called when the connection to the stream endpoint is closed
    private var connectionClosedClosure: ConnectionClosedClosure?
    
    /**
     Designated initializer
     - parameter dispatchQueue: Queue where the session data delegate methods are
     going to be dispatched
     */
    init(dispatchQueue: dispatch_queue_t) {
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
    func connect(withRequest request: NSURLRequest, responseClosure: ResponseClosure?, connectionClosedClosure: ConnectionClosedClosure?) {
        self.responseClosure = responseClosure
        self.connectionClosedClosure = connectionClosedClosure
        self.currentTask = self.session.dataTaskWithRequest(request)
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
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        completionHandler(dataTask.state != .Canceling ? .Allow : .Cancel)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if dataTask.state != .Canceling {
            self.responseClosure?(data, nil)
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        self.currentTask = nil
        self.responseClosure?(nil, error)
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        self.currentTask = nil
        self.responseClosure?(nil, error)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        let host = task.originalRequest?.URL?.host
        if let serverTrust = challenge.protectionSpace.serverTrust where challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust && challenge.protectionSpace.host == host {
            completionHandler(.UseCredential, NSURLCredential(forTrust: serverTrust))
        }
    }
    
}
