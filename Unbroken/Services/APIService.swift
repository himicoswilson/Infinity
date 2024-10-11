import Foundation

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError(Data?)
    case encodingError
    case networkError(Error)
    case httpError(Int)
}

class APIService {
    static let shared = APIService()
    private init() {}
    
    func fetch<T: Codable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.token) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        print("发送请求到: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "Invalid response", code: 0, userInfo: nil))
        }
        
        print("HTTP 状态码: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode != 200 {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        // 打印原始数据
        if let jsonString = String(data: data, encoding: .utf8) {
            print("收到的原始JSON数据:")
            print(jsonString)
        } else {
            print("无法将数据转换为字符串")
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(T.self, from: data)
            print("成功解码数据: \(decodedData)")
            return decodedData
        } catch {
            print("解码错误: \(error)")
            throw APIError.decodingError(data)
        }
    }
    
    func post<T: Codable>(_ endpoint: String, body: [String: Any], completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("请求地址: \(url.absoluteString)")
        print("请求体: \(body)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(.encodingError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("网络错误: \(error.localizedDescription)")
                completion(.failure(.networkError(error)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP 状态码: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
            }
            
            guard let data = data else {
                print("没有收到数据")
                completion(.failure(.noData))
                return
            }
            
            print("收到的数据: \(String(data: data, encoding: .utf8) ?? "无法解码")")
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("解码错误: \(error.localizedDescription)")
                completion(.failure(.decodingError(data)))  // 传递 data 参数
            }
        }.resume()
    }
    
    // 添加其他 API 方法，如 put, delete 等
}
