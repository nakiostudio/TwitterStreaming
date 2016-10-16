//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    
    ///
    @IBOutlet var collectionView: UICollectionView!
    
    ///
    private(set) lazy var viewModel: FeedViewModel = {
        let viewModel = FeedViewModel(collectionView: self.collectionView)
        viewModel.subscribe(withClosure: self.didReceiveViewModelMessageClosure())
        return viewModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.send(signal: .LoadContent)
    }

}


/**
 MVVM Binding methods and definitions
 */
extension FeedViewController {
    
    func didReceiveViewModelMessageClosure() -> (FeedViewModel.Message -> Void) {
        return { message in
            
        }
    }
    
}
