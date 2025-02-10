import FirebaseAuth
import GoogleSignIn
import UIKit
import FacebookLogin
import AuthenticationServices
import CryptoKit

final class LoginPresenter: ObservableObject {
    private let wireframe: LoginWireframeInterface
    private var currentNonce: String?

    init(wireframe: LoginWireframeInterface) {
        self.wireframe = wireframe
    }

    // MARK: - Google Login
    func handleGoogleLogin() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Google Sign-In failed: \(error.localizedDescription)")
                return
            }

            guard let authentication = result?.user.idToken else {
                print("Failed to get Google ID Token")
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: authentication.tokenString,
                accessToken: result!.user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-In with Google failed: \(error.localizedDescription)")
                } else {
                    print("User signed in with Google: \(authResult?.user.email ?? "No email")")
                    self.handleSuccessfulLogin()
                }
            }
        }
    }

    // MARK: - GitHub Login
    func handleGitHubLogin() {
        let provider = OAuthProvider(providerID: "github.com")
        
        provider.scopes = ["user:email"]
        provider.customParameters = [
            "allow_signup": "false"
        ]

        provider.getCredentialWith(nil) { [weak self] credential, error in
            if let error = error {
                print("GitHub login failed: \(error.localizedDescription)")
                return
            }

            guard let credential = credential else {
                print("Failed to get GitHub credential")
                return
            }

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase GitHub login failed: \(error.localizedDescription)")
                } else {
                    print("User signed in with GitHub: \(authResult?.user.email ?? "No email")")
                    self?.handleSuccessfulLogin()
                }
            }
        }
    }

    // MARK: - Facebook Login
    func handleFacebookLogin() {
        let loginManager = LoginManager()
        
        
        loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { [weak self] result, error in
            if let error = error {
                print("Facebook login failed: \(error.localizedDescription)")
                return
            }

            guard let result = result, !result.isCancelled else {
                print("Facebook login was cancelled.")
                return
            }

            guard let accessToken = AccessToken.current else {
                print("Failed to get Facebook access token.")
                return
            }

            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-In with Facebook failed: \(error.localizedDescription)")
                } else {
                    print("User signed in with Facebook: \(authResult?.user.email ?? "No email")")
                    self?.handleSuccessfulLogin()
                }
            }
        }
    }

    // MARK: - Nonce Function
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce.")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Apple Login Request
    func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        request.requestedScopes = [.fullName, .email]
    }

    // MARK: - Apple Login Finalization
    func handleAppleLogin(authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = appleIDCredential.user
            print("Apple Sign-In User ID: \(userID)")

            guard let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8),
                  let nonce = currentNonce else {
                print("Failed to get Apple ID token or nonce.")
                return
            }

            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: tokenString,
                rawNonce: nonce
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-In with Apple failed: \(error.localizedDescription)")
                } else {
                    print("User signed in with Apple: \(authResult?.user.email ?? "No email")")
                    self.handleSuccessfulLogin()
                }
            }
        } else {
            print("Apple Sign-In failed: No credential found.")
        }
    }

    // MARK: - Successful Login
    func handleSuccessfulLogin() {
        print("Login was successful!")
        wireframe.navigateToHome()
    }
}
