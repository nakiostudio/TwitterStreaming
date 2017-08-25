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
    public typealias CompletionClosure = (Bool, Error?) -> Void
    
    /// URL the endpoint paths will be append to
    public let baseURL: URL
    
    /// Database utils
    public let dataManager: DataManager
    
    /// Class managing stream sessions
    let streamSessionManager: StreamSessionManager
    
    /// If the user gets authenticated the account is persisted here in order to
    /// sign requests
    fileprivate(set) var twitterAccount: ACAccount?
    
    init(baseURL: URL, dataManager: DataManager, streamSessionManager: StreamSessionManager) {
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
    public func authenticate(_ completion: CompletionClosure?) {
        let store = ACAccountStore()
        let accountType = store.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
        store.requestAccessToAccounts(with: accountType, options: nil) { [weak self, store] granted, error in
            guard let twitterAccount = store.accounts.lastObject as? ACAccount, granted else {
                DispatchQueue.main.async {
                    debugPrint("Unable to authenticate")
                    completion?(granted, error)
                }
                return
            }
            
            self?.twitterAccount = twitterAccount
            DispatchQueue.main.async {
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
    public func statuses(forKeywords keywords: [String], completion: CompletionClosure?) -> NSFetchedResultsController<NSFetchRequestResult>? {
        // Disconnect from current sessions
        self.streamSessionManager.disconnect()
        
        // Prepare new streaming session
        let parameters = ["track": keywords.joined(separator: ","), "delimited": "length"]
        let responseDeserializer = ResponseDeserializer(dataManager: self.dataManager, endpoint: .statuses)
        let signedRequest = StreamAPI.signedRequest(withBaseURL: self.baseURL, endpoint: .statuses, parameters: parameters, account: twitterAccount)
        self.streamSessionManager.connect(withRequest: signedRequest) { [responseDeserializer] (data, error) in
            guard let data = data else {
                DispatchQueue.main.async {
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
    fileprivate static func signedRequest(withBaseURL baseURL: URL, endpoint: StreamEndpoint, parameters: [AnyHashable: Any], account: ACAccount?) -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint.path)
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: endpoint.method, url: url, parameters: parameters)
        request!.account = account
        return request!.preparedURLRequest()
    }

}
