//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import Service
import CoreData

class FeedModel: NSObject, MVVMBinding, NSFetchedResultsControllerDelegate {
    
    private static let keywords = ["trump"]
    
    private static let updateInterval: NSTimeInterval = 15
    
    private static let batchLimit: Int = 5
    
    ///
    let streamAPI: StreamAPI
    
    ///
    var messagesClosure: (Message -> Void)?
    
    ///
    private(set) var fetchedResultsController: NSFetchedResultsController?
    
    ///
    private(set) var lastProcessedBatch: NSTimeInterval
    
    ///
    private(set) var statusesQueue: [Status]
    
    /**
 
     */
    override init() {
        self.statusesQueue = []
        self.lastProcessedBatch = NSDate().timeIntervalSince1970 - 10
        self.streamAPI = Service.shared.streamAPI
        super.init()
    }
    
    // MARK: - Private methods
    
    private func requestAccess() {
        self.streamAPI.authenticate { [weak self] success, error in
            if success {
                self?.getStatuses(withKeywords: FeedModel.keywords)
                return
            }
            
            self?.messagesClosure?(.ErrorReceived(error))
        }
    }
    
    private func getStatuses(withKeywords keywords: [String]) {
        let controller = self.streamAPI.statuses(forKeywords: keywords) { [weak self] success, error in
            if success {
                return
            }
            
            self?.messagesClosure?(.ErrorReceived(error))
        }
        
        //
        self.fetchedResultsController = controller
        self.fetchedResultsController?.delegate = self
        try! self.fetchedResultsController?.performFetch()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        guard let indexPath = newIndexPath where type == .Insert else {
            return
        }
        
        if let status = controller.objectAtIndexPath(indexPath) as? Status {
            self.statusesQueue.append(status)
            
            let now = NSDate().timeIntervalSince1970
            if now - self.lastProcessedBatch > FeedModel.updateInterval {
                let slice = Array(self.statusesQueue.suffix(FeedModel.batchLimit))
                self.messagesClosure?(.BatchFetched(slice))
                self.statusesQueue.removeAll()
                self.lastProcessedBatch = now
                return
            }
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
