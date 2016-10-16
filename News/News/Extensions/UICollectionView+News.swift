//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func news_registerNib<T where T: UICollectionViewCell>(fromClass class: T.Type) {
        let name = NSStringFromClass(T).componentsSeparatedByString(".").last ?? ""
        let nib = UINib(nibName: name, bundle: nil)
        self.registerNib(nib, forCellWithReuseIdentifier: name)
    }
    
    func news_dequeueCell<T where T: UICollectionViewCell>(withClass class: T.Type, forIndexPath indexPath: NSIndexPath) -> T {
        let name = NSStringFromClass(T).componentsSeparatedByString(".").last ?? ""
        return self.dequeueReusableCellWithReuseIdentifier(name, forIndexPath: indexPath) as! T
    }
    
}
