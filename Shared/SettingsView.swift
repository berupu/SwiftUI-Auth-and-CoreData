//
//  SettingsView.swift
//  SwiftUI Auth & CoreData & CloudKit
//
//  Created by Ashraful Islam Rupu on 2/27/22.
//

import SwiftUI
import CoreData
import FirebaseAuth

struct SettingsView: View {
    @State private var editingNameTextField = false
    @State private var editingTwitterTextField = false
    @State private var editingSiteTextField = false
    @State private var editingBioTextField = false
    
    
    @State private var nameIconBounce = false
    @State private var twitterIconBounce = false
    @State private var siteIconBounce = false
    @State private var bioIconBounce = false
    
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    
    
    @State private var name = ""
    @State private var twitter = ""
    @State private var site = ""
    @State private var bio = ""
    
    @State private var showAlertView: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    private let generator = UISelectionFeedbackGenerator()
    
    // MARK : - CoreData Implementation for this view
    @Environment(\.managedObjectContext) private var viewContext
    
    //fetch user data based on the Auth.auth().currentUser?.uid format predicate
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Account.userID, ascending: true)],predicate: NSPredicate(format: "userID == %@", Auth.auth().currentUser!.uid),animation: .default) private var savedAccounts: FetchedResults<Account>
    @State private var currentAccount: Account?
    
    
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16.0) {
                Text("Settings")
                    .foregroundColor(.white)
                    .font(.largeTitle.bold())
                    .padding(.top)
                
                Text("Manage your profile and account")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.callout)
                
                //choose photo
                
                Button {
                    self.showImagePicker = true
                } label: {
                    HStack(spacing: 12.0){
                        TextFieldIcon(iconName: "person.crop.circle", currentlyEditing: .constant(false), passedIMage: $inputImage)
                        
                        GradientText(text: "Choose photo")
                        Spacer()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .background(Color.init(red: 26/255, green: 20/255, blue: 51/255)
                        .cornerRadius(16)
                    )
                }
                
                //Name Textfield
                GradientTextfield(editingTextfield: $editingNameTextField, textfieldString: $name, iconBounce: $nameIconBounce, textfieldPlaceholder: "Name", textfieldIconString: "textformat.alt")
                    .autocapitalization(.words)
                    .textContentType(.name)
                    .disableAutocorrection(true)
                
                //Twitter Textfield
                GradientTextfield(editingTextfield: $editingTwitterTextField, textfieldString: $twitter, iconBounce: $twitterIconBounce, textfieldPlaceholder: "Twitter Handle", textfieldIconString: "at")
                    .autocapitalization(.none)
                    .keyboardType(.twitter)
                    .disableAutocorrection(true)
                
                //Site Textfield
                GradientTextfield(editingTextfield: $editingSiteTextField, textfieldString: $site, iconBounce: $siteIconBounce, textfieldPlaceholder: "Website", textfieldIconString: "link")
                    .autocapitalization(.words)
                    .keyboardType(.webSearch)
                    .disableAutocorrection(true)
                
                //Bio Textfield
                GradientTextfield(editingTextfield: $editingBioTextField, textfieldString: $bio, iconBounce: $bioIconBounce, textfieldPlaceholder: "Bio", textfieldIconString: "text.justifyleft")
                    .autocapitalization(.sentences)
                    .keyboardType(.default)
                
                
                GradientButton(buttonTitle: "Save Settings") {
                    
                    
                    generator.selectionChanged()
                    
                    // save to coredata
                    currentAccount?.name = self.name
                    currentAccount?.bio = self.bio
                    currentAccount?.twitterhandle = self.twitter
                    currentAccount?.website = self.site
                    currentAccount?.profileImage = self.inputImage?.pngData()
                    
                    do {
                        try viewContext.save()
                        
                        alertTitle = "Settings saved"
                        alertMessage = "Your changes have been saved"
                        showAlertView.toggle()
                    }catch let error {
                        alertTitle = "Uh-oh!"
                        alertMessage = error.localizedDescription
                        showAlertView.toggle()
                    }
                }
                
                Spacer()
                
            }
            .padding()
            
            Spacer()
        }
        .background(Color("settingsBackground"))
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$inputImage)
        }
        .onAppear(){
            currentAccount = savedAccounts.first!
            self.name = currentAccount?.name ?? ""
            self.bio = currentAccount?.bio ?? ""
            self.twitter = currentAccount?.twitterhandle ?? ""
            self.site = currentAccount?.website ?? ""
        }
        .alert(isPresented: $showAlertView, content: {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel())
        })
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
