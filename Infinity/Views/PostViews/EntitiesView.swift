import SwiftUI

struct EntitiesView: View {
    @ObservedObject var viewModel: EntitiesViewModel
    @State private var hasAppeared = false

    var body: some View {
        VStack {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.entities, id: \.id) { entity in
                            VStack {
                                if let avatarURL = entity.avatar, let url = URL(string: avatarURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 70, height: 70)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 70, height: 70)
                                    }
                                } else {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 70, height: 70)
                                }
                                
                                Text(entity.entityName)
                                    .font(.caption)
                                
                                // 未查看标记暂时被注释掉
                                // if entity.unviewed {
                                //     Circle()
                                //         .fill(Color.red)
                                //         .frame(width: 10, height: 10)
                                // }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if !hasAppeared {
                viewModel.fetchEntities()
                hasAppeared = true
            }
        }
    }
}
