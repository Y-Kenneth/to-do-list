import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel

    @State private var email            = ""
    @State private var password         = ""
    @State private var isSignUpMode     = false
    @State private var isPasswordVisible = false

    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {

                    // ── Header ──
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appAccent, Color.appAccentSecondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing)
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.appAccent.opacity(0.3),
                                        radius: 12, x: 0, y: 6)
                            Image(systemName: "checklist")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text(isSignUpMode ? "Create Account" : "Welcome Back")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.appTitle)

                        Text(isSignUpMode
                             ? "Sign up to start managing your tasks"
                             : "Sign in to access your tasks")
                            .font(.system(size: 14))
                            .foregroundColor(Color.appSubtitle)
                    }
                    .padding(.top, 60)

                    // ── Form ──
                    VStack(spacing: 16) {

                        // Email
                        fieldSection(label: "Email", icon: "envelope.fill") {
                            TextField("you@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .font(.system(size: 16))
                                .foregroundColor(Color.appTitle)
                                .padding(14)
                                .background(Color.appCardBackground)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.appBorder, lineWidth: 1.5)
                                )
                        }

                        // Password
                        fieldSection(label: "Password", icon: "lock.fill") {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Group {
                                        if isPasswordVisible {
                                            TextField("At least 6 characters", text: $password)
                                                .textInputAutocapitalization(.never)
                                                .autocorrectionDisabled()
                                        } else {
                                            SecureField("At least 6 characters", text: $password)
                                        }
                                    }
                                    .focused($focusedField, equals: .password)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.appTitle)

                                    // Eye toggle button
                                    Button {
                                        isPasswordVisible.toggle()
                                    } label: {
                                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color.appSubtitle)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(14)
                                .background(Color.appCardBackground)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.appBorder, lineWidth: 1.5)
                                )

                                // Password length hint
                                if !password.isEmpty && password.count < 6 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 11))
                                        Text("Password must be at least 6 characters (\(password.count)/6)")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(Color.priorityHigh)
                                }
                            }
                        }

                        // Error message
                        if let error = authViewModel.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 12))
                                Text(error)
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(Color.priorityHigh)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.priorityHigh.opacity(0.1))
                            .cornerRadius(10)
                        }

                        // Submit
                        Button(action: submit) {
                            HStack(spacing: 8) {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: isSignUpMode
                                          ? "person.badge.plus.fill"
                                          : "arrow.right.circle.fill")
                                        .font(.system(size: 18))
                                    Text(isSignUpMode ? "Sign Up" : "Sign In")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.appAccent, Color.appAccentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.appAccent.opacity(0.3),
                                    radius: 10, x: 0, y: 5)
                        }
                        .disabled(!canSubmit || authViewModel.isLoading)
                        .opacity(canSubmit ? 1 : 0.5)
                        .padding(.top, 8)

                        // Toggle mode
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isSignUpMode.toggle()
                                authViewModel.errorMessage = nil
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(isSignUpMode
                                     ? "Already have an account?"
                                     : "Don't have an account?")
                                    .foregroundColor(Color.appSubtitle)
                                Text(isSignUpMode ? "Sign In" : "Sign Up")
                                    .foregroundColor(Color.appAccent)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 14))
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }
        }
        .onTapGesture { focusedField = nil }
    }

    // MARK: - Helpers

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }

    private func submit() {
        focusedField = nil
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if isSignUpMode {
            authViewModel.signUp(email: trimmedEmail, password: password)
        } else {
            authViewModel.signIn(email: trimmedEmail, password: password)
        }
    }

    @ViewBuilder
    private func fieldSection<Content: View>(
        label: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.appSubtitle)
            content()
        }
    }
}
