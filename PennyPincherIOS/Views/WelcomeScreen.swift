import SwiftUI

struct WelcomeScreen: View {
    var onGetStarted: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "dollarsign.circle.fill")
                .resizable()
                .frame(width: 72, height: 72)
                .foregroundColor(.accentColor)
                .accessibilityLabel("Coins Icon")
            Spacer().frame(height: 24)
            Text("PennyPincher by neski")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            Spacer().frame(height: 12)
            Text("Take control of your finances with ease.\nTrack spending, set budgets, and achieve your financial goals.")
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            Spacer().frame(height: 32)
            Button(action: { onGetStarted?() }) {
                Text("Get Started")
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WelcomeScreen()
} 