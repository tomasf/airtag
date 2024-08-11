import Foundation
import SwiftSCAD
import AirTag

struct SnapInHolder: Shape3D {
    static let chamferSize = 1.2
    static let wallThickness = 2.0
    static let outerDiameter = AirTag.radius * 2 + wallThickness * 2

    static let tabHeight = 1.8
    static let fullHeight = AirTag.widestPointZ - AirTag.sideBottomZ + tabHeight

    let attachment: any Geometry3D

    init(@UnionBuilder3D attachment: () -> any Geometry3D) {
        self.attachment = attachment()
    }

    init() {
        self.init {}
    }

    var body: Geometry3D {
        Circle(diameter: Self.outerDiameter)
            .extruded(height: Self.fullHeight, topEdge: .chamfer(size: Self.chamferSize), bottomEdge: .chamfer(size: Self.chamferSize), method: .convexHull)
            .subtracting {
                // Snap tabs
                let splitWidth = 17.0
                let splitCount = 3
                let splitSlopeLength = 2.0

                Rectangle([Self.outerDiameter, splitWidth])
                    .aligned(at: .centerY)
                    .extruded(
                        height: Self.tabHeight + 0.001,
                        bottomEdge: .chamfer(width: splitSlopeLength, height: Self.tabHeight),
                        method: .convexHull
                    )
                    .repeated(around: .z, count: splitCount)
                    .translated(z: Self.fullHeight - Self.tabHeight)
            }
            .adding(attachment)
            .subtracting {
                AirTag()
                    .translated(z: -AirTag.sideBottomZ)
            }
    }
}

struct SnapInHolderWithLoop: Shape3D {
    var body: Geometry3D {
        let innerSize = Vector2D(x: 4.0, y: 20.5)
        let thickness = 3.0
        let width = 4.0
        let cornerRadius = 5.0
        let layerThickness = 0.1

        SnapInHolder {
            let outerShape = Rectangle(
                x: innerSize.x + width + SnapInHolder.outerDiameter / 2,
                y: innerSize.y + 2 * width
            )
            .aligned(at: .centerY)
            .roundingRectangleCorners(radius: cornerRadius)

            outerShape
                .subtracting {
                    outerShape.offset(amount: -width, style: .round)
                }
                .extruded(
                    height: thickness,
                    topEdge: .chamfer(size: SnapInHolder.chamferSize),
                    bottomEdge: .chamfer(size: SnapInHolder.chamferSize),
                    method: .layered(height: layerThickness)
                )
        }
    }
}

struct SnapInHolderWithRing: Shape3D {
    var body: Geometry3D {
        let thickness = 3.0
        let width = 3.0
        let innerDiameter = 5.0
        let outerDiameter = innerDiameter + width * 2
        let layerThickness = 0.1

        SnapInHolder {
            let outerShape = Circle(diameter: outerDiameter)
                .translated(x: -SnapInHolder.outerDiameter / 2 - innerDiameter / 2)

            outerShape
                .subtracting {
                    outerShape.offset(amount: -width, style: .round)
                }
                .extruded(
                    height: thickness,
                    topEdge: .chamfer(size: SnapInHolder.chamferSize),
                    bottomEdge: .chamfer(size: SnapInHolder.chamferSize),
                    method: .layered(height: layerThickness)
                )
        }
    }
}

save(environment: .defaultEnvironment.withTolerance(0.25)) {
    SnapInHolder()
        .named("airtag-snap")

    SnapInHolderWithLoop()
        .named("airtag-snap-loop")

    SnapInHolderWithRing()
        .named("airtag-snap-ring")
}
