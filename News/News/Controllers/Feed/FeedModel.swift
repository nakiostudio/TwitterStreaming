//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import Service
import CoreData

/**
 Element in charge or authenticating the user and retrieving the items stored in
 database coming from the stream
 */
class FeedModel: NSObject, MVVMBinding, NSFetchedResultsControllerDelegate {
    
    /// If there are millions of statuses coming throught this limits their
    /// appearance on screen
    fileprivate static let updateInterval: TimeInterval = 3
    
    /// Maximum number of items that can be passed at once to the view model
    fileprivate static let batchLimit: Int = 1
    
    /// Utils that authenticate the user and creates the stream connection
    fileprivate let streamAPI: StreamAPI
    
    /// Closure used to notify results or messages to the view model
    var messagesClosure: ((Message) -> Void)?
    
    /// Fetched results controller returned by the StreamAPI upon creating the
    /// stream
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    /// Timestamp when the last item was passed to the view model
    fileprivate var lastProcessedBatch: TimeInterval
    
    /// Statuses queued before being passed to the view model
    fileprivate var statusesQueue: [Status]
    
    override init() {
        self.statusesQueue = []
        self.lastProcessedBatch = Date().timeIntervalSince1970 - 2
        self.streamAPI = Service.shared.streamAPI
        super.init()
    }
    
    // MARK: - Private methods
    
    /**
     Requests access to the system social accounts
     */
    fileprivate func requestAccess() {
        self.streamAPI.authenticate { [weak self] success, error in
            if success {
                self?.messagesClosure?(.accessGranted)
                return
            }
            
            self?.messagesClosure?(.errorReceived(error))
        }
    }
    
    /**
     Terminates the fetching section if exists
     */
    fileprivate func destroyCurrentFetchedResultsController() {
        self.fetchedResultsController?.delegate = nil
        self.fetchedResultsController = nil
    }
    
    /**
     Gets the statuses for the given keywords
     */
    fileprivate func getStatuses(withKeywords keywords: [String]) {
        let controller = self.streamAPI.statuses(forKeywords: keywords) { [weak self] success, error in
            if success {
                return
            }
            
            self?.messagesClosure?(.errorReceived(error))
        }
        
        // If the stream is going to be open a fetched results controller is
        // returned. We make the model delegate to start retrieving items
        self.fetchedResultsController = controller
        self.fetchedResultsController?.delegate = self
        try! self.fetchedResultsController?.performFetch()
    }
    
    /**
     Controls how frequently we feed the view model with new results
     */
    func throttle() {
        let now = Date().timeIntervalSince1970
        if now - self.lastProcessedBatch > FeedModel.updateInterval && self.fetchedResultsController != nil {
            // Send the newest five items, flush the queue and notify the view model
            let slice = Array(self.statusesQueue.suffix(FeedModel.batchLimit))
            self.messagesClosure?(.batchFetched(slice))
            self.statusesQueue.removeAll()
            self.lastProcessedBatch = now
            return
        }
        
        // Try again after the interval defined by `updateInterval`
        let interval = DispatchTime.now() + Double(Int64(FeedModel.updateInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: interval) {
            self.throttle()
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let indexPath = newIndexPath, type == .insert && controller.delegate != nil else {
            return
        }
        
        // Takes items inserted and passes them to view model after the given 
        // throttle
        if let status = controller.object(at: indexPath) as? Status, status.text != nil {
            self.statusesQueue.append(status)
            self.throttle()
        }
    }
    
}

/**
 MVVM Binding methods and definitions
 */
extension FeedModel {
    
    enum Signal {
        case requestAccountAccess
        case getStatuses([String])
    }
    
    enum Message {
        case accessGranted
        case errorReceived(Error?)
        case batchFetched([Status])
    }
    
    func didReceive(signal: Signal) {
        switch signal {
        case .requestAccountAccess:
            self.requestAccess()
        case let .getStatuses(keywords):
            self.destroyCurrentFetchedResultsController()
            self.getStatuses(withKeywords: keywords)
        }
    }
    
}
