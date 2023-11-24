import SwiftUI
import ToastUI

struct FishTextView: View {
    @State public var fishText = "fishText"
    @State private var isPresentingToast = false
    var body: some View {
        VStack
        {
            Text("РыбаТекст")
                .font(.title)
                .bold()
                .foregroundColor(.accentColor)
            
            Spacer()
            
            TextEditor(text: $fishText)
            
            Spacer()
            
            Button(action: {
                UIPasteboard.general.string = fishText
                isPresentingToast.toggle()
            }, label: {
                Text("Копировать")
                    .padding(.all, 25)
                    .background(Color.accentColor)
                    .foregroundColor(Color.white)
                    .cornerRadius(25)
                    .bold()
            })
            .toast(isPresented: $isPresentingToast, dismissAfter: 1.0)
            {
                ToastView("Скопировано")
            }
            .toastViewStyle(InformationToastViewStyle())
        }
        .padding(.all, 25)
    }
}

struct FishTextView_Previews: PreviewProvider {
    static var previews: some View {
        FishTextView()
    }
}
