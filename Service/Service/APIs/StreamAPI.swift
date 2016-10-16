//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import CoreData
import Social
import Accounts

/**
 Tools to authenticate the user and establish a stream connection
 */
public class StreamAPI {
    
    /// Alias of the closure called to notify results
    public typealias CompletionClosure = (Bool, NSError?) -> Void
    
    /// URL the endpoint paths will be append to
    public let baseURL: NSURL
    
    /// Database utils
    public let dataManager: DataManager
    
    /// Class managing stream sessions
    let streamSessionManager: StreamSessionManager
    
    /// If the user gets authenticated the account is persisted here in order to
    /// sign requests
    private(set) var twitterAccount: ACAccount?
    
    init(baseURL: NSURL, dataManager: DataManager, streamSessionManager: StreamSessionManager) {
        self.baseURL = baseURL
        self.dataManager = dataManager
        self.streamSessionManager = streamSessionManager
    }
    
    // MARK: - Public methods
    
    /**
     Authenticates the user using the social accounts existing in the current
     device
     - parameter completion: Closure called to notify the result
     */
    public func authenticate(completion: CompletionClosure?) {
        let store = ACAccountStore()
        let accountType = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        store.requestAccessToAccountsWithType(accountType, options: nil) { [weak self, store] granted, error in
            guard let twitterAccount = store.accounts.last as? ACAccount where granted else {
                dispatch_async(dispatch_get_main_queue()) {
                    debugPrint("Unable to authenticate")
                    completion?(granted, error)
                }
                return
            }
            
            self?.twitterAccount = twitterAccount
            dispatch_async(dispatch_get_main_queue()) {
                completion?(granted, error)
            }
        }
    }
    
    /**
     Opens a stream of statuses filtered by the given keyword
     - parameter keywords: Keywords the statuses will be filtered with
     - parameter completion: Closure called to notify error or whether the stream
     has been closes
     - returns A `NSFetchedResultsController` to fetch the statuses stored in database
     upon server response
     */
    public func statuses(forKeywords keywords: [String], completion: CompletionClosure?) -> NSFetchedResultsController? {
        let parameters = ["track": keywords.joinWithSeparator(","), "delimited": "length"]
        let responseDeserializer = ResponseDeserializer(dataManager: self.dataManager, endpoint: .Statuses)
        let signedRequest = StreamAPI.signedRequest(withBaseURL: self.baseURL, endpoint: .Statuses, parameters: parameters, account: twitterAccount)
        self.streamSessionManager.connect(withRequest: signedRequest) { [responseDeserializer] (data, error) in
            guard let data = data else {
                dispatch_async(dispatch_get_main_queue()) {
                    completion?(false, error)
                }
                return
            }
            
            responseDeserializer.process(data: data)
        }
    
        // `NSFetchedResultsController` to fetch the received statuses
        let fetchedResultsController = Status.fetchedResultsController(withObjectContext: self.dataManager.mainObjectContext)
        return fetchedResultsController
    }
    
    // MARK: - Private methods
    
    /**
     Creates a request for the given endpoint and parameters and signes it with the
     account provided
     */
    private static func signedRequest(withBaseURL baseURL: NSURL, endpoint: StreamEndpoint, parameters: [NSObject: AnyObject], account: ACAccount?) -> NSURLRequest {
        let url = baseURL.URLByAppendingPathComponent(endpoint.path)
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: endpoint.method, URL: url, parameters: parameters)
        request.account = account
        return request.preparedURLRequest()
    }

}
