//
//  ObjCPluginSupport.swift
//  
//
//  Created by Brandon Sneed on 3/14/23.
//

#if !os(Linux)

import Foundation
import Sovran

@objc
public protocol SEGMiddleware {
    func context(_ context: SEGContext, next: @escaping ((SEGContext) -> Void))
}

@objc
public class SEGBlockMiddlewareBase: NSObject, SEGMiddleware {
    let block: (SEGContext, @escaping (SEGContext) -> Void) -> Void
    
    public init(block: @escaping (SEGContext, @escaping (SEGContext) -> Void) -> Void) {
        self.block = block
    }
    
    public func context(_ context: SEGContext, next: @escaping ((SEGContext) -> Void)) {
        block(context, next)
    }
}

@objc(SEGPlugin)
public protocol ObjCPlugin {}

public protocol ObjCPluginShim {
    func instance() -> EventPlugin
}

internal class ObjCShimPlugin: Plugin, Subscriber {
    var type: PluginType = .enrichment
    var analytics: Analytics? = nil
    var executionBlock: ((SEGContext, (@escaping (SEGContext) -> Void)) -> Void)? = nil
    let object: SEGMiddleware?
    var shouldDrop: Bool = true
    
    init(middleware: SEGMiddleware) {
        object = middleware
        executionBlock = object?.context(_:next:)
    }
    
    required init(middleware: @escaping (SEGContext, (@escaping (SEGContext) -> Void)) -> Void) {
        object = nil
        executionBlock = middleware
    }
    
    internal func next(_ context: SEGContext) {
        shouldDrop = false
    }
    
    func execute<T>(event: T?) -> T? where T : RawEvent {
        guard let a = analytics else { return event }
        guard let event = event else { return event }
        guard let executionBlock = executionBlock else { return event }
        
        let context = SEGContext(analytics: ObjCAnalytics(wrapping: a), event: event)
        executionBlock(context, next)

        let payload = context.payload as? SEGIdentifyPayload
        let typedPayload = payload?.rawEvent as? T
        return typedPayload
    }
}

// MARK: - ObjC Plugin Functionality

@objc
extension ObjCAnalytics {
    /// This method allows you to add middleware to an Analytics instance, similar to Analytics-iOS.
    /// However, it is **strongly encouraged** that Enrichments/Plugins/Middlewares be written in swift
    /// to avoid the overhead of type conversion back and forth.  This exists solely for compatibility
    /// purposes.
    ///
    /// Example:
    ///    [self.analytics addSourceMiddleware:^NSDictionary<NSString *,id> * _Nullable(NSDictionary<NSString *,id> * _Nullable event) {
    ///        // drop all events named booya
    ///        NSString *eventType = event[@"type"];
    ///        if ([eventType isEqualToString:@"track"]) {
    ///            NSString *eventName = event[@"event"];
    ///            if ([eventName isEqualToString:@"booya"]) {
    ///                return nil;
    ///            }
    ///        }
    ///        return event;
    ///    }];
    ///
    /// - Parameter middleware: The middleware to execute at the source level.
    @objc(addSourceMiddleware:)
    public func addSourceMiddleware(middleware: SEGMiddleware) {
        analytics.add(plugin: ObjCShimPlugin(middleware: middleware))
    }
    
    /// This method allows you to add middleware to an Analytics instance, similar to Analytics-iOS.
    /// However, it is **strongly encouraged** that Enrichments/Plugins/Middlewares be written in swift
    /// to avoid the overhead of type conversion back and forth.  This exists solely for compatibility
    /// purposes.
    ///
    /// Example:
    ///    [self.analytics addDestinationMiddleware:^NSDictionary<NSString *,id> * _Nullable(NSDictionary<NSString *,id> * _Nullable event) {
    ///        // drop all events named booya on the amplitude destination
    ///        NSString *eventType = event[@"type"];
    ///        if ([eventType isEqualToString:@"track"]) {
    ///            NSString *eventName = event[@"event"];
    ///            if ([eventName isEqualToString:@"booya"]) {
    ///                return nil;
    ///            }
    ///        }
    ///        return event;
    ///    }, forKey: @"Amplitude"];
    ///
    /// - Parameters:
    ///   - middleware: The middleware to execute at the source level.
    ///   - destinationKey: A string value representing the destination.  ie: @"Amplitude"
    @objc(addDestinationMiddleware:forKey:)
    public func addDestinationMiddleware(middleware: SEGMiddleware, destinationKey: String) {
        // couldn't find the destination they wanted
        guard let dest = analytics.find(key: destinationKey) else { return }
        _ = dest.add(plugin: ObjCShimPlugin(middleware: middleware))
    }
    
    @objc(addPlugin:)
    public func add(plugin: ObjCPlugin) {
        guard let bouncer = plugin as? ObjCPluginShim else { return }
        let p = bouncer.instance()
        analytics.add(plugin: p)
    }
}


#endif
