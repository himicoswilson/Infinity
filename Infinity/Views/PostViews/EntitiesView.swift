import SwiftUI
import Kingfisher

struct EntitiesView: View {
    @ObservedObject var viewModel: EntitiesViewModel

    var body: some View {
        VStack {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.entities, id: \.id) { entity in
                            EntityView(entity: entity)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, -16)
            }
        }
    }
}

struct EntityView: View {
    let entity: EntityDTO
    
    var body: some View {
        VStack {
            if let avatarURL = entity.avatar, let url = URL(string: avatarURL) {
                KFImage(url)
                    .resizable()
                    .placeholder {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 70, height: 70)
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
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
