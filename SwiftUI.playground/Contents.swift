import SwiftUI
import PlaygroundSupport

class Mix: ObservableObject {
    @Published var name: String
    @Published var ingredients: [String]
    
    init(name: String, ingredients: [String]) {
        self.name = name
        self.ingredients = ingredients
    }
    
    convenience init() {
        self.init(name: "", ingredients: [])
    }
}

struct ContentView: View {
    @ObservedObject private var mix = Mix()
    @State private var showSheet = false
    
    private func getInfo() {
        showSheet.toggle()
    }
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: FormView()) {
                    Text("Form")
                }
                
                NavigationLink(destination: StackView()) {
                    Text("Stacks")
                }
                
                NavigationLink(destination: ButtonView()) {
                    Text("Buttons")
                }
                
                NavigationLink(destination: FramedView()) {
                    Text("Framed")
                }
                
                NavigationLink(destination: ListView()) {
                    Text("List")
                }
                
                NavigationLink(destination: BindingView(mix: mix)) {
                    Text("Data Binding")
                }
            }
            .navigationBarTitle("SwiftUI", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: getInfo) {
                Image(systemName: "info.circle")
            })
        }
        .sheet(isPresented: $showSheet) { InfoView() }
        .onAppear() {
            print("Appeared")
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())

struct InfoView: View {
    var body: some View {
        Text("Info View")
    }
}

struct FormView: View {
    @State var name: String = ""
    let locations = ["Portland", "Seattle", "Austin"]
    @State var locationIndex: Int = 0
    @State var buildingNumber: Int = 0
    let formatter = NumberFormatter()
    let buildingTypes = ["Lab", "Administration", "Housing"]
    @State var buildingTypeIndex: Int = 0
    
    var body: some View {
        Form {
            Section(header: Text("Personal Info")) {
                TextField("Name", text: $name)
                Picker("Location", selection: $locationIndex) {
                    ForEach(0 ..< locations.count) {
                        Text(self.locations[$0])
                    }
                }
                TextField("Building", value: $buildingNumber, formatter: formatter)
                .keyboardType(.numberPad)
                Picker("Building type", selection: $buildingTypeIndex) {
                    ForEach(0 ..< buildingTypes.count) {
                        Text(self.buildingTypes[$0])
                    }
                }
            .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Rows")) {
                ForEach(0 ..< 3) {
                    Text("Row \($0)")
                }
            }
        }
        .navigationBarTitle("Form", displayMode: .inline)
    }
}

struct StackView: View {
    @State private var showingAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Row 1")
                Spacer()
            }
            
            HStack {
                Text("Row 2")
                Spacer()
            }
            
            Button("Alert") { self.showingAlert = true }
            
            Spacer()
        }
        .padding(8.0)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Alert"), message: Text("Alert message"), dismissButton: .default(Text("OK")))
        }
        .navigationBarTitle("Stacks", displayMode: .inline)
    }
}

struct Bordered: ViewModifier {
    func body(content: Content) -> some View {
        content
        .padding(8)
        .background(Color.blue)
        .cornerRadius(4)
    }
}

extension View {
    func bordered() -> some View {
        modifier(Bordered())
    }
}

struct ButtonView: View {
    private func map() {
        print("map")
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Button(action: { print("button pressed") }) {
                Image(systemName: "paperplane.fill")
                .renderingMode(.original)
            }
            .bordered()
            
            Button(action: { print("other button") }) {
                Image(systemName: "plus.circle")
                .renderingMode(.original)
            }
            .padding(8)
            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
            
            Button(action: map) {
                Image(systemName: "map.fill")
                .renderingMode(.original)
            }
            .padding(8)
            .background(Color.blue)
            .clipShape(Capsule())
            .shadow(color: .black, radius: 2)
            
            Spacer()
        }
        .navigationBarTitle("Buttons", displayMode: .inline)
    }
}

struct FramedView: View {
    private var title: some View { Text("Title").font(.largeTitle) }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Spacer()
                    
                    title
                    
                    Spacer()
                }
                
                HStack {
                    Text("SwiftUI")
                    Spacer()
                }
            }
            .padding(8.0)
        
            Text("Borders")
            .padding()
            .background(Color.red)
            .cornerRadius(16)
            .padding()
            .background(Color.blue)
            .cornerRadius(16)
            .padding()
            .background(Color.green)
            .cornerRadius(16)
            .padding()
            .background(Color.yellow)
            .cornerRadius(16)

            Spacer()

            VStack {
                Button("Done") {}
                .frame(width: 100, height: 40)
                .background(Color.yellow)
                .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemTeal))
        .navigationBarTitle("Framed", displayMode: .inline)
    }
}

struct ListView: View {
    let food = ["Chicken", "Bread", "Limes", "Carrots"]
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Section 1")) {
                    Text("first")
                    Text("second")
                }
                
                Section(header: Text("Section 2")) {
                    ForEach(1 ..< 3) {
                        Text("row \($0)")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            
            List(food, id: \.self) {
                Text($0)
            }
        }
    }
}

struct BindingView: View {
    @ObservedObject private var mix: Mix
    
    init(mix: Mix) {
        self.mix = mix
    }
    
    func load() {
        mix.name = "Rum and coke"
        mix.ingredients = ["Rum", "Coke", "Ice"]
    }
    
    var body: some View {
        VStack {
            Text(mix.name)
            .font(.title)
            .bordered()
            .padding()
            
            List(mix.ingredients, id: \.self) { ingredient in
                Text(ingredient)
            }
            
            Button(action: load) {
                Text("Load")
            }
            .padding()
        }
        .navigationBarTitle("Binding", displayMode: .inline)
    }
}
