import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView {
                    ContestListView()
                        .tabItem {
                            Label("Contests", systemImage: "calendar")
                        }

                    ProblemListView()
                        .tabItem {
                            Label("Problems", systemImage: "list.bullet")
                        }

                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                }
                .accentColor(.neonBlue) 
                .preferredColorScheme(.dark)
                .background(Color.clear)
                
    }
}
#Preview {
    ContentView()
}
