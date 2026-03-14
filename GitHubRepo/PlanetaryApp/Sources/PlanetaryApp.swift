// PlanetaryApp.swift
import SwiftUI

@main
struct PlanetaryApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}

// MARK: - Colores y estilos globales

extension Color {
    static let spaceDark   = Color(red: 0.02, green: 0.04, blue: 0.10)
    static let spaceDeep   = Color(red: 0.04, green: 0.08, blue: 0.18)
    static let spaceMid    = Color(red: 0.07, green: 0.13, blue: 0.28)
    static let goldAccent  = Color(red: 1.0,  green: 0.84, blue: 0.0)
    static let silverAccent = Color(red: 0.75, green: 0.85, blue: 0.95)
    static let dimText     = Color(red: 0.55, green: 0.65, blue: 0.80)

    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r,g,b: Double
        (r,g,b) = (Double((int>>16)&0xFF)/255, Double((int>>8)&0xFF)/255, Double(int&0xFF)/255)
        self.init(red:r, green:g, blue:b)
    }
}

extension Planet {
    var swiftUIColor: Color { Color(hex: color) }
}

// MARK: - Shared ViewModel

class AppState: ObservableObject {
    @Published var timezone: Double = Double(TimeZone.current.secondsFromGMT()) / 3600.0
    static let shared = AppState()
}

// MARK: - Root

struct RootTabView: View {
    @StateObject private var appState = AppState.shared

    var body: some View {
        TabView {
            PositionsView()
                .tabItem { Label("Posiciones", systemImage: "globe") }

            DegreesView()
                .tabItem { Label("Recorrido", systemImage: "arrow.forward.circle") }

            AnglesView()
                .tabItem { Label("Ángulos", systemImage: "angle") }

            SearchView()
                .tabItem { Label("Buscar", systemImage: "magnifyingglass") }
        }
        .accentColor(.goldAccent)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Shared Components

struct SpaceBackground: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.spaceDark, .spaceDeep, .spaceMid]),
                       startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundColor(.goldAccent)
            .textCase(.uppercase)
            .kerning(2)
            .padding(.horizontal, 4)
    }
}

struct PlanetBadge: View {
    let planet: Planet
    var size: CGFloat = 32
    var body: some View {
        ZStack {
            Circle().fill(planet.swiftUIColor.opacity(0.2))
                .frame(width: size, height: size)
            Circle().stroke(planet.swiftUIColor.opacity(0.6), lineWidth: 1)
                .frame(width: size, height: size)
            Text(planet.symbol).font(.system(size: size * 0.5))
        }
    }
}

struct InfoRow: View {
    let label: String; let value: String; var highlight: Bool = false
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.dimText)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: highlight ? .bold : .regular, design: .monospaced))
                .foregroundColor(highlight ? .goldAccent : .silverAccent)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct DateTimePicker: View {
    let title: String
    @Binding var date: Date
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.goldAccent)
                .textCase(.uppercase).kerning(1.5)
            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .colorScheme(.dark)
                .accentColor(.goldAccent)
                .labelsHidden()
        }
        .padding(12)
        .background(Color.spaceMid.opacity(0.5))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.goldAccent.opacity(0.2), lineWidth: 1))
    }
}

struct CalcButton: View {
    let title: String; let action: () -> Void; var isLoading: Bool = false
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .spaceDark)).scaleEffect(0.8)
                } else {
                    Image(systemName: "sparkles").font(.system(size: 14))
                }
                Text(isLoading ? "Calculando..." : title)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
            }
            .frame(maxWidth: .infinity).frame(height: 44)
            .background(isLoading ? Color.goldAccent.opacity(0.6) : Color.goldAccent)
            .foregroundColor(.spaceDark)
            .cornerRadius(10)
        }
        .disabled(isLoading)
    }
}
