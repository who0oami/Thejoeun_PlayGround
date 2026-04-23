//
//  ContentView.swift
//  ServerJsonImageList
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI
import SDWebImageSwiftUI // ****** 이걸 해와야지 쓸수 있다

struct ContentView: View {
    
    @State var movies: [MovieJSON] = []
    @State var image: UIImage?
    
    var body: some View {
        NavigationView(content: {
            List(movies, id: \.title, rowContent: {
                movie in HStack(content: {
                    WebImage(url: URL(string: movie.image))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                    
                    Text(movie.title)
                    
                    Spacer()
                })
            })
            .navigationTitle("영화 리스트") // 기본값이 오토매틱이라 올리면 바뀐다 
            .onAppear{
                let queryModel = QueryModel()
                Task{
                    movies = try await queryModel.loadData(url: URL(string: "https://zeushahn.github.io/Test/ios/movies.json")!)
                }
            }
        })
    }
}

#Preview {
    ContentView()
}
