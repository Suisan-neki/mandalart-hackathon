import SwiftUI

struct SplashView: View {
    @State private var glowScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var ring1Rotation: Double = 0
    @State private var ring2Rotation: Double = 0
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.9

    var body: some View {
        ZStack {
            Color.stone50.ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(Color.amber400.opacity(0.4))
                .frame(width: 380, height: 380)
                .blur(radius: 100)
                .scaleEffect(glowScale)
                .opacity(glowOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        glowScale   = 1.2
                        glowOpacity = 0.5
                    }
                }

            VStack(spacing: 20) {
                // Logo mark
                ZStack {
                    // Outer rotating ring
                    Circle()
                        .stroke(Color.amber400.opacity(0.2), lineWidth: 1)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(ring1Rotation))

                    // Inner rotating ring (reverse)
                    Circle()
                        .stroke(Color.amber400.opacity(0.12), lineWidth: 1)
                        .frame(width: 148, height: 148)
                        .rotationEffect(.degrees(ring2Rotation))

                    // Icon tile
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "fef3c7"), Color(hex: "fcd34d")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.amber500.opacity(0.3), radius: 20, x: 0, y: 8)
                        .rotationEffect(.degrees(12))
                        .overlay(
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(Color(hex: "92400e"))
                                .rotationEffect(.degrees(-12))
                        )
                }
                .onAppear {
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                        ring1Rotation = 360
                    }
                    withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                        ring2Rotation = -360
                    }
                }

                // Title
                VStack(spacing: 6) {
                    HStack(spacing: 2) {
                        Text("Mandalart")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.stone800)
                        Text(" Sync")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(Color.amber600)
                    }
                    Text("目標と行動をつなぐ。")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.stone500)
                        .tracking(1)
                }
            }
            .opacity(logoOpacity)
            .scaleEffect(logoScale)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    logoOpacity = 1
                    logoScale   = 1
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
