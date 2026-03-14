// AnglesView.swift — Tab 3: Ángulos entre planetas (todas las combinaciones)
import SwiftUI

class AnglesViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var angles: [AnglePair] = []
    @Published var positions: [PlanetPosition] = []
    @Published var isLoading = false
    @Published var filterAspects = false
    @Published var sortByAngle = false

    func calculate() {
        isLoading = true
        let d = selectedDate
        DispatchQueue.global(qos: .userInitiated).async {
            let pos = calcPlanets(jd: jdFromDate(d))
            let ang = calcAngles(positions: pos)
            DispatchQueue.main.async {
                self.positions = pos
                self.angles = ang
                self.isLoading = false
            }
        }
    }

    var displayedAngles: [AnglePair] {
        var list = angles
        if filterAspects { list = list.filter { !$0.aspect.isEmpty } }
        if sortByAngle   { list = list.sorted { $0.angle < $1.angle } }
        return list
    }
}

struct AnglesView: View {
    @StateObject private var vm = AnglesViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                SpaceBackground()
                ScrollView {
                    VStack(spacing: 16) {

                        // — Controles —
                        VStack(spacing: 10) {
                            DateTimePicker(title: "Fecha y Hora", date: $vm.selectedDate)

                            HStack(spacing: 12) {
                                Toggle(isOn: $vm.filterAspects) {
                                    Text("Solo aspectos")
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.dimText)
                                }
                                .toggleStyle(.switch).tint(.goldAccent)
                                Toggle(isOn: $vm.sortByAngle) {
                                    Text("Ordenar por ángulo")
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.dimText)
                                }
                                .toggleStyle(.switch).tint(.goldAccent)
                            }
                            .padding(10)
                            .background(Color.spaceMid.opacity(0.4))
                            .cornerRadius(8)

                            CalcButton(title: "Calcular Ángulos", action: vm.calculate, isLoading: vm.isLoading)
                        }
                        .padding(.horizontal)

                        // — Posiciones resumen —
                        if !vm.positions.isEmpty {
                            VStack(spacing: 6) {
                                SectionHeader(title: "Posiciones del \(dateFormatter.string(from: vm.selectedDate))")
                                    .padding(.horizontal)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(vm.positions) { pos in
                                            MiniPlanetBubble(pos: pos)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            // — Ángulos —
                            VStack(spacing: 6) {
                                HStack {
                                    SectionHeader(title: "Todas las combinaciones (\(vm.displayedAngles.count) pares)")
                                    Spacer()
                                }
                                .padding(.horizontal)

                                ForEach(Array(vm.displayedAngles.enumerated()), id: \.offset) { _, pair in
                                    AngleRow(pair: pair)
                                }
                                .padding(.horizontal)
                            }
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Ángulos Planetarios")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ahora") { vm.selectedDate = Date(); vm.calculate() }
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(.goldAccent)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct MiniPlanetBubble: View {
    let pos: PlanetPosition
    var body: some View {
        VStack(spacing: 4) {
            PlanetBadge(planet: pos.planet, size: 30)
            Text(String(format: "%.2f°", pos.eclipticLongitude))
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.silverAccent)
            Text(pos.zodiacSign.components(separatedBy: " ").last ?? "")
                .font(.system(size: 10))
            if pos.retrograde {
                Text("℞").font(.system(size: 9, weight: .bold)).foregroundColor(.red)
            }
        }
        .padding(8)
        .background(Color.spaceMid.opacity(0.6))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(pos.planet.swiftUIColor.opacity(0.3), lineWidth: 1))
    }
}

struct AngleRow: View {
    let pair: AnglePair
    @State private var expanded = false

    var hasAspect: Bool { !pair.aspect.isEmpty }

    var body: some View {
        Button(action: { withAnimation(.spring(response: 0.3)) { expanded.toggle() } }) {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    // Planeta 1
                    HStack(spacing: 6) {
                        PlanetBadge(planet: pair.p1, size: 26)
                        Text(pair.p1.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.silverAccent)
                    }

                    Spacer()

                    // Ángulo central
                    VStack(spacing: 2) {
                        Text(String(format: "%.4f°", pair.angle))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(hasAspect ? .goldAccent : .silverAccent)
                        if hasAspect {
                            Text(pair.aspect)
                                .font(.system(size: 9))
                                .foregroundColor(.goldAccent.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }

                    Spacer()

                    // Planeta 2
                    HStack(spacing: 6) {
                        Text(pair.p2.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.silverAccent)
                        PlanetBadge(planet: pair.p2, size: 26)
                    }
                }
                .padding(.horizontal, 12).padding(.vertical, 10)

                if expanded {
                    Divider().background(Color.goldAccent.opacity(0.2))
                    VStack(spacing: 5) {
                        InfoRow(label: "Ángulo entre \(pair.p1.symbol) y \(pair.p2.symbol)",
                                value: String(format: "%.6f°", pair.angle), highlight: true)
                        InfoRow(label: "Diferencia con signo",
                                value: String(format: "%+.6f°", pair.signedAngle))
                        InfoRow(label: "Complemento (360°−ángulo)",
                                value: String(format: "%.6f°", 360 - pair.angle))
                        if hasAspect {
                            InfoRow(label: "Aspecto",
                                    value: pair.aspect, highlight: true)
                            InfoRow(label: "Orbe al aspecto exacto",
                                    value: String(format: "%.4f°", orbToNearestAspect(pair.angle)))
                        }
                    }
                    .padding(12)
                }
            }
        }
        .buttonStyle(.plain)
        .background(hasAspect ? Color.goldAccent.opacity(0.08) : Color.spaceMid.opacity(0.4))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(
            hasAspect ? Color.goldAccent.opacity(0.4) : pair.p1.swiftUIColor.opacity(0.2), lineWidth: 1))
    }
}

func orbToNearestAspect(_ angle: Double) -> Double {
    let aspects = [0.0, 30, 45, 60, 90, 120, 135, 150, 180]
    return aspects.map { abs(angle - $0) }.min() ?? 0
}
