//
//  HomeView.swift
//  CryptoTracker
//
//  Created by Tegar Marino on 26/05/23.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var vm: HomeViewModel
    @State private var showPortfolio: Bool = false // Animate right
    @State private var showPortfolioView: Bool = false // New sheet
    @State private var showSettingView: Bool = false // Setting
    
    @State private var showNews: Bool = false
    @State private var showHome: Bool = false
    
    @State private var selectedCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false
    
    var body: some View {
        ZStack{
//            Background layer
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showPortfolioView, content: {
                    PortfolioView()
                        .environmentObject(vm)
                })
             
//            Content layer
            VStack {
    // homeHeader
                        
                if showPortfolio && !showHome {
                    Text("Portfolio")
                        .font(.headline)
                        .foregroundColor(Color.theme.accent)
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                    HomeStatsView(showPortfolio: $showPortfolio)
                    SearchBarView(searchText: $vm.searchText)
                    HStack{
                        if showPortfolio{
                            Button(action: {
                                showPortfolioView.toggle()
                            }, label: {
                                Text("Add new portfolio")
                                    .font(.headline)
                                    .foregroundColor(Color.theme.blue)
                            })
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0))
                    columnTitles
                    portfolioCoinList
                        .transition(.move(edge: .trailing))
                    
                } else if showHome || !showNews{
                    Text("Live crypto price")
                        .font(.headline)
                        .foregroundColor(Color.theme.accent)
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                    HomeStatsView(showPortfolio: $showPortfolio)
                    SearchBarView(searchText: $vm.searchText)
                    columnTitles
                    allCoinList
                        .transition(.move(edge: .leading))
                } else if showNews {
                    Text("Crypto news")
                        .font(.headline)
                        .foregroundColor(Color.theme.accent)
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                    NewsView()
                }
                        
                Spacer(minLength: 0)
                navigationBar
            }
            .sheet(isPresented: $showSettingView, content: {
                SettingView()
            })
        }
        .background(
            NavigationLink(
                destination: DetailLoadingView(coin: $selectedCoin),
                isActive: $showDetailView,
                label: {EmptyView()}
            )
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            HomeView()
                .navigationBarHidden(true)
        }
        .environmentObject(dev.homeVM)
    }
}

extension HomeView{
    
    private var navigationBar: some View{
        HStack{
            NavigationButtonView(iconName: "chart.bar")
                .animation(.none)
                .onTapGesture {
//                    if showPortfolio{
//                        showPortfolioView.toggle()
//                    } else {
//                        showSettingView.toggle()
//                    }
                    showHome = true
                    if showHome{
                        showPortfolio = false
                        showNews = false
                    }
                }
            Spacer()
            NavigationButtonView(iconName: "bitcoinsign.circle")
                .animation(.none)
                .onTapGesture {
                    showPortfolio = true
                    if showPortfolio{
                        showHome = false
                        showNews = false
                    }
                }
            Spacer()
            NavigationButtonView(iconName: "newspaper")
                .animation(.none)
                .onTapGesture {
                    showNews = true
                    if showNews {
                        showHome = false
                        showPortfolio = false
                    }
                }
        }
        .padding(.horizontal, 40)
    }
    
    private var homeHeader: some View{
        HStack{
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(.none)
                .onTapGesture {
                    if showPortfolio{
                        showPortfolioView.toggle()
                    } else {
                        showSettingView.toggle()
                    }
                }
                .background(
                    CircleButtonAnimationView(animate: $showPortfolio)
                )
            Spacer()
            Text(showPortfolio ? "Portfolio" : "Live price")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()){
                        showPortfolio.toggle()
                    }
                }
        }
        .padding(.horizontal)
    }
    
    private var allCoinList: some View{
        List{
            ForEach(vm.allCoins) { coin in
                CoinRowView(coin: coin, showHoldingColumn: false)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
                    .onTapGesture {
                        segue(coin: coin)
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var portfolioCoinList: some View{
        List{
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
                    .onTapGesture {
                        segue(coin: coin)
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func segue(coin: CoinModel){
        selectedCoin = coin
        showDetailView.toggle()
    }
    
    private var columnTitles: some View{
        HStack{
            HStack(spacing: 4){
                Text("Coin")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .rank || vm.sortOption == .rankReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .rank ? 0 : 180))
            }
            .onTapGesture {
                withAnimation(.default){
                    vm.sortOption = vm.sortOption == .rank ? .rankReversed : .rank
                }
//                if vm.sortOption == .rank{
//                    vm.sortOption = .rankReversed
//                } else {
//                    vm.sortOption = .rank
//                }
            }
            Spacer()
            if showPortfolio{
                HStack(spacing: 4){
                    Text("Holdings")
                    Image(systemName: "chevron.down")
                        .opacity((vm.sortOption == .holdings || vm.sortOption == .holdingReversed) ? 1.0 : 0.0)
                        .rotationEffect(Angle(degrees: vm.sortOption == .holdings ? 0 : 180))
                }
                .onTapGesture {
                    withAnimation(.default){
                        vm.sortOption = vm.sortOption == .holdings ? .holdingReversed : .holdings
                    }
                }
            }
            HStack(spacing: 4){
                Text("Price")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .price || vm.sortOption == .priceReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .price ? 0 : 180))
            }
            .frame(width: UIScreen.main.bounds.width/3.5, alignment: .trailing)
            .onTapGesture {
                withAnimation(.default){
                    vm.sortOption = vm.sortOption == .price ? .priceReversed : .price
                }
            }
            
            Button(action: {
                withAnimation(.linear(duration: 2.0)) {
                    vm.reloadData()
                }
            }, label: {
                Image(systemName: "goforward")
            })
            .rotationEffect(Angle(degrees: vm.isLoading ? 360 : 0), anchor: .center)
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .padding(.horizontal)
    }
}
