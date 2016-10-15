//
//  Created by Carlos Vidal Pallin on 15/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import CoreData
import Social
import Accounts

/**
 
 */
public class TwitterStreamAPI {
    
    ///
    public typealias AuthenticationResultClosure = (Bool, NSError?) -> Void
    
    ///
    private static let mappingQueue = dispatch_queue_create("com.nakiostudio.mapping", DISPATCH_QUEUE_SERIAL)
    
    ///
    public let dataManager: DataManager
    
    ///
    private(set) lazy var streamSessionManager: StreamSessionManager = {
        let manager = StreamSessionManager(dispatchQueue: TwitterStreamAPI.mappingQueue)
        return manager
    }()
    
    ///
    private(set) var twitterAccount: ACAccount?
    
    ///
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    // MARK: - Public methods
    
    /**
 
     */
    public func authenticate(completion: AuthenticationResultClosure?) {
        let store = ACAccountStore()
        let accountType = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        store.requestAccessToAccountsWithType(accountType, options: nil) { [weak self, store] granted, error in
            guard let twitterAccount = store.accounts.last as? ACAccount where granted else {
                debugPrint("Unable to authenticate")
                completion?(granted, error)
                return
            }
            
            self?.twitterAccount = twitterAccount
            completion?(granted, error)
        }
    }
    
    /**
 
     */
    public func stream(withStatus status: String) -> NSFetchedResultsController? {
        return nil
    }
    
    // MARK: - Private methods
    
    /**
     
     */
    private func stream(withEndpoint TwitterStreamEndpoint) {
        
    }
    
}
