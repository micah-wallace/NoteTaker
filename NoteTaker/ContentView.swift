//
//  ContentView.swift
//  NoteTaker
//
//  Created by Wallace, Micah on 2/13/26.
//

import SwiftUI
import SwiftData
import Foundation





struct Note: Codable, Identifiable {
    var id = UUID()
    var title: String
    var content: String
    var isCompleted: Bool = false
}

struct NoteList: Codable, RawRepresentable{
    var items: [Note]
    
    enum CodingKeys: String, CodingKey{
        case items
    }
    
    init(items: [Note]){
        self.items = items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([Note].self, forKey: .items)
    }
    
    func encode(to encoder: Encoder) throws{
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
    }

    init?(rawValue: String){
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(NoteList.self, from: data)
        else{
            return nil
        }
        self = result
    }
    
    var rawValue: String{
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else{
            return "{\"items\": [] }"
        }
        return result
    }
}

struct NoteEditView: View{
    @Binding var note: Note
    @Environment(\.dismiss) var dismiss
    
    var body: some View{
        NavigationView{
            Form{
                TextField("Title", text: $note.title)
                TextEditor(text: $note.content)
                    .frame(minHeight: 200)
            }
            .navigationTitle("Edit Note")
            .toolbar{
                Button("Save"){
                    dismiss()
                }
            }
        }
    }
}

struct AddNoteView: View{
    @Binding var note: Note
    var onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View{
        NavigationView{
            Form{
                Section(header: Text("Note Title")){
                    TextField("Enter Title", text: $note.title)
                }
                Section(header: Text("Note Content")){
                    TextField("Enter Content", text: $note.content)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("New Note")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Cancel"){
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Save"){
                        onSave()
                    }
                    .disabled(note.title.isEmpty)
                }
            }
        }
    }
}


struct NoteDetailView: View{
    @Binding var note: Note
    @State private var isEditing = false
    
    var body: some View{
        VStack(alignment: .leading, spacing: 20){
            Text(note.title)
                .font(.largeTitle)
                .bold()
                .strikethrough(note.isCompleted, color: .primary)
                .foregroundColor(note.isCompleted ? .green : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView{
                Text(note.content)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(note.isCompleted ? .green : .primary)
            }
            Spacer()
            
            Button(action: {
                note.isCompleted.toggle()
            }){
                Text(note.isCompleted ? "Mark as Incomplete": "Mark as Complete")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(note.isCompleted ? Color.orange : Color.green)
                    .cornerRadius(10)
            }
            .padding(.bottom, 10)
        }
        .padding()
        .navigationTitle("Note Details")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button("Edit"){
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing){
            NoteEditView(note: $note)
        }
    }
}


struct ContentView: View{
    
    @AppStorage("Note_Lists") private var noteList: NoteList = NoteList(items: [])
    
    @State private var showingAddNote = false
    @State private var newNote = Note(title: "", content: "")
    
    var body: some View {
        
        NavigationView{
            List{
                ForEach(noteList.items.indices, id: \.self){ index in
                    NavigationLink(destination: NoteDetailView(note: $noteList.items[index])){
                        VStack(alignment: .leading){
                            Text(noteList.items[index].title)
                                .font(.headline)
                                .strikethrough(noteList.items[index].isCompleted, color: .primary)
                                .foregroundColor(noteList.items[index].isCompleted ? Color.green : .primary)
                            Text(noteList.items[index].content)
                                .font(.subheadline)
                                .lineLimit(1)
                                .foregroundColor(noteList.items[index].isCompleted ? Color.green : .primary)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(noteList.items[index].isCompleted ? Color.green : Color.primary)
                        )
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteNote)
            }
            .navigationTitle("My Notes")
            .toolbar{
                Button {
                    newNote = Note(title: "", content: "")
                    showingAddNote = true
                }
                label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddNote){
                AddNoteView(note: $newNote){
                    saveNewNote()
                }
            }
        }
    }
    
    
    
    func saveNewNote(){
        
        
        var updatedItems = noteList.items
        updatedItems.append(newNote)
        noteList = NoteList(items: updatedItems)
        showingAddNote = false
    }
    
    func deleteNote(at offsets: IndexSet){
        var updatedItems = noteList.items
        updatedItems.remove(atOffsets: offsets)
        noteList = NoteList(items: updatedItems)
    }
    
    
    
}

