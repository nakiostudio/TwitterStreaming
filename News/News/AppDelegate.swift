//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import UIKit
import Service

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        debugPrint("Initialized Service pointing to: \(Service.shared.baseURL)")
        return true
    }
    
}

extension Service {
    
    /// Static accessor to the Service library
    static let shared: Service = {
        return Service(baseURL: URL(string: "https://stream.twitter.com/1.1")!)
    }()
    
}
