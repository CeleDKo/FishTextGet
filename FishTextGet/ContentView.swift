import SwiftUI

struct ContentView: View {
    @State private var sentences = 3.0
    @State private var isEditing = false
    @State private var mainColor = "MainColor"
    @State private var isShowFishText = false
    @State private var fishText = "Fish Text"
    @State private var path = NavigationPath()
    let url = "https://fish-text.ru/get"
    let requestType = "sentence"
    let minFishTextValue = 1
    let maxFishTextValue = 100
    
    var body: some View {
        NavigationStack
        {
            VStack()
            {
                VStack(spacing: 0)
                {
                    Image("fishIcon")
                    Text("РыбаТекст")
                        .bold()
                        .font(.title)
                        .foregroundColor(Color.accentColor)
                }
                
                
                Spacer()
                
                VStack()
                {
                    VStack
                    {
                        Text("Количество предложений")
                            .bold()
                            .foregroundColor(Color.gray)
                        Slider(
                            value: $sentences,
                            in: Double(minFishTextValue)...Double(maxFishTextValue),
                            step: 1
                        ) {
                            Text("Speed")
                        } minimumValueLabel: {
                            Text(String(minFishTextValue))
                        } maximumValueLabel: {
                            Text(String(maxFishTextValue))
                        } onEditingChanged: { editing in
                            isEditing = editing
                        }
                        Text("\(sentences.formatted())")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task{
                            try await self.fishText = Api().sendRequestAsync(url: url, requestType: requestType, sentencesCount: Int(sentences))
                            print(self.fishText)
                            isShowFishText.toggle()
                        }
                    }, label: {
                        Text("Сгенерировать текст")
                    })
                    .navigationDestination(isPresented: $isShowFishText)
                    {
                        FishTextView(fishText: fishText)
                    }
                    .padding(.all, 25.0)
                    .background(Color.accentColor)
                    .cornerRadius(/*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color(mainColor))
                    .bold()
                }
                .frame(height: 250.0)
                .padding(.horizontal, 50.0)
                
                
            }
            .padding(.bottom, 50.0)
        }
    }
}

struct FishTextRequest: Codable
{
    var status: String
    var text: String
    var errorCode: Int?
}
enum RequestType: String
{
    case sentence = "sentence"
    case paragraph = "paragraph"
    case title = "title"
}
class Api
{
    public func sendRequest(url: String, requestType: String, sentencesCount: Int)  -> String
    {
        var urlComponents = URLComponents(string: url)!
        var result :String? = ""
        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: requestType),
            URLQueryItem(name: "number", value: String(sentencesCount))
        ]
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: urlComponents.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data
            {
                let dataString = String(data: data, encoding: .utf8)
                result = dataString
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
        return result ?? ""
    }
    public func sendRequestAsync(url: String, requestType: String, sentencesCount: Int) async throws  -> String
    {
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: requestType),
            URLQueryItem(name: "number", value: String(sentencesCount))
        ]
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: urlComponents.url!)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let result = try JSONDecoder().decode(FishTextRequest.self, from: data)
        
        return result.text
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
