import SwiftUI

struct SearchBarTestView: View {
    // Sample array with various items.
    private let items: [String] = [
        "Order 1234 has been shipped.",
        "Meeting scheduled at 3 PM.",
        "Invoice 5678 is due next week.",
        "User 42 logged in successfully.",
        "The package weighs 2.5 kg.",
        "Reminder: Call client at 9 AM.",
        "Reservation for 4 confirmed.",
        "Ticket number 7890 is valid.",
        "Battery at 15% charge remaining.",
        "Flight 101 is now boarding.",
        "Event starts at 7:30 PM sharp.",
        "Item 999 is out of stock.",
        "Project deadline is in 5 days.",
        "The new model costs $399.",
        "Temperature dropped to -2°C last night.",
        "Warehouse has 250 units available.",
        "Task ID 555 is assigned to John.",
        "You have 8 new messages.",
        "Order 66 is pending approval.",
        "Conference room booked for 10 people."
    ]
    
    
    // A state variable to hold the current search text.
    @State private var searchText: String = ""
    
    // The selected search type, defaults to .contains.
    @State private var selectedSearchType: SearchType = .contains
    
    // Computed property to create a SearchBarComponent with the chosen search type.
    private var searchComponent: SearchBarComponent<String> {
        return SearchBarComponent<String>(
            data: items,
            searchType: selectedSearchType
        ) { item in
            return item
        }
    }
    
    // Computed property that filters items based on the search text using the selected search type.
    private var filteredItems: [String] {
        searchComponent.filter(with: searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Segmented Picker to Select Search Type
                Picker("Search Type", selection: $selectedSearchType) {
                    Text("Contains").tag(SearchType.contains)
                    Text("Begins With").tag(SearchType.beginsWith)
                    Text("Ends With").tag(SearchType.endsWith)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // MARK: - Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    // Using a custom text field (SCTextField) as before.
                    SCTextField(text: $searchText, type: .search, borderColor: .gray)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                }
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding([.horizontal, .top])
                
                // MARK: - Dropdown List of Filtered Items
                // Show dropdown only when there is search text and matching results.
                if !searchText.isEmpty && !filteredItems.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredItems, id: \.self) { item in
                                NavigationLink(destination: DetailView(item: item)) {
                                    Text(item)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white)
                                }
                                Divider()
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                    }
                    .frame(maxHeight: 200) // Limit dropdown height if many results
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Search Cases Test")
        }
    }
}

// A simple detail view to demonstrate redirection when an item is selected.
struct DetailView: View {
    let item: String
    
    var body: some View {
        Text("Detail for:\n\(item)")
            .padding()
            .navigationTitle("Detail")
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarTestView()
    }
}
