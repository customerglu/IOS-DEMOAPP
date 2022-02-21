//
//  ButtonsScreen.swift
//  CustomerGluDemo
//
//  Created by kapil on 21/02/22.
//
import SwiftUI
import CustomerGlu

struct NotificationsScreen: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
   var body: some View {
       VStack {
           ZStack {
               Color.black
               HStack {
                   GeometryReader { geometry in
                       Button(action: {
                           CustomerGlu.getInstance.sendEventData(eventName: "completePurchase", eventProperties: ["state": "1"])
                       }) {
                           Text("Push")
                               .frame(
                                minWidth: (geometry.size.width / 2) - 25,
                                maxWidth: .infinity, minHeight: 50
                               )
                               .font(.system(size: 20))
                               .cornerRadius(20)
                           
                       }
                   }
               }
           }
           .frame(height: 50)
           .background(Color.blue)
           .foregroundColor(.white)
           .cornerRadius(20)
           .padding()
           ZStack {
               Color.black
               HStack {
                   GeometryReader { geometry in
                       Button(action: {
                           CustomerGlu.getInstance.sendEventData(eventName: "completePurchase2", eventProperties: ["state": "1"])
                       }) {
                           Text("Full-Screen")
                               .frame(
                                minWidth: (geometry.size.width / 2) - 25,
                                maxWidth: .infinity, minHeight: 50
                               )
                               .font(.system(size: 20))
                               .cornerRadius(20)
                           
                       }
                   }
               }
           }
           .frame(height: 50)
           .background(Color.blue)
           .foregroundColor(.white)
           .cornerRadius(20)
           .padding()
           ZStack {
               Color.black
               HStack {
                   
                   GeometryReader { geometry in
                       Button(action: {
                           CustomerGlu.getInstance.sendEventData(eventName: "completePurchase3", eventProperties: ["state": "1"])
                       }) {
                           Text("Middle-Default")
                               .frame(
                                minWidth: (geometry.size.width / 2) - 25,
                                maxWidth: .infinity, minHeight: 50
                               )
                               .font(.system(size: 20))
                               .cornerRadius(20)
                           
                       }
                   }
               }
           }
           .frame(height: 50)
           .background(Color.blue)
           .foregroundColor(.white)
           .cornerRadius(20)
           .padding()
           ZStack {
               Color.black
               HStack {
                   GeometryReader { geometry in
                       Button(action: {
                           CustomerGlu.getInstance.sendEventData(eventName: "completePurchase4", eventProperties: ["state": "1"])
                       }) {
                           Text("Bottom-Default")
                               .frame(
                                minWidth: (geometry.size.width / 2) - 25,
                                maxWidth: .infinity, minHeight: 50
                               )
                               .font(.system(size: 20))
                               .cornerRadius(20)
                           
                       }
                   }
               }
           }
           .frame(height: 50)
           .background(Color.blue)
           .foregroundColor(.white)
           .cornerRadius(20)
           .padding()
       }.navigationTitle("Notifications")
   }
}
