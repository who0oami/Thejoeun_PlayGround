//
//  AuthView.swift
//  hangangpark
//

import SwiftUI

struct AuthView: View {
    @AppStorage("rememberLoginEmail") private var rememberLoginEmail = false
    @AppStorage("savedLoginEmail") private var savedLoginEmail = ""

    @StateObject private var viewModel = AuthViewModel()
    @State private var loggedInSession: UserSession?
    @State private var isAgePickerPresented = false
    @State private var draftSignupAge = 23

    let onLogin: (UserSession) -> Void

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.97, blue: 0.99)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    authCard
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $loggedInSession) { session in
            ParkingStatusView(session: session) {
                loggedInSession = nil
            }
        }
        .sheet(isPresented: $isAgePickerPresented) {
            AgePickerSheet(
                selectedAge: $viewModel.signupAge,
                draftAge: $draftSignupAge,
                ages: viewModel.ageRange
            )
            .presentationDetents([.height(320)])
        }
        .onAppear {
            resetLoginFieldsForCurrentPreference()
        }
        .onChange(of: rememberLoginEmail) { _, shouldRemember in
            if shouldRemember {
                saveCurrentLoginEmail()
            } else {
                savedLoginEmail = ""
                viewModel.loginEmail = ""
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 10) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("HanFlow")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.mode == .login ? "한강공원 주차 확인" : "이메일로 시작하기")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                Text(viewModel.mode == .login ? "로그인하고 주차장 잔여 대수를 확인하세요." : "이메일 인증 후 주차 예측 서비스를 이용할 수 있어요.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(.white)
                    .frame(width: 8, height: 8)
                Text(viewModel.mode == .login ? "사용자 계정으로 로그인하세요." : "인증 코드는 이메일로 전송됩니다.")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.92))
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.13))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.11, green: 0.34, blue: 0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var authCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.mode == .login ? "로그인" : "회원가입")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))

                Text(viewModel.mode == .login ? "이메일과 비밀번호를 입력해주세요." : "이메일 인증 후 계정을 만들 수 있어요.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            modeButtons

            if viewModel.mode == .login {
                loginFields
            } else {
                signupFields
            }

            if !viewModel.message.isEmpty {
                Text(viewModel.message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.94, green: 0.96, blue: 0.99))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
        .disabled(viewModel.isLoading)
    }

    private var modeButtons: some View {
        HStack(spacing: 10) {
            modeButton(title: "로그인", mode: .login)
            modeButton(title: "회원가입", mode: .signup)
        }
    }

    private func modeButton(title: String, mode: AuthViewModel.Mode) -> some View {
        Button {
            viewModel.mode = mode
            viewModel.message = ""
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundStyle(viewModel.mode == mode ? .white : Color(red: 0.16, green: 0.31, blue: 0.62))
                .background(viewModel.mode == mode ? Color(red: 0.16, green: 0.38, blue: 0.83) : Color(red: 0.93, green: 0.95, blue: 0.99))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private var loginFields: some View {
        VStack(spacing: 16) {
            AuthTextField(
                title: "이메일",
                placeholder: "name@example.com",
                systemImage: "envelope.fill",
                text: $viewModel.loginEmail,
                keyboardType: .emailAddress
            )

            AuthSecureField(
                title: "비밀번호",
                placeholder: "비밀번호를 입력하세요",
                text: $viewModel.loginPassword
            )

            rememberEmailToggle

            Button {
                Task {
                    if let session = await viewModel.login() {
                        saveCurrentLoginEmail()
                        viewModel.loginPassword = ""
                        loggedInSession = session
                        onLogin(session)
                    }
                }
            } label: {
                Text(viewModel.isLoading ? "확인 중..." : "로그인")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(PrimaryAuthButtonStyle())
            .disabled(!viewModel.canLogin)

            Button("계정이 없으신가요? 회원가입") {
                viewModel.mode = .signup
                viewModel.message = ""
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color(red: 0.16, green: 0.38, blue: 0.83))
            .frame(maxWidth: .infinity)
        }
    }

    private var rememberEmailToggle: some View {
        Button {
            rememberLoginEmail.toggle()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: rememberLoginEmail ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(rememberLoginEmail ? Color(red: 0.16, green: 0.38, blue: 0.83) : Color(red: 0.42, green: 0.51, blue: 0.66))

                Text("이메일 기억하기")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.20, green: 0.24, blue: 0.31))

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    private func resetLoginFieldsForCurrentPreference() {
        viewModel.loginPassword = ""
        viewModel.loginEmail = rememberLoginEmail ? savedLoginEmail : ""
    }

    private func saveCurrentLoginEmail() {
        if rememberLoginEmail {
            savedLoginEmail = viewModel.loginEmail.trimmed.lowercased()
        } else {
            savedLoginEmail = ""
        }
    }

    private var signupFields: some View {
        VStack(spacing: 16) {
            AuthTextField(
                title: "이메일",
                placeholder: "name@example.com",
                systemImage: "envelope.fill",
                text: $viewModel.signupEmail,
                keyboardType: .emailAddress
            )

            AuthSecureField(
                title: "비밀번호",
                placeholder: "비밀번호를 입력하세요",
                text: $viewModel.signupPassword
            )

            HStack(alignment: .top, spacing: 12) {
                AgeSelectionField(
                    title: "나이",
                    value: viewModel.signupAgeText
                ) {
                    draftSignupAge = viewModel.signupAge ?? 23
                    isAgePickerPresented = true
                }

                GenderSelectionField(selection: $viewModel.signupGender)
            }

            HStack(spacing: 12) {
                AuthTextField(
                    title: "인증 코드",
                    placeholder: "6자리 코드",
                    systemImage: "number",
                    text: $viewModel.verificationCode,
                    keyboardType: .numberPad
                )

                Button("코드 받기") {
                    Task { await viewModel.sendSignupCode() }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 94, height: 54)
                .background(viewModel.canSendCode ? Color(red: 0.06, green: 0.52, blue: 0.48) : Color.gray.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .disabled(!viewModel.canSendCode)
            }

            Button {
                Task { await viewModel.signup() }
            } label: {
                Text(viewModel.isLoading ? "가입 중..." : "회원가입")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(PrimaryAuthButtonStyle())
            .disabled(!viewModel.canSignup)

            Button("이미 계정이 있으신가요? 로그인") {
                viewModel.mode = .login
                viewModel.message = ""
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color(red: 0.16, green: 0.38, blue: 0.83))
            .frame(maxWidth: .infinity)
        }
    }
}

private struct AgePickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedAge: Int?
    @Binding var draftAge: Int
    let ages: [Int]

    var body: some View {
        VStack(spacing: 16) {
            Text("나이 선택")
                .font(.headline)
                .padding(.top, 16)

            Picker("나이", selection: $draftAge) {
                ForEach(ages, id: \.self) { age in
                    Text("\(age)살").tag(age)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 160)

            Button {
                selectedAge = draftAge
                dismiss()
            } label: {
                Text("선택 완료")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(PrimaryAuthButtonStyle())
            .padding(.horizontal, 20)
        }
        .presentationDragIndicator(.visible)
    }
}

private struct AgeSelectionField: View {
    let title: String
    let value: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.34, green: 0.39, blue: 0.48))

            Button(action: action) {
                HStack(spacing: 10) {
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color(red: 0.42, green: 0.51, blue: 0.66))
                        .frame(width: 18)

                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14)
                .frame(height: 52)
                .background(Color(red: 0.97, green: 0.98, blue: 1.0))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct GenderSelectionField: View {
    @Binding var selection: AuthViewModel.Gender?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("성별")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.34, green: 0.39, blue: 0.48))

            HStack(spacing: 8) {
                genderButton(.male)
                genderButton(.female)
            }
            .frame(height: 52)
        }
    }

    private func genderButton(_ gender: AuthViewModel.Gender) -> some View {
        Button {
            selection = gender
        } label: {
            Text(gender.rawValue)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundStyle(selection == gender ? .white : Color(red: 0.16, green: 0.31, blue: 0.62))
                .background(selection == gender ? Color(red: 0.16, green: 0.38, blue: 0.83) : Color(red: 0.97, green: 0.98, blue: 1.0))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

private struct AuthTextField: View {
    let title: String
    let placeholder: String
    let systemImage: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.34, green: 0.39, blue: 0.48))

            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(Color(red: 0.42, green: 0.51, blue: 0.66))
                    .frame(width: 18)

                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color(red: 0.97, green: 0.98, blue: 1.0))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

private struct AuthSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.34, green: 0.39, blue: 0.48))

            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(Color(red: 0.42, green: 0.51, blue: 0.66))
                    .frame(width: 18)

                SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color(red: 0.97, green: 0.98, blue: 1.0))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

private struct PrimaryAuthButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(configuration.isPressed ? Color(red: 0.10, green: 0.28, blue: 0.66) : Color(red: 0.16, green: 0.38, blue: 0.83))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.88 : 1)
    }
}

#Preview {
    NavigationStack {
        AuthView { _ in }
    }
}
