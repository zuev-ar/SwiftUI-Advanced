//
//  ContentView.swift
//  SwiftUI-Advanced
//
//  Created by Arkasha Zuev on 18.01.2022.
//

import SwiftUI
import AudioToolbox
import FirebaseAuth

struct SignupView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var editingEmailTextField: Bool = false
    @State private var editingPasswordTextField: Bool = false
    @State private var emailIconBounce: Bool = false
    @State private var passwordIconBounce: Bool = false
    @State private var showProfileView: Bool = false
    @State private var signupToggle: Bool = true
    @State private var rotationAngle: Double = 0.0
    @State private var signInWithAppleObject = SignInWithAppleObject()
    @State private var fadeToggle: Bool = true
    
    @State private var showAlertView: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Account.userSince, ascending: true)], animation: .default) private var savedAccounts: FetchedResults<Account>
    
    private let generator = UISelectionFeedbackGenerator()
    
    var body: some View {
        ZStack {
            Image(signupToggle ? "background-3" : "background-1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .opacity(fadeToggle ? 1.0 : 0.0)
            
            Color("secondaryBackground")
                .edgesIgnoringSafeArea(.all)
                .opacity(fadeToggle ? 0.0 : 1.0)
            
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text(signupToggle ? "Sign up" : "Sign in")
                        .font(Font.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("Access to 120+ hours of courses, tutorials, and livestreams")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.7))
                    
                    HStack(spacing: 12) {
                        TextFieldIcon(iconName: "envelope.open.fill", currentlyEditing: $editingEmailTextField, passedImage: .constant(nil))
                            .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                        TextField("Email", text: $email) { isEditing in
                            editingEmailTextField = isEditing
                            editingPasswordTextField = false
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
                            .stroke(Color.white, lineWidth: 1)
                            .blendMode(.overlay)
                    )
                    .background(
                        Color("secondaryBackground")
                            .cornerRadius(16)
                            .opacity(0.8)
                    )
                    
                    HStack(spacing: 12) {
                        TextFieldIcon(iconName: "key.fill", currentlyEditing: $editingPasswordTextField, passedImage: .constant(nil))
                            .scaleEffect(passwordIconBounce ? 1.2 : 1.0)
                        TextField("Password", text: $password)
                            .colorScheme(.dark)
                            .foregroundColor(Color.white.opacity(0.7))
                            .autocapitalization(.none)
                            .textContentType(.password)
                    }
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white, lineWidth: 1)
                            .blendMode(.overlay)
                    )
                    .background(
                        Color("secondaryBackground")
                            .cornerRadius(16)
                            .opacity(0.8)
                    )
                    .onTapGesture {
                        editingPasswordTextField = true
                        editingEmailTextField = false
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
                    
                    GradientButton(buttonTitle: signupToggle ? "Create account" : "Sign in") {
                        generator.selectionChanged()
                        signup()
                    }
                    .onAppear {
                        Auth.auth().addStateDidChangeListener { auth, user in
                            if let currentUser = user {
                                if savedAccounts.count == 0 {
                                    // add data to Core Data
                                    let userDataToSave = Account(context: viewContext)
                                    userDataToSave.name = currentUser.displayName
                                    userDataToSave.bio = nil
                                    userDataToSave.userID = currentUser.uid
                                    userDataToSave.numberOfCertificates = 0
                                    userDataToSave.proMember = false
                                    userDataToSave.twitterHandle = nil
                                    userDataToSave.website = nil
                                    userDataToSave.profileImage = nil
                                    userDataToSave.userSince = Date()
                                    do {
                                        try viewContext.save()
                                        DispatchQueue.main.async {
                                            showProfileView.toggle()
                                        }
                                    } catch let error {
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
                    
                    if signupToggle {
                        Text("By clicking on Sign up, you agree to our Terms of service and Privacy policy")
                            .font(.footnote)
                            .foregroundColor(Color.white.opacity(0.7))
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.white.opacity(0.1))
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Button {
                            withAnimation(.easeIn(duration: 0.35)) {
                                fadeToggle.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        self.fadeToggle.toggle()
                                    }
                                }
                            }
                            
                            withAnimation(.easeIn(duration: 0.7)) {
                                signupToggle.toggle()
                                self.rotationAngle += 180.0
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(signupToggle ? "Alredy have an account?" : "Don't have an account?")
                                    .font(.footnote)
                                    .foregroundColor(Color.white.opacity(0.7))
                                
                                GradientText(text: signupToggle ? "Sign in" : "Sign up")
                                    .font(Font.footnote.bold())
                            }
                        }
                        
                        if !signupToggle {
                            Button {
                                sendPasswordResetEmail()
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Forgot password?")
                                        .font(.footnote)
                                        .foregroundColor(
                                            .white.opacity(0.7)
                                        )
                                    GradientText(text: "Reset password")
                                        .font(.footnote.bold())
                                }
                            }
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.white.opacity(0.1))
                            
                            Button {
                                signInWithAppleObject.signInWithApple()
                            } label: {
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
                Angle(degrees: self.rotationAngle), axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.2))
                    .background(Color("secondaryBackground").opacity(0.5))
                    .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark))
                    .shadow(color: Color("shadowColor").opacity(0.5), radius: 10, x: 0, y: 30)
            )
            .cornerRadius(30)
            .padding(.horizontal)
            .rotation3DEffect(
                Angle(degrees: self.rotationAngle), axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .alert(isPresented: $showAlertView) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel())
            }
        }
        .fullScreenCover(isPresented: $showProfileView) {
            ProfileView()
                .environment(\.managedObjectContext, self.viewContext)
        }
    }
    
    func signup() {
        if signupToggle {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                guard error == nil else {
                    self.alertTitle = "Uh-oh"
                    self.alertMessage = error!.localizedDescription
                    self.showAlertView.toggle()
                    return
                }
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                guard error == nil else {
                    self.alertTitle = "Uh-oh"
                    self.alertMessage = error!.localizedDescription
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
                self.alertMessage = error!.localizedDescription
                self.showAlertView.toggle()
                return
            }
            
            self.alertTitle = "Password reset email sent"
            self.alertMessage = "Check your indox for an email to reset your password"
            self.showAlertView.toggle()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
