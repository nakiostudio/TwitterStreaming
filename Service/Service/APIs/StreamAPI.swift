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
public class StreamAPI {
    
    ///
    public typealias CompletionClosure = (Bool, NSError?) -> Void
    
    ///
    public let baseURL: NSURL
    
    ///
    public let dataManager: DataManager
    
    ///
    let streamSessionManager: StreamSessionManager
    
    ///
    private(set) var twitterAccount: ACAccount?
    
    ///
    init(baseURL: NSURL, dataManager: DataManager, streamSessionManager: StreamSessionManager) {
        self.baseURL = baseURL
        self.dataManager = dataManager
        self.streamSessionManager = streamSessionManager
    }
    
    // MARK: - Public methods
    
    /**
 
     */
    public func authenticate(completion: CompletionClosure?) {
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
    public func statuses(forKeywords keywords: [String], completion: CompletionClosure?) -> NSFetchedResultsController? {
        let parameters = ["track": keywords.joinWithSeparator(","), "delimited": "length"]
        let responseDeserializer = ResponseDeserializer(dataManager: self.dataManager, endpoint: .Statuses)
        let signedRequest = StreamAPI.signedRequest(withBaseURL: self.baseURL, endpoint: .Statuses, parameters: parameters, account: twitterAccount)
        self.streamSessionManager.connect(withRequest: signedRequest) { [responseDeserializer] (data, error) in
            guard let data = data else {
                completion?(false, error)
                return
            }
            
            responseDeserializer.process(data: data)
        }
        
        //
        return nil
    }
    
    // MARK: - Private methods
    
    /**
     
     */
    private static func signedRequest(withBaseURL baseURL: NSURL, endpoint: StreamEndpoint, parameters: [NSObject: AnyObject], account: ACAccount?) -> NSURLRequest {
        let url = baseURL.URLByAppendingPathComponent(endpoint.path)
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: endpoint.method, URL: url, parameters: parameters)
        request.account = account
        return request.preparedURLRequest()
    }

}
