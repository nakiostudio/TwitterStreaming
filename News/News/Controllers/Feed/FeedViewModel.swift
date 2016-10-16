//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import UIKit
import CoreData
import Service

class FeedViewModel: NSObject, MVVMBinding, UICollectionViewDataSource, UICollectionViewDelegate {
    
    ///
    private static let batchLimit: Int = 5
    
    ///
    var messagesClosure: (Message -> Void)?
    
    ///
    private(set) lazy var model: FeedModel = {
        let model = FeedModel()
        model.subscribe(withClosure: self.didReceiveModelMessageClosure())
        return model
    }()
    
    ///
    private(set) weak var collectionView: UICollectionView?
    
    ///
    private(set) var statuses: [Status]
    
    /*
 
     */
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.statuses.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.news_dequeueCell(withClass: StatusCell.self, forIndexPath: indexPath)
        let status = self.statuses[indexPath.item]
        cell.configure(withStatus: status)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout methods
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let status = self.statuses[indexPath.item]
        let width = CGRectGetWidth(collectionView.bounds)
        let height = StatusCell.height(withStatus: status, width: width)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    // MARK: Private methods
    
    private func process(batch batch: [Status]) {
        let statusesCount = self.statuses.count
        var toDelete = FeedViewModel.batchLimit - statusesCount - batch.count
        toDelete = toDelete >= 0 ? 0 : (toDelete * -1)
        var indexPathsToDelete: [NSIndexPath] = []
        for i in 0..<toDelete {
            indexPathsToDelete.append(NSIndexPath(forItem: statusesCount-i-1, inSection: 0))
            self.statuses.removeLast()
        }
        var indexPathsToInsert: [NSIndexPath] = []
        for i in 0..<batch.count {
            indexPathsToInsert.append(NSIndexPath(forItem: i, inSection: 0))
        }
        
        self.collectionView?.performBatchUpdates({
            self.collectionView?.deleteItemsAtIndexPaths(indexPathsToDelete)
        }, completion: { _ in
            var mutableBatch = batch
            mutableBatch.appendContentsOf(self.statuses)
            self.statuses = mutableBatch
            self.collectionView?.performBatchUpdates({ 
                self.collectionView?.insertItemsAtIndexPaths(indexPathsToInsert)
            }, completion: nil)
        })
    }
    
}

/**
 MVVM Binding methods and definitions
 */
extension FeedViewModel {
    
    enum Signal {
        case LoadContent
    }
    
    enum Message {
        case DidRequest
    }
    
    func didReceive(signal signal: Signal) {
        switch signal {
        case .LoadContent:
            self.model.send(signal: .RequestAccountAccess)
        }
    }
    
    func didReceiveModelMessageClosure() -> (FeedModel.Message -> Void) {
        return { [weak self] message in
            switch message {
            case .AccessGranted:
                break
            case let .ErrorReceived(error):
                break
            case let .BatchFetched(batch):
                self?.process(batch: batch)
            }
        }
    }
    
}
