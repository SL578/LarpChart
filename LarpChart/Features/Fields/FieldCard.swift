import SwiftUI

/// One field in the library grid: map preview with the name below.
struct FieldCard: View {
    let field: Field

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Color.clear
                .aspectRatio(4 / 3, contentMode: .fit)
                .overlay { thumbnail }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(field.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let data = field.thumbnailData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "map")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.tertiarySystemFill))
        }
    }
}
