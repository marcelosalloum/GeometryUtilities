//
//  MultiPolygonRenderer.swift
//  GeometryUtilities
//
//  Created by Lluís Ulzurrun on 20/7/16.
//  Copyright © 2016 VisualNACert. All rights reserved.
//

import MapKit

#if os(iOS)
import UIKit
public typealias Color = UIColor
#else
import AppKit
open typealias Color = NSColor
#endif

open class MultiPolygonRenderer: MKOverlayPathRenderer {

	/// Polygons to be drawn.
	fileprivate let polygons: [MKPolygon]

    /// Style information about how a multi polygon should render its shape.
    public typealias Style = (fill: Color, stroke: Color, width: CGFloat)
    
    /**
     Creates a new renderer that can render a `MultiPolygonOverlay`.
     
     - parameter multiPolygonOverlay: `MultiPolygonOverlay` to be rendered.
     - parameter normalStyle: Colors and stroke width to be used to draw polygon 
     when not selected.
     - parameter selectedStyle: Colors and stroke width to be used to draw 
     polygon when selected.
     - parameter useSimplifiedGeometry: Whether simplified geometry (bounding 
     box, `true`) or real, complex one (`false`) should be drawn.
     
     - returns: Renderer that can render given multi polygon overlay.
     */
    @available(*, introduced: 1.1.0)
    public init(
        multiPolygonOverlay: MultiPolygonOverlay,
        normalStyle: Style,
        selectedStyle: Style,
        useSimplifiedGeometry: Bool = false
    ) {
        
        if useSimplifiedGeometry {
            self.polygons = [multiPolygonOverlay.simplifiedPolygon]
        } else {
            self.polygons = multiPolygonOverlay.polygons
        }
        
        super.init(overlay: multiPolygonOverlay)
        
        // TODO: Move this display settings to a proxy object so they can be easily changed or themed
        let style = (multiPolygonOverlay.selected) ? selectedStyle : normalStyle
        
        self.fillColor = style.fill
        self.strokeColor = style.stroke
        self.lineWidth = style.width
        
    }
    
	/**
	 Creates a new renderer that can render a `MultiPolygonOverlay`.

	 - parameter multiPolygonOverlay: `MultiPolygonOverlay` to be rendered.
     - parameter fillColor: Color to be used to fill polygon.
     - parameter strokeColor: Color to be used to stroke polygon.
     - parameter selectedFillColor: Color to be used to fill polygon when
     selected.
     - parameter selectedStrokeColor: Color to be used to stroke polygon when
     selected.
	 - parameter useSimplifiedGeometry: Whether simplified geometry should be
	 used (`true`) or real, complex one (`false`).

	 - returns: Renderer that can render given multi polygon overlay.
	 */
    @available(*, deprecated: 1.1.0, renamed: "init(multiPolygonOverlay:normalStyle:selectedStyle:useSimplifiedGeometry:)")
	public convenience init(
		multiPolygonOverlay: MultiPolygonOverlay,
		fillColor: UIColor,
		strokeColor: UIColor,
		selectedFillColor: UIColor,
		selectedStrokeColor: UIColor,
		useSimplifiedGeometry: Bool = false
    ) {
        self.init(
            multiPolygonOverlay: multiPolygonOverlay,
            normalStyle: (
                fill: fillColor,
                stroke: strokeColor,
                width: 5.0
            ),
            selectedStyle: (
                fill: selectedFillColor,
                stroke: selectedStrokeColor,
                width: 5.0
            ),
            useSimplifiedGeometry: useSimplifiedGeometry
        )
	}

	fileprivate override init(overlay: MKOverlay) {
		self.polygons = []
		super.init(overlay: overlay)
	}

	open override func draw(
        _ mapRect: MKMapRect,
        zoomScale: MKZoomScale,
        in context: CGContext
    ) {
		// Taken from: http://stackoverflow.com/a/17673411

		for polygon in self.polygons {
            guard let path = self.polyPath(forPolygon: polygon) else { continue }
			self.applyFillProperties(to: context, atZoomScale: zoomScale)
			context.beginPath()
			context.addPath(path)
			context.drawPath(using: CGPathDrawingMode.eoFill)
			self.applyStrokeProperties(to: context, atZoomScale: zoomScale)
			context.beginPath()
			context.addPath(path)
			context.strokePath()
		}

	}

	// MARK: Public helpers

	/**
	 Returns whether given point is found inside this renderer's polygons or not.

     - note: [Source](http://stackoverflow.com/a/15235844)
     
	 - parameter point: Map point to look for.

	 - returns: `true` if point is contained in this renderer`s polygons.
	 */
    @available(*, introduced: 1.1.0)
    open func contains(point: MKMapPoint) -> Bool {
        
        let polygonViewPoint = self.point(for: point)
        for polygon in self.polygons {
            
            guard let polypath = self.polyPath(forPolygon: polygon),
                polypath.contains(polygonViewPoint) else { continue }
            
            // TODO: Check interior polygons to discard false positives
            
            return true
            
        }
        return false
    }
    /**
     Returns whether given point is found inside this renderer's polygons or not.
     
     - parameter point: Map point to look for.
     
     - returns: `true` if point is contained in this renderer`s polygons.
     */
    @available(*, deprecated: 1.1.0, renamed: "contains(point:)")
	open func containsPoint(_ point: MKMapPoint) -> Bool {
        return self.contains(point: point)
	}

}
