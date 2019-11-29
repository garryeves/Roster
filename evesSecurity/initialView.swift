////
////  initialView.swift
////  Shift Dashboard
////
////  Created by Garry Eves on 13/7/19.
////  Copyright © 2019 Garry Eves. All rights reserved.
////
//
import SwiftUI
//import Combine
import evesShared

struct initialView : View {

    init() {
        let defaultUser = readDefaultInt(userDefaultName)
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
            
            let iapInstance = IAPHandler()
            iapInstance.checkReceipt()
        }
        
        if defaultUser > 0 {
            if currentUser == nil {
                currentUser = userItem(userID: Int64(readDefaultString(userDefaultName))!)
                currentUser.getUserDetails()
            }
            
            if currentUser.currentTeam == nil {
                currentUser.loadTeams()
            }
            
            if currentUser.teamList.count == 0 {
                currentUser.loadUserTeams()
            }
        }
    }
    
    var body: some View {
        return securityInitialView()
    }
}
