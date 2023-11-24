import SwiftUI
import ToastUI

struct ContentView: View {
    @State private var sentences = 3.0
    @State private var isLoading = false
    @State private var mainColor = "MainColor"
    @State private var isShowFishText = false
    @State private var fishText = "Fish Text"
    @State private var generateButtonText = String(localized: "GenerateText", defaultValue: "Сгенерировать текст")
    @State private var path = NavigationPath()
    @State private var requestType = RequestType.sentence
    let url = "https://fish-text.ru/get"
    let minFishTextValue = 1
    let maxFishTextValue = 25
    
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
                        HStack(spacing: -5)
                        {
                            Text("Количество")
                            Picker("Выбор типа РыбаТекста", selection: $requestType) {
                                Text("предложений").tag(RequestType.sentence)
                                Text("абзацев").tag(RequestType.paragraph)
                                Text("заголовков").tag(RequestType.title)
                            }
                        }
                        .foregroundColor(Color.gray)
                        
                        Slider(
                            value: $sentences,
                            in: Double(minFishTextValue)...Double(maxFishTextValue),
                            step: 1
                        ) {
                            Text("Количество")
                        } minimumValueLabel: {
                            Text(String(minFishTextValue))
                        } maximumValueLabel: {
                            Text(String(maxFishTextValue))
                        }
                        Text("\(sentences.formatted())")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task{
                            if (!isLoading)
                            {
                                isLoading = true
                                generateButtonText = String(localized: "Wait", defaultValue: "Подождите..")
                                try await self.fishText = Api().sendRequestAsync(url: url, requestType: requestType, sentencesCount: Int(sentences))
                                print(self.fishText)
                                isLoading = false
                                generateButtonText = String(localized: "GenerateText", defaultValue: "Сгенерировать текст")
                                isShowFishText.toggle()
                            }
                        }
                    }, label: {
                        Text(generateButtonText)
                    })
                    .navigationDestination(isPresented: $isShowFishText)
                    {
                        FishTextView(fishText: fishText)
                    }
                    .padding(.all, 25.0)
                    .background(Color.accentColor)
                    .cornerRadius(25.0)
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
enum RequestType: String, CaseIterable, Identifiable
{
    case sentence = "sentence"
    case paragraph = "paragraph"
    case title = "title"
    var id: Self { self }
}
class Api
{
    public func sendRequestAsync(url: String, requestType: RequestType, sentencesCount: Int) async throws  -> String
    {
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: requestType.rawValue),
            URLQueryItem(name: "number", value: String(sentencesCount))
        ]
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: urlComponents.url!)
        
        if let (data, _) = try? await URLSession.shared.data(for: request)
        {
            let result = try JSONDecoder().decode(FishTextRequest.self, from: data)
            return result.text
        }
        else
        {
            return "Error"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
