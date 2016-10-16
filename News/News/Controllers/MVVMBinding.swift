//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation

protocol MVVMBinding: NSObjectProtocol {
    
    ///
    associatedtype Signal
    
    ///
    associatedtype Message
    
    ///
    var messagesClosure: (Message -> Void)? { get set }
    
    /**
     
     */
    func didReceive(signal signal: Signal)
    
}

extension MVVMBinding {
    
    func subscribe(withClosure closure: (Message -> Void)?) {
        self.messagesClosure = closure
    }
    
    func send(signal signal: Signal) {
        self.didReceive(signal: signal)
    }
    
}
