import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(isSignUp ? "Create Account" : "Login")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                if isSignUp {
                    signUp()
                } else {
                    signIn()
                }
            }) {
                Text(isSignUp ? "Sign Up" : "Login")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            Button(action: {
                isSignUp.toggle()
            }) {
                Text(isSignUp ? "Already have an account? Login" : "Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func signIn() {
        FirebaseManager.shared.signIn(email: email, password: password) { result in
            switch result {
            case .success(let user):
                alertMessage = "Successfully logged in as \(user.email ?? "")"
                showAlert = true
            case .failure(let error):
                alertMessage = "Error: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }

    private func signUp() {
        FirebaseManager.shared.signUp(email: email, password: password) { result in
            switch result {
            case .success(let user):
                alertMessage = "Successfully created account for \(user.email ?? "")"
                showAlert = true
            case .failure(let error):
                alertMessage = "Error: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}