
import Foundation

struct DeviceData: Codable {
    let device_id: String
    let battery_level: Double
    let mode: String
    let latitude: Double
    let longitude: Double
    let timestamp: String
}

struct ModeChangeRequest: Codable {
    let mode: String
}

struct ModeChangeResponse: Codable {
    let success: Bool
    let message: String
}

class AzureAPI {
    static let baseURL = "https://bikelight-functions.azurewebsites.net/api"
    static let authCode: String = {
        guard let authCode = Bundle.main.object(forInfoDictionaryKey: "AzureAuthCode") as? String else {
            fatalError("AzureAuthCode not found in Info.plist")
        }
        return authCode
    }()

    static func getDeviceList(completion: @escaping ([String]?) -> Void) {
        let urlString = "\(baseURL)/devices?code=\(authCode)"
        guard let url = URL(string: urlString) else { return completion(nil) }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let ids = try? JSONDecoder().decode([String].self, from: data)
                completion(ids)
            } else {
                completion(nil)
            }
        }.resume()
    }

    static func getDeviceData(deviceId: String, completion: @escaping (DeviceData?) -> Void) {
        let urlString = "\(baseURL)/devices/\(deviceId)?code=\(authCode)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return completion(nil)
        }
        
        print("Fetching from URL: \(urlString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                completion(nil)
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("Server returned error code: \(httpResponse.statusCode)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            print("Data received: \(String(data: data, encoding: .utf8) ?? "Could not convert to string")")
            
            do {
                let deviceData = try JSONDecoder().decode(DeviceData.self, from: data)
                completion(deviceData)
            } catch {
                print("JSON Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }

    static func getDeviceHistory(deviceId: String, startDate: String? = nil, endDate: String? = nil, completion: @escaping ([DeviceData]?) -> Void) {
        var urlString = "\(baseURL)/devices/\(deviceId)/history?code=\(authCode)"
        if let startDate = startDate { urlString += "&startDate=\(startDate)" }
        if let endDate = endDate { urlString += "&endDate=\(endDate)" }
        guard let url = URL(string: urlString) else { return completion(nil) }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let history = try? JSONDecoder().decode([DeviceData].self, from: data)
                completion(history)
            } else {
                completion(nil)
            }
        }.resume()
    }

    static func updateDeviceMode(deviceId: String, mode: String, completion: @escaping (ModeChangeResponse?) -> Void) {
        let urlString = "\(baseURL)/devices/\(deviceId)/mode?code=\(authCode)"
        guard let url = URL(string: urlString) else { return completion(nil) }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ModeChangeRequest(mode: mode)
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data {
                let response = try? JSONDecoder().decode(ModeChangeResponse.self, from: data)
                completion(response)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
