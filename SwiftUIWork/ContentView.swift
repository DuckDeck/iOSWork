//
//  ContentView.swift
//  SwiftUIWork
//
//  Created by Stan Hu on 2021/10/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            List{
                NavigationLink("Spirograph",destination:SpirographView())
            }.navigationBarTitle(Text("菜单"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
