import SwiftUI

struct SettingsScreen: View {
    @Binding var colorScheme: String
    @ObservedObject var authService: AuthService

    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Picker("App Theme", selection: $colorScheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section {
                Button(role: .destructive) {
                    authService.signOut()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Log Out")
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsScreen(colorScheme: .constant("system"), authService: AuthService())
} 