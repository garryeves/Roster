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
        
        var teamList: userTeams!
        var displayList: [String] = Array()
        
        if myCloudDB == nil
        {
            myCloudDB = CloudKitInteraction()
        }
        
        if defaultUser > 0
        {
            if currentUser == nil{
                currentUser = userItem(userID: Int64(readDefaultString(userDefaultName))!)
                currentUser.getUserDetails()
            }

            if currentUser.currentTeam == nil
            {
                currentUser.loadTeams()
            }

            if readDefaultInt("teamID") >= 0
            {
                currentUser.currentTeam = team(teamID: Int64(readDefaultInt("teamID")))
            }

            let iapInstance = IAPHandler()
            iapInstance.checkReceipt()
            
            if teamList == nil
            {
                teamList = userTeams(userID: currentUser.userID)
            }
            
            displayList.removeAll()
            
            for item in teamList.UserTeams
            {
                let tempTeam = team(teamID: item.teamID)
                displayList.append(tempTeam.name)
            }
            
            print("list = \(displayList.count)")
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
                    mainBusinessView()
            )
        )
    }
}

#if DEBUG
struct initialView_Previews : PreviewProvider {
    static var previews: some View {
        initialView()
    }
}
#endif
