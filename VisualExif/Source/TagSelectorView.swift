import SwiftUI

struct TagSelectorView: View {
    @Binding var selectedCategories: Set<ExifToolWrapper.ExifCategory>
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Metadata to Remove")
                .font(.headline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                ForEach(ExifToolWrapper.ExifCategory.allCases, id: \.self) { category in
                    Toggle(isOn: binding(for: category)) {
                        HStack {
                            Text(category.rawValue)
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                        }
                    }
                    .toggleStyle(CheckboxToggleStyle())
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func binding(for category: ExifToolWrapper.ExifCategory) -> Binding<Bool> {
        Binding {
            selectedCategories.contains(category)
        } set: { isOn in
            if isOn {
                // If selecting 'All', maybe clear others? Or keep simple.
                selectedCategories.insert(category)
            } else {
                selectedCategories.remove(category)
            }
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(configuration.isOn ? .blue : .secondary)
                    .font(.system(size: 20))
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}
