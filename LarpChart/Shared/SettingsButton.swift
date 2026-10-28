import SwiftUI

/// App preferences, kept out of the way in a toolbar popover.
struct SettingsButton: View {
    @AppStorage("leftHandMode") private var isLeftHanded = false
    @State private var isShowing = false

    var body: some View {
        Button { isShowing = true } label: {
            Label("Settings", systemImage: "gearshape")
        }
        .popover(isPresented: $isShowing) {
            Form {
                Section {
                    Toggle("Left-Hand Mode", isOn: $isLeftHanded)
                } footer: {
                    Text("Moves the unit palette to the right edge of the board.")
                }
            }
            .frame(idealWidth: 320, idealHeight: 140)
        }
    }
}
