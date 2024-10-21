import Foundation
import Alamofire

class APIService {
    static let shared = APIService()
    private init() {}
    
    private func getHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        if let token = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.token) {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
    
    func request<T: Codable>(_ endpoint: String, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let headers = getHeaders()
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, statusCode: response.response?.statusCode, data: response.data))
                    }
                }
        }
    }
    
    func upload<T: Codable>(
        _ endpoint: String,
        method: HTTPMethod = .post,
        parameters: Parameters? = nil,
        files: [String: Data],
        fileNames: [String: String]? = nil,
        mimeTypes: [String: String]? = nil,
        fileFieldName: String = "images"
    ) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var headers = getHeaders()
        headers["Content-Type"] = "multipart/form-data"
        
        print("请求 URL: \(url)")
        print("请求头: \(headers)")
        print("参数: \(parameters ?? [:])")
        print("文件数量: \(files.count)")
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multipartFormData in
                // 添加普通参数
                if let parameters = parameters {
                    for (key, value) in parameters {
                        if let stringValue = value as? String {
                            multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
                        } else if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []) {
                            multipartFormData.append(jsonData, withName: key)
                        }
                    }
                }
                
                // 添加文件
                if fileFieldName == "images" {
                    for (index, (_, data)) in files.enumerated() {
                        multipartFormData.append(data, withName: "images", fileName: "image\(index).jpg", mimeType: "image/jpeg")
                        print("添加文件: images, 文件名: image\(index).jpg, 大小: \(data.count) bytes")
                    }
                } else {
                    for (key, data) in files {
                        let fileName = fileNames?[key] ?? "\(key).jpg"
                        let mimeType = mimeTypes?[key] ?? "image/jpeg"
                        multipartFormData.append(data, withName: fileFieldName, fileName: fileName, mimeType: mimeType)
                        print("添加文件: \(fileFieldName), 文件名: \(fileName), 大小: \(data.count) bytes")
                    }
                }
            }, to: url, method: method, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                print("响应状态码: \(response.response?.statusCode ?? 0)")
                print("响应数据: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "")")
                
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: self.handleError(error, statusCode: response.response?.statusCode, data: response.data))
                }
            }
        }
    }
    
    func downloadFile(_ endpoint: String, to destinationURL: URL) async throws -> URL {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let headers = getHeaders()
        
        return try await withCheckedThrowingContinuation { continuation in
            let destination: DownloadRequest.Destination = { _, _ in
                return (destinationURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            AF.download(url, method: .get, headers: headers, to: destination)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success:
                        if let fileURL = response.fileURL {
                            continuation.resume(returning: fileURL)
                        } else {
                            continuation.resume(throwing: APIError.noData)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, statusCode: response.response?.statusCode, data: response.resumeData))
                    }
                }
        }
    }
    
    private func handleError(_ error: AFError, statusCode: Int?, data: Data?) -> Error {
        if let data = data, let serverError = try? JSONDecoder().decode(ServerError.self, from: data) {
            return APIError.serverError(serverError.message)
        } else if let statusCode = statusCode {
            return APIError.httpError(statusCode)
        } else {
            return APIError.networkError(error.localizedDescription)
        }
    }
    
    static func handleError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidURL:
                return "无效的URL"
            case .noData:
                return "服务器没有返回数据"
            case .decodingError:
                return "数据解码失败"
            case .encodingError:
                return "数据编码失败"
            case .networkError(let message):
                return "网络错误: \(message)"
            case .httpError(let statusCode):
                return "HTTP错误: 状态码 \(statusCode)"
            case .serverError(let message):
                return "服务器错误: \(message)"
            }
        } else {
            return "未知错误: \(error.localizedDescription)"
        }
    }
}

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    case encodingError
    case networkError(String)
    case httpError(Int)
    case serverError(String)
}

struct ServerError: Codable {
    let message: String
}

// 便利扩展
extension APIService {
    func get<T: Codable>(_ endpoint: String, parameters: Parameters? = nil) async throws -> T {
        try await request(endpoint, method: .get, parameters: parameters, encoding: URLEncoding.default)
    }
    
    func post<T: Codable>(_ endpoint: String, parameters: Parameters? = nil) async throws -> T {
        try await request(endpoint, method: .post, parameters: parameters)
    }
    
    func put<T: Codable>(_ endpoint: String, parameters: Parameters? = nil) async throws -> T {
        try await request(endpoint, method: .put, parameters: parameters)
    }
    
    func delete<T: Codable>(_ endpoint: String, parameters: Parameters? = nil) async throws -> T {
        try await request(endpoint, method: .delete, parameters: parameters)
    }
}
