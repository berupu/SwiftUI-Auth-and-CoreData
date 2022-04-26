//
//  SignUpView.swift
//  SwiftUI Auth & CoreData & CloudKit
//
//  Created by Ashraful Islam Rupu on 2/27/22.
//

import SwiftUI
import AudioToolbox //for haptic
import FirebaseAuth
import CoreData

let gradiant = LinearGradient(gradient: Gradient(colors: [ Color.green, Color.cyan]), startPoint: .top, endPoint: .bottom)

struct SignUpView: View {
    
    
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var editingEmailTextField: Bool = false
    @State private var editingPasswordTextField: Bool = false
    @State private var emailIconBounce: Bool = false
    @State private var passwordIconBounce: Bool = false
    @State private var showProfileView: Bool = false
    @State private var signUpToggle: Bool = true
    @State var rotationAngle = 0.0
    @State var signInWithAppleObject = SignInWithAppleObject()
    @State var fadeToggle: Bool = true
    
    @State private var showAlertView: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    // MARK : - Haptic Feedback
    private let generator = UISelectionFeedbackGenerator()
    
    // MARK : - CoreData Implementation
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Account.userID, ascending: true)], animation: .default) private var savedAccounts: FetchedResults<Account>
    
    
    var body: some View {
        
        ZStack {
            gradiant
                .edgesIgnoringSafeArea(.all)
                .opacity(fadeToggle ? 1.0 : 0.0)
            
            Color("secondaryBackground")
                .edgesIgnoringSafeArea(.all)
                .opacity(fadeToggle ? 0.0 : 1.0)
            
            VStack {
                VStack(alignment: .leading, spacing: 16.0) {
                    Text(signUpToggle ?  "Sign up": "Sign in")
                        .font(Font.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("Access to 120+ hours of courses,tutorial and livestream")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.7))
                    
                    HStack(spacing: 12.0) {
                        TextFieldIcon(iconName: "envelope.open.fill", currentlyEditing: $editingEmailTextField, passedIMage: .constant(nil))
                            .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                        TextField("Email", text: $email) { isEditing in
                            editingEmailTextField = isEditing
                            editingPasswordTextField = false
                            
                            // MARK : - Heptic Feedback
                            generator.selectionChanged()
                            
                            if isEditing {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.5)) {
                                    emailIconBounce.toggle()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.5)) {
                                        emailIconBounce.toggle()
                                    }
                                }
                            }
                        }
                        .colorScheme(.dark)
                        .foregroundColor(Color.white.opacity(0.7))
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                    }
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white,lineWidth: 1.0)
                            .blendMode(.overlay)
                    )
                    .background(
                        Color.secondary
                            .cornerRadius(16)
                            .opacity(0.8)
                    )
                    
                    
                    HStack(spacing: 12.0) {
                        TextFieldIcon(iconName: "key.fill", currentlyEditing: $editingPasswordTextField, passedIMage: .constant(nil))
                            .scaleEffect(passwordIconBounce ? 1.2 : 1.0)
                        SecureField("Password", text: $password)
                            .colorScheme(.dark)
                            .foregroundColor(Color.white.opacity(0.7))
                            .autocapitalization(.none)
                            .textContentType(.password)
                    }
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white,lineWidth: 1.0)
                            .blendMode(.overlay)
                    )
                    .background(
                        Color.secondary
                            .cornerRadius(16)
                            .opacity(0.8)
                    )
                    .onTapGesture{
                        editingPasswordTextField = true
                        editingEmailTextField = false
                        
                        // MARK : - Haptic feedback
                        generator.selectionChanged()
                        
                        if editingPasswordTextField {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.5)) {
                                passwordIconBounce.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.5)) {
                                    passwordIconBounce.toggle()
                                }
                            }
                        }
                        
                    }
                    
                    GradientButton(buttonTitle:signUpToggle ? "Create Account" : "Sign in") {
                        generator.selectionChanged()
                        signUp()
                    }
                    .onAppear {
                         // MARK : - If a user exist in firbase
                        Auth.auth().addStateDidChangeListener { auth, user in
                            if let currentUser = user {
                                if savedAccounts.count == 0{
                                    //Add data to Core data. In order to view this into another view we need to pass viewContext to that view
                                    let userDatatoSave = Account(context: viewContext)
                                    userDatatoSave.name = currentUser.displayName
                                    userDatatoSave.bio = nil
                                    userDatatoSave.userID = currentUser.uid
                                    userDatatoSave.proMember = false
                                    userDatatoSave.twitterhandle = nil
                                    userDatatoSave.website = nil
                                    userDatatoSave.profileImage = nil
                                    
                                    do {
                                        try viewContext.save()
                                        DispatchQueue.main.async{
                                            showProfileView.toggle()
                                        }
                                    }catch let error {
                                        alertTitle = "Could not create an account"
                                        alertMessage = error.localizedDescription
                                        showAlertView.toggle()
                                    }
                                } else {
                                    showProfileView.toggle()
                                }
                            }
                        }
                    }
                    
                    if signUpToggle {
                        Text("By clicking on Sign up,you agree to our Terms of service and Privacy policy")
                        .font(.footnote)
                        .foregroundColor(Color.white.opacity(0.6))
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.white.opacity(0.1))
                        
                    }
                    
                    VStack(alignment: .leading, spacing: 16.0) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                self.fadeToggle.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    withAnimation(.easeInOut(duration: 0.35)){
                                        self.fadeToggle.toggle()
                                    }
                                }
                            }
                            
                            withAnimation(.easeInOut(duration: 0.7)){
                            signUpToggle.toggle()
                                self.rotationAngle += 180
                            }
                        }, label: {
                            HStack {
                                Text(signUpToggle ? "Already have an account": "Dont't have an account?")
                                    .font(.footnote)
                                    .foregroundColor(Color.white.opacity(0.7))
                                GradientText(text: signUpToggle ? "Sign in" : "Sign up")
                                    .font(Font.footnote.bold())
                            }
                        }
                        )
                        if !signUpToggle {
                            Button(action: {
                                sendPasswordResetEmail()
                            }) {
                                HStack {
                                    Text("Forgot password")
                                        .font(.footnote)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    GradientText(text: "Reset password")
                                        .font(.footnote.bold())
                                        
                                }
                            }
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.white.opacity(0.1))
                            
                            Button(action: {
                                signInWithAppleObject.signInWithApple()
                            }) {
                                SignInWithAppleButton()
                                    .frame(height: 50)
                                    .cornerRadius(16)
                            }
                            
                        }
                    }
                    
                    
                }
                .padding(20)
            }
            .rotation3DEffect(
                Angle(degrees: self.rotationAngle), axis: (x: 0, y: 1, z: 0)
            )
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.2))
                    .background(Color.purple.opacity(0.5))
                    .background(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.5), radius: 60, x: 0, y: 30)
            )
            .cornerRadius(30)
            .padding(.horizontal)
            .rotation3DEffect(
                Angle(degrees: self.rotationAngle), axis: (x: 0, y: 1, z: 0)
            )
            .alert(isPresented: $showAlertView) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel() )
            }
            
        }
        .fullScreenCover(isPresented: $showProfileView) {
            ProfileView()
                .environment(\.managedObjectContext, self.viewContext)
        }
    }
    
    func signUp() {
        if signUpToggle {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error == nil {
                guard error != nil else {return}
                self.alertTitle = "Uh-oh"
                self.alertMessage = (error!.localizedDescription)
                self.showAlertView.toggle()
            }
        }
            
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                guard error == nil else {
                    self.alertTitle = "Uh-oh"
                    self.alertMessage = (error!.localizedDescription)
                    self.showAlertView.toggle()
                    return
                }
            }
        }
    }
    
    func sendPasswordResetEmail() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            guard error == nil else {
                self.alertTitle = "Uh-oh"
                self.alertMessage = (error!.localizedDescription)
                self.showAlertView.toggle()
                return
            }
            alertTitle = "Password reset email sent"
            alertMessage = "Check your inbox for an email to reset your password"
            showAlertView.toggle()
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}


