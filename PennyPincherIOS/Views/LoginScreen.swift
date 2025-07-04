import SwiftUI

struct LoginScreen: View {
    var onLoginSuccess: (() -> Void)? = nil
    var onNavigateToSignup: (() -> Void)? = nil
    @ObservedObject var authService: AuthService
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var showResetSheet: Bool = false
    @State private var resetEmail: String = ""
    @State private var resetSuccess: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.accentColor.opacity(0.1), Color(.systemBackground)]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    Image(systemName: "dollarsign.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundColor(.accentColor)
                        .padding(.bottom, 12)
                    Text("Welcome Back!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.accentColor)
                    Text("Sign in to manage your finances with PennyPincher by Neski.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                        .padding(.bottom, 20)
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    Spacer().frame(height: 16)
                    HStack {
                        if showPassword {
                            TextField("Password", text: $password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else {
                            SecureField("Password", text: $password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    Spacer().frame(height: 4)
                    HStack {
                        Spacer()
                        Button(action: {
                            resetEmail = email
                            showResetSheet = true
                        }) {
                            Text("Forgot Password?")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                    }
                    Spacer().frame(height: 8)
                    Button(action: {
                        authService.signIn(email: email, password: password) { success in
                            if success {
                                onLoginSuccess?()
                            }
                        }
                    }) {
                        HStack {
                            if authService.isLoading {
                                ProgressView().scaleEffect(0.8)
                                Text("Logging in...")
                            } else {
                                Image(systemName: "arrow.right.circle")
                                Text("Log In")
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((authService.isLoading || email.isEmpty || password.isEmpty) ? Color.gray : Color.accentColor)
                        .cornerRadius(8)
                    }
                    .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                    Spacer().frame(height: 16)
                    Button(action: { onNavigateToSignup?() }) {
                        HStack(spacing: 0) {
                            Text("Don't have an account? ")
                                .foregroundColor(.secondary)
                            Text("Sign up here")
                                .foregroundColor(.accentColor)
                        }
                    }
                    if let errorMsg = authService.error {
                        Spacer().frame(height: 12)
                        Text(errorMsg)
                            .foregroundColor(.red)
                    }
                }
                .padding(24)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding(.horizontal, 24)
                Spacer()
            }
        }
        .sheet(isPresented: $showResetSheet) {
            VStack(spacing: 20) {
                Text("Reset Password")
                    .font(.headline)
                TextField("Enter your email", text: $resetEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                if resetSuccess {
                    Text("Password reset email sent!")
                        .foregroundColor(.green)
                }
                if let errorMsg = authService.error {
                    Text(errorMsg)
                        .foregroundColor(.red)
                }
                HStack {
                    Button("Cancel") {
                        showResetSheet = false
                        resetSuccess = false
                    }
                    Spacer()
                    Button("Send Reset Email") {
                        authService.sendPasswordReset(email: resetEmail) { success in
                            resetSuccess = success
                        }
                    }
                    .disabled(resetEmail.isEmpty || authService.isLoading)
                }
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    LoginScreen(authService: AuthService())
} 