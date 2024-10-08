//
//  SetGameView.swift
//  Set game
//
//  Created by ezz on 02/09/2024.
//
import SwiftUI

struct SetGameView: View {
    @ObservedObject var viewModel = ShapeSetGame()
    @Namespace private var cardAnimation
    var body: some View {
        VStack {
            AspectVGrid(viewModel.presentCards, aspectRatio: 2/3) { card in
                CardView(card: card, isSelected: card.isSelected).matchedGeometryEffect(id: card.id, in: cardAnimation)
                    .onTapGesture {
                        withAnimation{
                            viewModel.selectCard(card)
                        }
                    }
                    .padding(5)
            }
            .padding()
            HStack{
                deck
                Spacer()
                Text("cards left:\(viewModel.deck.count)").animation(nil)
                Spacer()
                discardedCards
            }.padding()

            HStack {
                Button("New Game") {
                    withAnimation(.bouncy){
                        viewModel.startNewGame()
                    }
                }
                Spacer()
                Button("shuffle") {
                    withAnimation(.bouncy){
                        viewModel.shuffle()
                    }
                }.disabled(viewModel.presentCards.count == 0)
            }
            .padding()
        }
    }
    @ViewBuilder
    var deck: some View {
        if !viewModel.isEmptyDeck{
            makeStack(viewModel.deck).overlay{
                RoundedRectangle(cornerRadius: 10).fill(.blue).frame(width: 40,height: 60)
                Text("+3").bold().colorInvert()
            }.onTapGesture {
                withAnimation(.bouncy){
                    viewModel.draw3Cards()
                }
            }
        }
    }
    
@ViewBuilder var discardedCards: some View {
        if viewModel.discardedCards.count > 0 {
            makeStack(viewModel.discardedCards, isDiscarded: true)
        }
    }
    
    
    func makeStack(_ cards: [SetGame.Card], isDiscarded: Bool = false) -> some View {
        ZStack {
            ForEach(cards) { card in
                CardView(card: card, isDiscarded: isDiscarded, isSelected: card.isSelected)
                    .matchedGeometryEffect(id: card.id, in: cardAnimation)
            }
            .frame(width: 40, height: 60)
        }
    }
}

struct CardView: View {
    var card: SetGame.Card
    var isDiscarded = false
    var isSelected : Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(Color.white)
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected && !isDiscarded ? Color.blue : Color.black, lineWidth: isSelected && !isDiscarded ? 6 : 1)
            VStack {
                ForEach(0..<card.numberOfShapes, id: \.self) { _ in
                    shapeFor(card)
                        .aspectRatio(2, contentMode: .fit)
                }
            }
            .padding()
        }
        .aspectRatio(2/3, contentMode: .fit)
    }
    
    @ViewBuilder
    func shapeFor(_ card: SetGame.Card) -> some View {
        let colorr = Color(colorFor(card))
        let opacity = opacityFor(card)
        switch card.shape {
        case .rectangle:
            Rectangle().stroke(colorr,lineWidth: 5).fill(.white).overlay(Rectangle().stroke(colorr).fill(colorr).opacity(opacity))
        case .oval:
            Capsule().stroke(colorr,lineWidth: 5).fill(.white).overlay(Capsule().stroke(colorr).fill(colorr).opacity(opacity))
        case .diamond:
            Diamond().stroke(colorr,lineWidth: 5).fill(.white).overlay(Diamond().stroke(colorr).fill(colorr).opacity(opacity))
        }
    }
    
    func colorFor(_ card: SetGame.Card) -> Color {
        switch card.color {
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
        }
    }
    
    // Opacity based on shading
    func opacityFor(_ card: SetGame.Card) -> Double {
        switch card.shading {
        case .full:
            return 1.0
        case .transparent:
            return 0.5
        case .empty:
            return 0
        }
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))  // Top point
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))  // Right point
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))  // Bottom point
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))  // Left point
        path.closeSubpath()
        return path
    }
}





#Preview {
    SetGameView()
}
