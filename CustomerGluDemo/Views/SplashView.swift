//
//  SplashView.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 19/05/23.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @Binding var isUserRegistered:Bool
    var body: some View {
        
        if isActive
        {
            if isUserRegistered
            {
                HomeScreen()
            }else{
                LoginScreen()
            }
        }else{
            // Customize your splash screen UI here
            Image("customerglu")
                .foregroundColor(.white)
                .padding()
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    // Hide the splash screen after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(isUserRegistered: .constant(true))
    }
}
