import SwiftUI

struct FishTextView: View {
    @State public var fishText = "fishText"
    var body: some View {
        VStack
        {
            Text("РыбаТекст")
                .font(.title)
                .bold()
                .foregroundColor(.accentColor)
            
            Spacer()
            
            ScrollView()
            {
                Text(fishText)
            }
            
            Spacer()
            
            Button(action: {
                UIPasteboard.general.string = fishText
            }, label: {
                Text("Копировать")
                    .padding(.all, 25)
                    .background(Color.accentColor)
                    .foregroundColor(Color.white)
                    .cornerRadius(25)
                    .bold()
            }
            )
        }
        .padding(.all, 25)
    }
}

struct FishTextView_Previews: PreviewProvider {
    static var previews: some View {
        FishTextView()
    }
}
