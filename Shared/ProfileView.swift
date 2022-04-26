//
//  ProfileView.swift
//  SwiftUI Auth & CoreData & CloudKit
//
//  Created by Ashraful Islam Rupu on 2/27/22.
//

import SwiftUI
import FirebaseAuth
import CoreData

struct ProfileView: View {
    
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showAlertView: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showSettingsView: Bool = false
    
    // MARK : - CoreData Implementation for this view
    @Environment(\.managedObjectContext) private var viewContext
    
    //fetch user data based on the Auth.auth().currentUser?.uid format predicate
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Account.userID, ascending: true)],predicate: NSPredicate(format: "userID == %@", Auth.auth().currentUser!.uid),animation: .default) private var savedAccounts: FetchedResults<Account>
    @State private var currentAccount: Account?
    
    
    @State private var updater: Bool = true
    
    
    var body: some View {
        ZStack {
            Image("background-2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16){
                        if currentAccount?.profileImage != nil {
                            GradientProfilePictureView(profilePicture: UIImage(data: currentAccount!.profileImage!)!)
                                .frame(width: 66, height: 66)
                        } else {
                            ZStack {
                                Circle()
                                    .foregroundColor(Color("pink-gradient-1"))
                                    .frame(width: 66, height: 66, alignment: .center)

                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .medium, design: .rounded))
                            }
                            .frame(width: 66, height: 66, alignment: .center)
                        }

                        
                        VStack(alignment: .leading) {
                            Text(currentAccount?.name ?? "No name")
                                .foregroundColor(.white)
                                .font(.title2)
                                .bold()
                            Text("View profile")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.footnote)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showSettingsView.toggle()
                        }, label: {
                            TextFieldIcon(iconName: "gearshape.fill", currentlyEditing: .constant(true), passedIMage: .constant(nil))
                        })
                    }
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.white.opacity(0.1))
                    
                    Text(currentAccount?.bio ?? "No bio")
                        .foregroundColor(.white)
                        .font(.title2.bold())
                    
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 16) {
                        if currentAccount?.twitterhandle != nil {
                            Image("Twitter")
                                .resizable()
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 24, height: 24, alignment: .center)
                        }
                        
                        if currentAccount?.website != nil {
                            Image(systemName: "link")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                            
                            Text(currentAccount?.website ?? "Nowebsite")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.footnote)
                        }
                        
                    }
                    
                }
                .padding(16)
                
                GradientButton(buttonTitle: "Go to youtube channel") {
                    alertTitle = "youtube.com/berupu"
                    alertMessage = "Subscribed"
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel())
                }
                .padding(.horizontal, 16)
                
                Button(action: {
                    print("restore")
                }, label: {
                    
                    if currentAccount != nil {
                        GradientText(text: currentAccount!.proMember ? "Subscribed" : "Unsubscribe")
                            .font(.footnote.bold())
                    }
                    
                })
                    .padding(.bottom)
            }
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.2))
                    .background(
                        Color("secondaryBackground").opacity(0.5)
                    )
                    .shadow(color: Color("shadowColor").opacity(0.5), radius: 60, x: 0, y: 30)
            )
            .cornerRadius(30)
            .padding(.horizontal)
            
            VStack{
                Spacer()
                Button(action: {
                    signout()
                }, label: {
                    Image(systemName: "arrow.turn.up.forward.iphone.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .rotation3DEffect(Angle(degrees: 180), axis: (x: 0.0, y: 0.0, z: 1.0)
                        )
                        .background(
                        Circle()
                            .stroke(Color.white.opacity(0.2),lineWidth: 1)
                            .frame(width: 42, height: 42, alignment: .center)
                            .overlay(
                                Color.black
                                    .cornerRadius(21)
//                                    .frame(width: 42, height: 100, alignment: .center)
                            )
                        )
                    
                })
            }
            .padding(.bottom, 64)
        }
        .colorScheme(updater ? .dark : .dark)
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
                .environment(\.managedObjectContext, self.viewContext)
                .onDisappear(){
                    currentAccount = savedAccounts.first!
                    updater.toggle()
                }
        }
        .onAppear(){
            currentAccount = savedAccounts.first
            
            if currentAccount == nil {
                let userDatatoSave = Account(context: viewContext)
                userDatatoSave.name = Auth.auth().currentUser!.displayName
                userDatatoSave.bio = nil
                userDatatoSave.userID = Auth.auth().currentUser!.uid
                userDatatoSave.proMember = false
                userDatatoSave.twitterhandle = nil
                userDatatoSave.website = nil
                userDatatoSave.profileImage = nil
                
                do {
                    try viewContext.save()
                    
                }catch let error {
                    alertTitle = "Could not create an account"
                    alertMessage = error.localizedDescription
                    showAlertView.toggle()
                }
            }
            
            
        }
    }
    
    func signout() {
        do {
            try Auth.auth().signOut()
            presentationMode.wrappedValue.dismiss()
        }catch let error {
            print(error.localizedDescription)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

