//
//  initialView.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 13/7/19.
//  Copyright © 2019 Garry Eves. All rights reserved.
//

import SwiftUI
import Combine
import evesShared

struct initialView : View {
    
    @EnvironmentObject var userAuth: UserAuth
    
    
    var body: some View {
        let myReachability = Reachability()
        let defaultUser = readDefaultInt(userDefaultName)
        
        if myCloudDB != nil
        {
            myCloudDB = CloudKitInteraction()
        }
        
        if userAuth.isLoggedin
        {
            if currentUser == nil {
                currentUser = userItem(userID: Int64(readDefaultString(userDefaultName))!)
                currentUser.getUserDetails()
            }
            
            if currentUser.currentTeam == nil
            {
                currentUser.loadTeams()
            }
            
            let iapInstance = IAPHandler()
            iapInstance.checkReceipt()
        }
        
        return ViewBuilder.buildBlock(
            defaultUser <= 0
                ? ViewBuilder.buildEither(first:
                    ViewBuilder.buildBlock(
                        myReachability.isConnectedToNetwork()
                            ? ViewBuilder.buildEither(first:
                                ViewBuilder.buildBlock(
                                    userAuth.isLoggedin
                                        ? ViewBuilder.buildEither(first:
                                            self.loadUser()
                                            mainBusinessView()
                                            )
                                        : ViewBuilder.buildEither(second:
                                            ViewBuilder.buildBlock(
                                                userAuth.newOrg
                                                    ? ViewBuilder.buildEither(first:
                                                        orgEditView()
                                                        )
                                                    : ViewBuilder.buildEither(second:
                                                        loginView()
                                                )
                                            )
                                    )
                                )
                                )
                            : ViewBuilder.buildEither(second:
                                Text("You must be connected to the Internet")
                        )
                    )
                    )
                : ViewBuilder.buildEither(second:
                    self.loadUser()
                    mainBusinessView()
            )
        )
    }
    
    func loadUser()
    {
        
    }
}

#if DEBUG
struct initialView_Previews : PreviewProvider {
    static var previews: some View {
        initialView()
    }
}
#endif
