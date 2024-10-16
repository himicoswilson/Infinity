struct Constants {
    static let appName = "HimiLove"
    static let appVersion = "1.0.0"
    
    // 定义基础 URL
    static let baseURL = "https://love.ytcccc.com/api"
    // static let baseURL = "http://localhost:8080/api"

    struct UserDefaultsKeys {
        static let token = "token"
        static let userID = "userID"
        static let username = "username"
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
        
        // 实体相关 API
        static let entities = "\(baseURL)/entities"
        static let updateLastViewed = { (entityId: Int) in "\(baseURL)/entities/\(entityId)/last-viewed" }
        
        // 其他 API 端点可以继续添加
    }
}
