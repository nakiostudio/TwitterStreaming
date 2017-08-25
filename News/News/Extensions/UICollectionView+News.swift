//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import UIKit

/**
 Helper methods
 */
extension UICollectionView {
    
    func news_registerNib<T>(fromClass class: T.Type) where T: UICollectionViewCell {
        let name = NSStringFromClass(T.self).components(separatedBy: ".").last ?? ""
        let nib = UINib(nibName: name, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: name)
    }
    
    func news_dequeueCell<T>(withClass class: T.Type, forIndexPath indexPath: IndexPath) -> T where T: UICollectionViewCell {
        let name = NSStringFromClass(T.self).components(separatedBy: ".").last ?? ""
        return self.dequeueReusableCell(withReuseIdentifier: name, for: indexPath) as! T
    }
    
}
