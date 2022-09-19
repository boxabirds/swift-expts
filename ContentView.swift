//
//  ContentView.swift
//  Tutorial 1
//
//  Created by Julian Harris on 18/09/2022.
//

import SwiftUI


// List requires its rows to be Identifiable so they can be referenced efficiently… I think
struct ArticleLine: Identifiable {
    let id = UUID()
    var text:String
    
    enum State {
        case PENDING_CONTENT
        case CONTENT_LOADED
    }
    var state: State = State.PENDING_CONTENT
}

class ArticleLineObservable: ObservableObject{
    @Published var lines:[ArticleLine] = []
}

struct ContentView: View {
    @StateObject var alo = ArticleLineObservable()

    var body: some View {
        // from https://www.hackingwithswift.com/quick-start/swiftui/how-to-scroll-to-a-specific-row-in-a-list
        ScrollViewReader { proxy in
            VStack {
                Text( "Demo of scrolling inconsistencies between adding items and resizing existing items")
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
                Button( "Jump to middle -- doesn't work :(") {
                    // TODO print isn't going to console don't know why
                    print("jumped to position \(alo.lines.count)")
                    
                    // TODO This isn't working -- it worked before why not now TBD
                    proxy.scrollTo(alo.lines.count / 2, anchor:.center)
                }
                Spacer()
                Button( "Add items") {
                    print( "adding new items \(alo.lines.count+1)")
                    for _ in 1...50 {
                        // Problem: how do we ensure this insertion doesn't move the current list items? We don't want the user's view to be affected by programmatic / background changes to the list
                        alo.lines.insert( ArticleLine(text:"New item \(alo.lines.count+1)"), at:0 )
                    }
                }
                Spacer()
                Button( "Resize items") {
                    print( "triggering resize of some items -- scroll view is preserved")
                    for i in 0 ..< alo.lines.count {
                        if alo.lines[i].state == ArticleLine.State.PENDING_CONTENT {
                            alo.lines[i].state = ArticleLine.State.CONTENT_LOADED
                            break
                        }
                    }
                }
                
                // https://www.swiftbysundell.com/articles/bindable-swiftui-list-elements/ -- nested bindings magic
                List {
                    ForEach($alo.lines) { $line in
                        ArticleLineView(line:$line)
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


struct ArticleLineView: View {
    @Binding var line: ArticleLine
    var body: some View {
        VStack {
            HStack {
                Text(line.text)
                Spacer()
            }
            if line.state == ArticleLine.State.CONTENT_LOADED {
                Text("Content loaded")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { value in
            print( "Value = \(value)")
        }
    }
}
