//
// FeedView.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import SwiftUI

struct FeedView: View {
    @Bindable var viewModel: FeedViewModel

    var body: some View {
        ZStack {
            feedScrollView

            VStack(spacing: 0) {
                LinearGradient(
                    colors: [.black.opacity(0.55), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: AppTheme.topGradientHeight)
                Spacer()
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack {
                FeedHeaderView()
                Spacer()
            }

            HStack {
                Spacer()
                PageIndicatorView(count: viewModel.items.count, activeIndex: viewModel.activeIndex)
                    .padding(.trailing, 14)
            }
            .ignoresSafeArea()
        }
        .background(AppTheme.background)
        .onAppear {
            viewModel.onAppear()
        }
        .onChange(of: viewModel.activeItemID) {
            viewModel.activeItemDidChange()
        }
    }

    private var feedScrollView: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.items) { item in
                    VideoPageView(
                        item: item,
                        player: viewModel.player(for: item),
                        onRetry: { viewModel.retry(item) },
                        onSkip: {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                viewModel.skipToNext()
                            }
                        }
                    )
                    .containerRelativeFrame([.horizontal, .vertical])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $viewModel.activeItemID)
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
}
