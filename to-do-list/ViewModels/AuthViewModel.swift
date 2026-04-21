import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {

    @Published var user: User?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Listen for auth state changes (login / logout)
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    var isSignedIn: Bool {
        user != nil
    }

    // MARK: - Sign Up

    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = Self.friendlyMessage(for: error)
                    return
                }
                self?.user = result?.user
            }
        }
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = Self.friendlyMessage(for: error)
                    return
                }
                self?.user = result?.user
            }
        }
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.errorMessage = Self.friendlyMessage(for: error)
        }
    }

    // MARK: - Friendly Error Messages

    private static func friendlyMessage(for error: Error) -> String {
        let nsError = error as NSError

        // Handle Firebase's "internalError" (17999) — peek into the deserialized
        // response to find the real auth error code like INVALID_LOGIN_CREDENTIALS.
        if nsError.code == AuthErrorCode.Code.internalError.rawValue {
            if let deserialized = nsError.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"]
                as? [String: Any],
               let message = deserialized["message"] as? String {
                return friendlyMessageForBackendCode(message)
            }
            // Fallback text if we couldn't parse the internal error
            return "Invalid email or password. Please check and try again."
        }

        // Map standard Firebase Auth error codes to human-readable messages
        if let code = AuthErrorCode.Code(rawValue: nsError.code) {
            switch code {
            case .invalidEmail:
                return "Please enter a valid email address."
            case .emailAlreadyInUse:
                return "An account already exists with this email. Try signing in instead."
            case .weakPassword:
                return "Password is too weak. Use at least 6 characters."
            case .wrongPassword:
                return "Incorrect password. Please try again."
            case .userNotFound:
                return "No account found with this email. Please sign up first."
            case .invalidCredential:
                return "Invalid email or password. Please check and try again."
            case .userDisabled:
                return "This account has been disabled. Contact support."
            case .networkError:
                return "Network error. Please check your internet connection."
            case .tooManyRequests:
                return "Too many attempts. Please wait a moment and try again."
            case .operationNotAllowed:
                return "Email/password sign-in is not enabled. Contact support."
            case .missingEmail:
                return "Please enter your email address."
            default:
                break
            }
        }

        // Fallback: return the original localized description
        return error.localizedDescription
    }

    /// Map Firebase backend error strings (e.g. "INVALID_LOGIN_CREDENTIALS") to friendly messages
    private static func friendlyMessageForBackendCode(_ message: String) -> String {
        let upper = message.uppercased()
        if upper.contains("INVALID_LOGIN_CREDENTIALS") ||
           upper.contains("INVALID_PASSWORD") {
            return "Incorrect email or password. Please try again."
        }
        if upper.contains("EMAIL_NOT_FOUND") {
            return "No account found with this email. Please sign up first."
        }
        if upper.contains("EMAIL_EXISTS") {
            return "An account already exists with this email. Try signing in instead."
        }
        if upper.contains("WEAK_PASSWORD") {
            return "Password is too weak. Use at least 6 characters."
        }
        if upper.contains("INVALID_EMAIL") {
            return "Please enter a valid email address."
        }
        if upper.contains("USER_DISABLED") {
            return "This account has been disabled. Contact support."
        }
        if upper.contains("TOO_MANY_ATTEMPTS") {
            return "Too many attempts. Please wait a moment and try again."
        }
        // Default: convert e.g. "INVALID_LOGIN_CREDENTIALS" → "Invalid login credentials"
        return message
            .replacingOccurrences(of: "_", with: " ")
            .lowercased()
            .capitalized
    }
}
