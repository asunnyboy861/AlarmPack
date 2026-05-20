import SwiftUI

struct ContactSupportView: View {
    @State private var selectedSubject = "General"
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    private let subjects = ["General", "Feature Suggestion", "Bug Report", "Usage Question", "Performance Issue", "UI Improvement", "Other"]
    private let backendURL = "https://feedback-board.iocompile67692.workers.dev"

    var body: some View {
        Form {
            Section {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(subjects, id: \.self) { subject in
                        Button {
                            selectedSubject = subject
                        } label: {
                            Text(subject)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(selectedSubject == subject ? Color.orange : Color(.secondarySystemBackground))
                                .foregroundStyle(selectedSubject == subject ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }

                if selectedSubject == "Other" {
                    TextField("Custom subject", text: $customSubject)
                }
            } header: {
                Text("Subject")
            }

            Section {
                TextField("Your name", text: $name)
                TextField("Email address", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            }

            Section {
                TextEditor(text: $message)
                    .frame(minHeight: 120)
            } header: {
                Text("Message")
            }

            Section {
                Button {
                    Task { await submitFeedback() }
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Submit Feedback")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                }
                .listRowBackground(Color.orange)
                .foregroundStyle(.white)
                .disabled(isSubmitting || name.isEmpty || email.isEmpty || message.isEmpty)
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Contact Support")
        .alert("Thank You!", isPresented: $showSuccess) {
            Button("OK") {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.dismiss(animated: true)
                }
            }
        } message: {
            Text("Your feedback has been submitted successfully.")
        }
    }

    private func submitFeedback() async {
        isSubmitting = true
        errorMessage = nil

        let subjectValue = selectedSubject == "Other" ? customSubject : selectedSubject
        let payload: [String: String] = [
            "name": name,
            "email": email,
            "subject": subjectValue,
            "message": message,
            "app_name": "AlarmPack"
        ]

        do {
            let url = URL(string: "\(backendURL)/api/feedback")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)

            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                showSuccess = true
            } else {
                errorMessage = "Failed to submit. Please try again."
            }
        } catch {
            errorMessage = "Network error. Please check your connection."
        }

        isSubmitting = false
    }
}
