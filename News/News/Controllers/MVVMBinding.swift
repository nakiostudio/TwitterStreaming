//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation

/**
 Protocol defining the way of communicating between view, view model and
 model. Handy to test view, viewmodel and model separately
 */
protocol MVVMBinding: NSObjectProtocol {
    
    /// Type representing a signal passing to view model or model to perform
    /// an action
    associatedtype Signal
    
    /// Type representing the result of an action carried out by view model or
    /// model
    associatedtype Message
    
    /// Closure used by view model or model to notify results or messages
    var messagesClosure: ((Message) -> Void)? { get set }
    
    /**
     Method to be defined within the classes conforming this protocol to react
     to the signals passed
     */
    func didReceive(signal: Signal)
    
}

extension MVVMBinding {
    
    /**
     As soon as a class subscribes to the view model/model it will start
     receiving messages from view/model
     */
    func subscribe(withClosure closure: ((Message) -> Void)?) {
        self.messagesClosure = closure
    }
    
    /**
     An easy way for the subscriber to send signals
     */
    func send(signal: Signal) {
        self.didReceive(signal: signal)
    }
    
}
