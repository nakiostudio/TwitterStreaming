//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import UIKit
import EasyPeasy

/**
 Controller, this class would control update of views within the view controller,
 handle, erros, loading states, etc
 */
class FeedViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    private(set) lazy var viewModel: FeedViewModel = {
        let viewModel = FeedViewModel(collectionView: self.collectionView)
        viewModel.subscribe(withClosure: self.didReceiveViewModelMessageClosure())
        return viewModel
    }()
    
    private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        return activityIndicator
    }()
    
    private (set) lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRectZero)
        textField.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.35)
        textField.font = UIFont.news_secondaryFont(withSize: 16)
        textField.placeholder = "Search for keywords"
        textField.textAlignment = .Center
        textField.autocorrectionType = .No
        textField.layer.cornerRadius = 6.0
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Title view
        self.navigationItem.titleView = self.activityIndicator
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show activity and request Twitter credentials
        self.activityIndicator.startAnimating()
        self.viewModel.send(signal: .RequestAccountAccess)
    }
    
    // MARK: - Private methods
    
    private func setupTextField() {
        self.navigationItem.titleView = self.textField
        self.textField.delegate = self.viewModel
        self.textField.becomeFirstResponder()
        self.textField <- [
            Left(5.0), Right(5.0), Height(32.0), CenterY(0.0)
        ]
    }

}

/**
 MVVM Binding methods and definitions
 */
extension FeedViewController {
    
    func didReceiveViewModelMessageClosure() -> (FeedViewModel.Message -> Void) {
        return { [weak self] message in
            switch message {
            case .AccessGranted:
                self?.setupTextField()
            }
        }
    }
    
}
