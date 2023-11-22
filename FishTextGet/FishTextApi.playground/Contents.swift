import UIKit

struct FishTextRequest: Codable
{
    var status: String
    var text: String
    var errorCode: Int?
}

var url = URLComponents(string: "https://fish-text.ru/get")!
let requestType = "sentence"
var sentencesCount = 1

url.queryItems = [
URLQueryItem(name: "type", value: requestType),
URLQueryItem(name: "number", value: String(sentencesCount))
]
url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
let request = URLRequest(url: url.url!)

let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let data = data
    {
        let dataString = String(data: data, encoding: .utf8)
        print("Data was getted")
        if let fishTextRequest = try? JSONDecoder().decode(FishTextRequest.self, from: data)
        {
            print("Successfull Response " + fishTextRequest.text)
        }
        else
        {
            print("Invalid Response")
        }
    }
    else if let error = error
    {
        print("HTTP Request Failed \(error)")
    }
}


task.resume()
