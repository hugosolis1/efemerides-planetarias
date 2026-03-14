// PositionsView.swift — Tab 1: Posiciones planetarias para una fecha
import SwiftUI

class PositionsViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var positions: [PlanetPosition] = []
    @Published var julianDay: Double = 0
    @Published var gmst: Double = 0
    @Published var isLoading = false
    @Published var selectedPlanet: PlanetPosition? = nil

    var tz: Double { AppState.shared.timezone }

    init() { calculate() }

    func calculate() {
        isLoading = true
        let d = selectedDate, tz = self.tz
        DispatchQueue.global(qos: .userInitiated).async {
            let JD = jdFromDate(d) + tz / 24.0  // local → UT already handled in calcPlanets
            let jdUT = jdFromDate(d)
            let T = (jdUT - 2451545.0) / 36525.0
            let g = norm360(280.46061837 + 360.98564736629*(jdUT-2451545.0) + 0.000387933*T*T - T*T*T/38710000)
            let res = calcPlanets(jd: jdUT)
            DispatchQueue.main.async {
                self.positions = res
                self.julianDay = jdUT
                self.gmst = g
                self.isLoading = false
            }
        }
    }
}

struct PositionsView: View {
    @StateObject private var vm = PositionsViewModel()
    @AppStorage("posTimezone") private var tzStr: String = "UTC"

    var body: some View {
        NavigationView {
            ZStack {
                SpaceBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        // — Selector de fecha —
                        VStack(spacing: 12) {
                            DateTimePicker(title: "Fecha y Hora", date: $vm.selectedDate)
                            TimezoneRow(tz: $vm.selectedDate)
                            CalcButton(title: "Calcular Posiciones", action: vm.calculate, isLoading: vm.isLoading)
                        }
                        .padding(.horizontal)

                        // — Datos técnicos —
                        if !vm.positions.isEmpty {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Día Juliano").font(.system(size: 10, design: .monospaced)).foregroundColor(.dimText)
                                    Text(String(format: "%.6f", vm.julianDay))
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(.goldAccent)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("T.S. Greenwich").font(.system(size: 10, design: .monospaced)).foregroundColor(.dimText)
                                    Text(String(format: "%.4f°", vm.gmst))
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(.silverAccent)
                                }
                            }
                            .padding(12)
                            .background(Color.spaceMid.opacity(0.5))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.goldAccent.opacity(0.15), lineWidth: 1))
                            .padding(.horizontal)

                            // — Lista de planetas —
                            VStack(spacing: 8) {
                                ForEach(vm.positions) { pos in
                                    PlanetCard(pos: pos)
                                        .onTapGesture { vm.selectedPlanet = (vm.selectedPlanet?.planet == pos.planet) ? nil : pos }
                                    if vm.selectedPlanet?.planet == pos.planet {
                                        PlanetDetail(pos: pos)
                                            .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.97, anchor: .top)),
                                                                     removal: .opacity))
                                    }
                                }
                            }
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.selectedPlanet?.planet)
                            .padding(.horizontal)
                        }
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Posiciones Planetarias")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ahora") { vm.selectedDate = Date(); vm.calculate() }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.goldAccent)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct PlanetCard: View {
    let pos: PlanetPosition
    var body: some View {
        HStack(spacing: 12) {
            PlanetBadge(planet: pos.planet, size: 38)
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(pos.planet.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.silverAccent)
                    if pos.retrograde {
                        Text("℞").font(.system(size: 12, weight: .bold)).foregroundColor(.red)
                    }
                }
                Text(lonStr(pos.eclipticLongitude))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.goldAccent)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(pos.zodiacSign)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.dimText)
                Text(String(format: "%.4f°", pos.eclipticLongitude))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.silverAccent)
            }
        }
        .padding(12)
        .background(Color.spaceMid.opacity(0.5))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(pos.planet.swiftUIColor.opacity(0.35), lineWidth: 1))
    }
}

struct PlanetDetail: View {
    let pos: PlanetPosition
    var body: some View {
        VStack(spacing: 0) {
            Divider().background(Color.goldAccent.opacity(0.2))
            VStack(spacing: 6) {
                Group {
                    InfoRow(label: "Longitud Eclíptica",  value: String(format: "%.6f°", pos.eclipticLongitude), highlight: true)
                    InfoRow(label: "Latitud Eclíptica",   value: String(format: "%.6f°", pos.eclipticLatitude))
                    InfoRow(label: "Longitud Zodiacal",   value: lonStr(pos.eclipticLongitude), highlight: true)
                    InfoRow(label: "Grado en Signo",      value: String(format: "%.4f° de %@", pos.zodiacDegree, pos.zodiacSign))
                }
                Divider().background(Color.dimText.opacity(0.3))
                Group {
                    InfoRow(label: "Asc. Recta",          value: raStr(pos.rightAscension))
                    InfoRow(label: "Declinación",         value: dmsStr(pos.declination))
                    InfoRow(label: "Long. Heliocéntrica", value: String(format: "%.6f°", pos.helioLongitude))
                    InfoRow(label: "Lat. Heliocéntrica",  value: String(format: "%.6f°", pos.helioLatitude))
                    InfoRow(label: "Radio Helioc. (UA)",  value: String(format: "%.8f", pos.helioRadius))
                    InfoRow(label: "Dist. Geocéntrica (UA)", value: String(format: "%.8f", pos.geocentricDistance))
                }
                if pos.planet != .sun {
                    Divider().background(Color.dimText.opacity(0.3))
                    InfoRow(label: "Elongación (Sol)",    value: String(format: "%.4f°", pos.elongation))
                    InfoRow(label: "Estado",              value: pos.retrograde ? "RETRÓGRADO ℞" : "Directo →",
                            highlight: pos.retrograde)
                }
            }
            .padding(12)
        }
        .background(Color.spaceDeep.opacity(0.9))
        .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.goldAccent.opacity(0.15), lineWidth: 1))
    }
}

// Selector de zona horaria simplificado
struct TimezoneRow: View {
    @Binding var tz: Date  // dummy binding, only to trigger redraw
    @AppStorage("tzOffset") var tzOffset: Double = Double(TimeZone.current.secondsFromGMT())/3600

    var body: some View {
        HStack {
            Text("Zona Horaria")
                .font(.system(size: 11, design: .monospaced)).foregroundColor(.dimText)
            Spacer()
            Text(String(format: "UTC%+.1f", tzOffset))
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.silverAccent)
            Stepper("", value: $tzOffset, in: -12...14, step: 0.5)
                .labelsHidden()
                .onChange(of: tzOffset) { AppState.shared.timezone = $0 }
        }
        .padding(12)
        .background(Color.spaceMid.opacity(0.4))
        .cornerRadius(8)
    }
}

// Corner radius helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat; var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let p = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                             cornerRadii: CGSize(width: radius, height: radius))
        return Path(p.cgPath)
    }
}
