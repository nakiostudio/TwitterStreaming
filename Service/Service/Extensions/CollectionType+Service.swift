//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation

/**
 Helper methods
 */
extension Collection {
    
    /**     
     A safer way of accessing items within an array
     - parameter index: Index of the item to be retrieved
     - returns The item at the index given if it exists
     */
    subscript (safe index: Index) -> Iterator.Element? {
        if self.endIndex > index && self.startIndex <= index {
            return self[index]
        }
        return nil
    }
    
}
