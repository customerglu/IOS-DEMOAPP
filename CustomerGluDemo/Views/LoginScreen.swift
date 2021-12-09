//
//  LoginScreen.swift
//  CustomerGluDemo
//
//  Created by kapil on 29/11/21.
//

import SwiftUI
import CustomerGlu
import Firebase

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

struct LoginScreen: View {
    
    @State var userid: String = ""
    @State var username: String = ""
    @State var referId: String = ""
    
    @State var isActive = false
    @State var attemptingLogin = false
        
    var body: some View {
        NavigationView {
            VStack {
                Image("customerglu")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 25)
                TextField("UserId", text: $userid)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                TextField("Username", text: $username)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                TextField("ReferId (Optional)", text: $referId)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                HStack {
                    NavigationLink(destination: HomeScreen(), isActive: $isActive) {
                        Button(action: {
                            if userid.isEmpty || username.isEmpty {
                                return
                            }
                            submitActionClicked(userId: userid, userName: username, referenceId: referId)
                        }) {
                            LoginButtonContent()
                        }
                    }
                }
            }
            .padding()
        }.ignoresSafeArea(.all)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
    
    func submitActionClicked(userId: String, userName: String, referenceId: String) {

        let fcmRegTokenMessage = UserDefaults.standard.string(forKey: "fcmtoken") ?? "defaultvalue"
        let apnsDeviceTokenMessage = UserDefaults.standard.string(forKey: "apntoken") ?? "defaultvalue"

        var userData = [String: AnyHashable]()
        userData["userId"] = userId
        userData["deviceId"] = "deviceb"
        userData["username"] = userName
        userData["referId"] = referenceId
        if CustomerGlu.fcm_apn == "fcm" {
            userData["firebaseToken"] = fcmRegTokenMessage
        } else {
            userData["apnsDeviceToken"] = apnsDeviceTokenMessage
        }
        CustomerGlu.getInstance.registerDevice(userdata: userData) { success, registrationModel in
            if success {
                CustomerGlu.getInstance.openWallet { _, _ in
                    print("Register Successfully \(String(describing: registrationModel))")
                    self.isActive = true
                }
            } else {
                self.attemptingLogin = false
                print("error")
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
#endif

struct UserImage: View {
    var body: some View {
        return Image("customerglu")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .padding(.bottom, 25)
    }
}

struct LoginButtonContent: View {
    var body: some View {
        return Text("SUBMIT")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.black)
    }
}
