import SwiftUI
import Kingfisher

struct EntitiesView: View {
    @ObservedObject var viewModel: EntitiesViewModel
    var onEntitySelected: (EntityDTO?) -> Void
    @State private var selectedEntityId: Int?

    var body: some View {
        VStack {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.entities, id: \.id) { entity in
                            EntityView(entity: entity, isSelected: entity.entityID == selectedEntityId)
                                .onTapGesture {
                                    if selectedEntityId == entity.entityID {
                                        selectedEntityId = nil
                                        onEntitySelected(nil)
                                    } else {
                                        selectedEntityId = entity.entityID
                                        onEntitySelected(entity)
                                        if entity.unviewed {
                                            Task {
                                                await viewModel.updateEntityViewedStatus(entity.entityID)
                                            }
                                        }
                                    }
                                }
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
    let isSelected: Bool
    
    var body: some View {
        VStack {
            if let avatarURL = entity.avatar, let url = URL(string: avatarURL) {
                KFImage(url)
                    .resizable()
                    .placeholder {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 69, height: 69)
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 69, height: 69)
                    .clipShape(Circle())
                    .overlay(
                        ZStack {
                            Circle()
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                            if entity.unviewed {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 16, height: 16)
                                    .offset(x: 30, y: -20)
                            }
                        }
                    )
                    .frame(width: 72, height: 72)
                    
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 69, height: 69)
            }
            
            Text(entity.entityName)
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .primary)
        }
    }
}
