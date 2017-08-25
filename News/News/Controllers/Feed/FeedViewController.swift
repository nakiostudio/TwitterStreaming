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
    
    fileprivate(set) lazy var viewModel: FeedViewModel = {
        let viewModel = FeedViewModel(collectionView: self.collectionView)
        viewModel.subscribe(withClosure: self.didReceiveViewModelMessageClosure())
        return viewModel
    }()
    
    fileprivate(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        return activityIndicator
    }()
    
    fileprivate (set) lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRect.zero)
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.35)
        textField.font = UIFont.news_secondaryFont(withSize: 16)
        textField.placeholder = "Search for keywords"
        textField.textAlignment = .center
        textField.autocorrectionType = .no
        textField.layer.cornerRadius = 6.0
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Title view
        self.navigationItem.titleView = self.activityIndicator
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show activity and request Twitter credentials
        self.activityIndicator.startAnimating()
        self.viewModel.send(signal: .requestAccountAccess)
    }
    
    // MARK: - Private methods
    
    fileprivate func setupTextField() {
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
    
    func didReceiveViewModelMessageClosure() -> ((FeedViewModel.Message) -> Void) {
        return { [weak self] message in
            switch message {
            case .accessGranted:
                self?.setupTextField()
            }
        }
    }
    
}
