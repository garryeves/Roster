//
//  mainSplitView.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 17/6/18.
//  Copyright © 2018 Garry Eves. All rights reserved.
//

import UIKit

class mainSplitView: UISplitViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = .primaryOverlay
    }
}
