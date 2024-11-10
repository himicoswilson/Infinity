struct Constants {
    static let appName = "HimiLove"
    static let appVersion = "1.0.0"
    
    // 定义基础 URL
    static let baseURL = "https://love.ytcccc.com/api"
    // static let baseURL = "http://localhost:8080/api"

    struct BarkAPI {
        static let baseURL = "https://api.day.app"
        static let defaultGroup = "Infinity"
        static let defaultIcon = "https://himilove.oss-cn-shanghai.aliyuncs.com/icon/icon-64%403x.png"
        static let defaultScheme = "infinity://"
    }

    struct UserDefaultsKeys {
        static let token = "token"
        static let userID = "userID"
        static let username = "username"
        static let nickName = "nickName"
        static let currentUserBarkToken = "current_user_bark_token"
        static let loverBarkToken = "lover_bark_token"
    }
    
    struct APIEndpoints {
        // 用户相关 API
        static let login = "\(baseURL)/users/login"
        static let register = "\(baseURL)/users/register"
        static let users = "\(baseURL)/users"
        static let uploadUserAvatar = { (userId: Int) in "\(baseURL)/users/\(userId)/avatar" }
        
        // 帖子相关 API
        static let posts = "\(baseURL)/posts"
        static let postById = { (postId: Int) in "\(baseURL)/posts/\(postId)" }
        static let postByEntityId = { (entityId: Int, page: Int, pageSize: Int) in "\(baseURL)/posts/entity/\(entityId)/\(page)/\(pageSize)" }

        // 情侣相关 API
        static let coupleInfo = "\(baseURL)/couples/user/"
        static let uploadCoupleBackground = { (coupleId: Int) in "\(baseURL)/couples/\(coupleId)" }
        
        // 评论相关 API
        static let comments = "\(baseURL)/comments"
        
        // 实体相关 API
        static let entities = "\(baseURL)/entities"
        static let updateLastViewed = { (entityId: Int) in "\(baseURL)/entities/\(entityId)/last-viewed" }

        // 位置相关 API
        static let postsNearby = "\(baseURL)/posts/nearby"
    }
}
