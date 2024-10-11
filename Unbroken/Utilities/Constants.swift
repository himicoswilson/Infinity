struct Constants {
    static let appName = "HimiLove"
    static let appVersion = "1.0.0"
    
    // 定义基础 URL
    static let baseURL = "http://localhost:8080/api"

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
        
        // 帖子相关 API
        static let posts = "\(baseURL)/posts"
        static let postById = { (postId: Int) in "\(baseURL)/posts/\(postId)" }
        
        // 情侣相关 API
        static let coupleInfo = "\(baseURL)/couples/user/"
        
        // 人物和宠物 API
        static let entities = "\(baseURL)/entities"
        
        // 其他 API 端点可以继续添加
    }
}