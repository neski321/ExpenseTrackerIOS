import SwiftUI

struct SignupScreen: View {
    var onSignupSuccess: (() -> Void)? = nil
    var onNavigateToLogin: (() -> Void)? = nil
    @ObservedObject var authService: AuthService
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.92, green: 0.96, blue: 1.0), Color(red: 0.75, green: 0.84, blue: 0.93)]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    Image(systemName: "dollarsign.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color(red: 0.31, green: 0.66, blue: 1.0))
                        .padding(.bottom, 12)
                    Text("Create Your Account")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Join PennyPincher by Neski and start managing your finances today.")
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
                    Spacer().frame(height: 16)
                    HStack {
                        if showPassword {
                            TextField("Confirm Password", text: $confirmPassword)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else {
                            SecureField("Confirm Password", text: $confirmPassword)
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
                    Spacer().frame(height: 20)
                    Button(action: {
                        if password != confirmPassword {
                            // Local validation
                            return
                        }
                        authService.signUp(email: email, password: password) { success in
                            if success {
                                onSignupSuccess?()
                            }
                        }
                    }) {
                        HStack {
                            if authService.isLoading {
                                ProgressView().scaleEffect(0.8)
                                Text("Setting up account...")
                            } else {
                                Image(systemName: "person.badge.plus")
                                Text("Sign Up")
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((authService.isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) ? Color.gray : Color(red: 0.31, green: 0.66, blue: 1.0))
                        .cornerRadius(8)
                    }
                    .disabled(authService.isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                    Spacer().frame(height: 16)
                    Button(action: { onNavigateToLogin?() }) {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.secondary)
                            Text("Log in here")
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
    }
}

#Preview {
    SignupScreen(authService: AuthService())
} 