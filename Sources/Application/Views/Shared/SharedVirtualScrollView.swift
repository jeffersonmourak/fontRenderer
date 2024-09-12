//
//  SharedVirtualScrollView.swift
//
// 
//  Created by JadenGeller. https://gist.github.com/JadenGeller/0b1fe76ab0406dbd6564fa27549b50a0
//

import Foundation
import SwiftUI


struct SharedVirtualScrollView<Content: View>: View {
    var axes: Axis.Set = .vertical
    var showsIndicators: Bool = true
    var alignment: Alignment = .topLeading
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    @ViewBuilder var content: (
        CGRect
    ) -> Content
    
    var body: some View {
        GeometryReader { outerGeometry in
            ScrollView(
                axes,
                showsIndicators: showsIndicators
            ) {
                GeometryReader { innerGeometry in
                    let origin = innerGeometry
                        .frame(
                            in: .named(
                                "outer"
                            )
                        )
                        .origin
                        .applying(
                            ProjectionTransform(
                                .init(
                                    scaleX: -1,
                                    y: -1
                                )
                            )
                        )
                    ZStack {
                        content(
                            CGRect(
                                origin: origin,
                                size: outerGeometry.size
                            )
                        )
                    }
                    .frame(
                        width: outerGeometry.size.width,
                        height: outerGeometry.size.height,
                        alignment: alignment
                    )
                    .offset(
                        x: origin.x,
                        y: origin.y
                    )
                }
                .frame(
                    width: width,
                    height: height
                )
            }
            .coordinateSpace(
                name: "outer"
            )
        }
    }
}
