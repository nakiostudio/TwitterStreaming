//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import UIKit
import CoreData
import Service

/**
 View model binging data and view
 */
class FeedViewModel: NSObject, MVVMBinding, UICollectionViewDataSource, UICollectionViewDelegate {
    
    /// Max number of items visible on screen
    fileprivate static let batchLimit: Int = 20
    
    /// Closure used to notify results or messages to the view
    var messagesClosure: ((Message) -> Void)?
    
    fileprivate(set) lazy var model: FeedModel = {
        let model = FeedModel()
        model.subscribe(withClosure: self.didReceiveModelMessageClosure())
        return model
    }()
    
    fileprivate(set) weak var collectionView: UICollectionView?
    
    /// Statuses or tweeks currently on screen
    fileprivate(set) var statuses: [Status]
    
    init(collectionView: UICollectionView) {
        self.statuses = []
        super.init()
        self.collectionView = collectionView
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.news_registerNib(fromClass: StatusCell.self)
        self.collectionView?.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.statuses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.news_dequeueCell(withClass: StatusCell.self, forIndexPath: indexPath)
        let status = self.statuses[indexPath.item]
        cell.configure(withStatus: status)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let status = self.statuses[indexPath.item]
        let width = collectionView.bounds.width
        let height = StatusCell.height(withStatus: status, width: width)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    // MARK: Private methods
    
    /**
     This method takes the batch passed from the model and performs the insertions
     and deletions required in order to never show more than 5 items on screen
     */
    fileprivate func process(batch: [Status]) {
        let statusesCount = self.statuses.count
        
        // Check index paths of items to delete
        var toDelete = FeedViewModel.batchLimit - statusesCount - batch.count
        toDelete = toDelete >= 0 ? 0 : (toDelete * -1)
        var indexPathsToDelete: [IndexPath] = []
        for i in 0..<toDelete {
            indexPathsToDelete.append(IndexPath(item: statusesCount-i-1, section: 0))
            self.statuses.removeLast()
        }
        
        // Check index paths of items to insert
        var indexPathsToInsert: [IndexPath] = []
        for i in 0..<batch.count {
            indexPathsToInsert.append(IndexPath(item: i, section: 0))
        }
        
        // Perform updates
        self.collectionView?.performBatchUpdates({
            self.collectionView?.deleteItems(at: indexPathsToDelete)
        }, completion: { _ in
            var mutableBatch = batch
            mutableBatch.append(contentsOf: self.statuses)
            self.statuses = mutableBatch
            self.collectionView?.performBatchUpdates({ 
                self.collectionView?.insertItems(at: indexPathsToInsert)
            }, completion: nil)
        })
    }
    
    /**
     Removes all the items in the `UICollectionView`
     */
    fileprivate func clearStatuses() {
        let statusesCount = self.statuses.count
        
        // Check index paths of items to delete
        var toDelete = -statusesCount
        toDelete = toDelete >= 0 ? 0 : (toDelete * -1)
        var indexPathsToDelete: [IndexPath] = []
        for i in 0..<toDelete {
            indexPathsToDelete.append(IndexPath(item: statusesCount-i-1, section: 0))
            self.statuses.removeLast()
        }
        
        // Perform updates
        self.collectionView?.performBatchUpdates({
            self.collectionView?.deleteItems(at: indexPathsToDelete)
        }, completion: nil)
    }
    
}

/**
 UITextFieldDelegate methods
 */
extension FeedViewModel: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.characters.count > 0 else {
            return false
        }
        
        // Resign first responder
        textField.resignFirstResponder()
        
        // Split the query into keywords and perform search
        let statuses = text.components(separatedBy: " ")
        self.model.send(signal: .getStatuses(statuses))
        
        // Clear collection
        self.clearStatuses()
        
        return true
    }
    
}

/**
 MVVM Binding methods and definitions
 */
extension FeedViewModel {
    
    enum Signal {
        case requestAccountAccess
    }
    
    enum Message {
        case accessGranted
    }
    
    func didReceive(signal: Signal) {
        switch signal {
        case .requestAccountAccess:
            self.model.send(signal: .requestAccountAccess)
        }
    }
    
    /**
     Messages received from model
     */
    func didReceiveModelMessageClosure() -> ((FeedModel.Message) -> Void) {
        return { [weak self] message in
            switch message {
            case .accessGranted:
                self?.messagesClosure?(.accessGranted)
            case .errorReceived(_):
                // TODO: Handle this
                break
            case let .batchFetched(batch):
                self?.process(batch: batch)
            }
        }
    }
    
}
