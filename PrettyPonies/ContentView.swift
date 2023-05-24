//
//  ContentView.swift
//  PrettyPoniesCLPA
//
//  Created by Tiger Nixon on 5/12/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    @State var ponyID: String = "1"
    @State var ponyName: String = "Buttercup"
    @State var ponySuperpower: String = "Flying"
    
    var body: some View {
        VStack {
            
            textFields()
            buttons()
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.ponies) { pony in
                        HStack {
                            Image("icon_pony")
                                .resizable()
                                .frame(width: 80.0, height: 80.0)
                         
                            VStack {
                                HStack {
                                    Text("Id:")
                                        .fontWeight(.bold)
                                    Text("\(pony.id)")
                                    Spacer()
                                }
                                HStack {
                                    Text("Name:")
                                        .fontWeight(.bold)
                                    Text(pony.name)
                                    Spacer()
                                }
                                HStack {
                                    Text("Super Power:")
                                        .fontWeight(.bold)
                                    Text(pony.superpower)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    func mockPonies() -> [Pony] {
        return [
        
            Pony(id: 1, name: "Buttercup", superpower: "Flying"),
            Pony(id: 2, name: "Sunshine Sprinkles", superpower: "Resurrection"),
            
        
        ]
    }
    
    func textFields() -> some View {
        VStack {
            HStack {
                HStack {
                    TextField("Pony ID", text: $ponyID)
                    .padding(.all, 6)
                }
                .background(RoundedRectangle(cornerRadius: 8.0).foregroundColor(Color(red: 0.92, green: 0.92, blue: 0.92)))
            }
            HStack {
                HStack {
                    TextField("Pony Name", text: $ponyName)
                    .padding(.all, 6)
                }
                .background(RoundedRectangle(cornerRadius: 8.0).foregroundColor(Color(red: 0.92, green: 0.92, blue: 0.92)))
            }
            HStack {
                HStack {
                    TextField("Pony Superpower", text: $ponySuperpower)
                    .padding(.all, 6)
                }
                .background(RoundedRectangle(cornerRadius: 8.0).foregroundColor(Color(red: 0.92, green: 0.92, blue: 0.92)))
            }
        }
    }
    
    func buttons() -> some View {
        VStack {
            HStack {
                Button {
                    Task {
                        await viewModel.createPony(id: ponyID,
                                                   name: ponyName,
                                                   superpower: ponySuperpower)
                    }
                } label: {
                    HStack {
                        HStack {
                            Spacer()
                            Text("Create Pony")
                                .padding(.all, 6)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .background(RoundedRectangle(cornerRadius: 8.0).foregroundColor(Color(red: 0.52, green: 0.32, blue: 0.92)))
                    }
                }
                
                Spacer()
                    .frame(width: 16.0)
                
                Button {
                    Task {
                        let ponies = await viewModel.readPonies()
                        print(ponies)
                    }
                } label: {
                    HStack {
                        HStack {
                            Spacer()
                            Text("Read Ponies")
                                .padding(.all, 6)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .background(RoundedRectangle(cornerRadius: 8.0).foregroundColor(Color(red: 0.52, green: 0.32, blue: 0.92)))
                    }
                }
            }
            
            HStack {
                Button {
                    Task {
                        await viewModel.updatePony(id: ponyID,
                                                   name: ponyName,
                                                   superpower: ponySuperpower)
                    }
                } label: {
                    HStack {
                        HStack {
                            Spacer()
                            Text("Update Pony")
                                .padding(.all, 6)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .background(RoundedRectangle(cornerRadius: 8.0).foregroundColor(Color(red: 0.42, green: 0.22, blue: 0.72)))
                    }
                }
                
                Spacer()
                    .frame(width: 16.0)
                
                Button {
                    Task {
                        await viewModel.deletePony(id: ponyID)
                    }
                } label: {
                    HStack {
                        HStack {
                            Spacer()
                            Text("Delete Pony")
                                .padding(.all, 6)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .background(RoundedRectangle(cornerRadius: 8.0).foregroundColor(Color(red: 0.22, green: 0.32, blue: 0.98)))
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
