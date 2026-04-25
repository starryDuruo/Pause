//
//  draft.swift
//  Pause
//
//  Created by Wang Sige on 4/19/26.
//

import SwiftUI

struct draft: View {
    var body: some View {
        ZStack{
            Color.theme
                .ignoresSafeArea()
            VStack{
                Image(systemName: "book.pages")
                Image(systemName: "pencil.and.list.clipboard")
                Image(systemName: "clock.arrow.circlepath")
                Image(systemName: "list.bullet.indent")
                Image(systemName: "heart.text.square")
                Image(systemName: "sparkles")
                Image(systemName: "archivebox")
            }
        }
    }
}

#Preview {
    draft()
}
