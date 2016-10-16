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
    
    /// Keywords queries
    /// ⚠️ Use the "trump" keyword at your own risk ⚠️
    private static let keywords = ["trump"]
    
    /// If there are millions of statuses coming throught this limits their
    /// appearance on screen
    private static let updateInterval: NSTimeInterval = 15
    
    /// Maximum number of items that can be passed at once to the view model
    private static let batchLimit: Int = 5
    
    /// Utils that authenticate the user and creates the stream connection
    private let streamAPI: StreamAPI
    
    /// Closure used to notify results or messages to the view model
    var messagesClosure: (Message -> Void)?
    
    /// Fetched results controller returned by the StreamAPI upon creating the
    /// stream
    private var fetchedResultsController: NSFetchedResultsController?
    
    /// Timestamp when the last item was passed to the view model
    private var lastProcessedBatch: NSTimeInterval
    
    /// Statuses queued before being passed to the view model
    private var statusesQueue: [Status]
    
    private var timer: NSTimer?
    
    override init() {
        self.statusesQueue = []
        self.lastProcessedBatch = NSDate().timeIntervalSince1970 - 10
        self.streamAPI = Service.shared.streamAPI
        super.init()
    }
    
    // MARK: - Private methods
    
    /**
     Requests access to the system social accounts
     */
    private func requestAccess() {
        self.streamAPI.authenticate { [weak self] success, error in
            if success {
                self?.getStatuses(withKeywords: FeedModel.keywords)
                return
            }
            
            self?.messagesClosure?(.ErrorReceived(error))
        }
    }
    
    /**
     Gets the statuses for the given keywords
     */
    private func getStatuses(withKeywords keywords: [String]) {
        let controller = self.streamAPI.statuses(forKeywords: keywords) { [weak self] success, error in
            if success {
                return
            }
            
            self?.messagesClosure?(.ErrorReceived(error))
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
        let now = NSDate().timeIntervalSince1970
        if now - self.lastProcessedBatch > FeedModel.updateInterval {
            // Send the newest five items, flush the queue and notify the view model
            let slice = Array(self.statusesQueue.suffix(FeedModel.batchLimit))
            self.messagesClosure?(.BatchFetched(slice))
            self.statusesQueue.removeAll()
            self.lastProcessedBatch = now
            return
        }
        
        // Try again in two seconds
        self.timer = NSTimer.scheduledTimerWithTimeInterval(
            2.0,
            target: self,
            selector: #selector(throttle),
            userInfo: nil,
            repeats: false
        )
    }
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        guard let indexPath = newIndexPath where type == .Insert else {
            return
        }
        
        // Invalidate current throttling
        self.timer?.invalidate()
        self.timer = nil
        
        // Takes items inserted and passes them to view model after the given 
        // throttle
        if let status = controller.objectAtIndexPath(indexPath) as? Status where status.text != nil {
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
        case RequestAccountAccess
    }
    
    enum Message {
        case AccessGranted
        case ErrorReceived(NSError?)
        case BatchFetched([Status])
    }
    
    func didReceive(signal signal: Signal) {
        switch signal {
        case .RequestAccountAccess:
            self.requestAccess()
        }
    }
    
}
