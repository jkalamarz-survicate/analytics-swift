//
//  ObjCExtensions.swift
//  
//
//  Created by Brandon Sneed on 4/3/23.
//

#if !os(Linux)

import Foundation

@objc
public enum SEGEventType: Int {
    case track
    case identify
    case alias
    case group
    case screen
    case unknown
}

@objc
public protocol SEGPayload: NSObjectProtocol {
    var timestamp: String? { get }
    var messageId: String? { get }
    var context: [String: Any]? { get set }
    var integrations: [String: Any]? { get set }
    var anonymousId: String? { get set }
    var userId: String? { get set }
}

@objcMembers
public class SEGBasePayload: NSObject, SEGPayload {
    @nonobjc
    internal var rawEvent: RawEvent
    
    public var timestamp: String? { return rawEvent.timestamp }
    public var messageId: String? { return rawEvent.messageId }

    public var context: [String: Any]? {
        get { return rawEvent.context?.dictionaryValue }
        set(value) { rawEvent.context = try? JSON(nilOrObject: value) }
    }
    public var integrations: [String: Any]? {
        get { return rawEvent.integrations?.dictionaryValue }
        set(value) { rawEvent.integrations = try? JSON(nilOrObject: value) }
        
    }
    public var anonymousId: String? {
        get { return rawEvent.anonymousId }
        set(value) { rawEvent.anonymousId = value }
    }
    public var userId: String? {
        get { return rawEvent.userId }
        set(value) { rawEvent.userId = value }
    }
    
    public required init(rawEvent: RawEvent) {
        self.rawEvent = rawEvent
    }
}

@objcMembers
public class SEGTrackPayload: SEGBasePayload {
    internal var trackEvent: TrackEvent? {
        get { return rawEvent as? TrackEvent }
        set(value) {
            guard let v = value else { return }
            rawEvent = v
        }
    }
    
    public var event: String? {
        get {
            return trackEvent?.event
        }
        set(value) {
            guard let v = value else { return }
            trackEvent?.event = v
        }
    }
    
    public var properties: [String: Any]? {
        get {
            return trackEvent?.properties?.dictionaryValue
        }
        set(value) {
            trackEvent?.properties = try? JSON(nilOrObject: value)
        }
    }
    
    public convenience init(event: String, properties: [String: Any]?, context: [String: Any], integrations: [String: Any]) {
        var trackEvent = TrackEvent(event: event, properties: try? JSON(nilOrObject: properties))
        trackEvent.context = try? JSON(context)
        trackEvent.integrations = try? JSON(integrations)
        self.init(rawEvent: trackEvent)
    }
    
    public required init(rawEvent: RawEvent) {
        super.init(rawEvent: rawEvent)
    }
}

@objcMembers
public class SEGIdentifyPayload: SEGBasePayload {
    internal var identifyEvent: IdentifyEvent? {
        get { return rawEvent as? IdentifyEvent }
        set(value) {
            guard let v = value else { return }
            rawEvent = v
        }
    }
    
    public var traits: [String: Any]? {
        get {
            return identifyEvent?.traits?.dictionaryValue
        }
        set(value) {
            identifyEvent?.traits = try? JSON(nilOrObject: value)
        }
    }
    
    public convenience init(userId: String, anonymousId: String?, traits: [String: Any]?, context: [String: Any], integrations: [String: Any]) {
        var identifyEvent = IdentifyEvent(userId: userId, traits: try? JSON(nilOrObject: traits))
        identifyEvent.context = try? JSON(context)
        identifyEvent.integrations = try? JSON(integrations)
        identifyEvent.anonymousId = anonymousId
        
        self.init(rawEvent: identifyEvent)
    }
    
    public required init(rawEvent: RawEvent) {
        super.init(rawEvent: rawEvent)
    }
}

@objcMembers
public class SEGScreenPayload: SEGBasePayload {
    internal var screenEvent: ScreenEvent? {
        get { return rawEvent as? ScreenEvent }
        set(value) {
            guard let v = value else { return }
            rawEvent = v
        }
    }
    
    public var properties: [String: Any]? {
        get {
            return screenEvent?.properties?.dictionaryValue
        }
        set(value) {
            screenEvent?.properties = try? JSON(nilOrObject: value)
        }
    }
    
    public convenience init(name: String, category: String?, properties: [String: Any]?, context: [String: Any], integrations: [String: Any]) {
        var screenEvent = ScreenEvent(title: name, category: category, properties: try? JSON(nilOrObject: properties))
        screenEvent.context = try? JSON(context)
        screenEvent.integrations = try? JSON(integrations)
        
        self.init(rawEvent: screenEvent)
    }
    
    public required init(rawEvent: RawEvent) {
        super.init(rawEvent: rawEvent)
    }
}

@objcMembers
public class SEGGroupPayload: SEGBasePayload {
    internal var groupEvent: GroupEvent? {
        get { return rawEvent as? GroupEvent }
        set(value) {
            guard let v = value else { return }
            rawEvent = v
        }
    }
    
    public var groupId: String? {
        get {
            return groupEvent?.groupId
        }
        set(value) {
            guard let v = value else { return }
            groupEvent?.groupId = v
        }
    }

    public var traits: [String: Any]? {
        get {
            return groupEvent?.traits?.dictionaryValue
        }
        set(value) {
            groupEvent?.traits = try? JSON(nilOrObject: value)
        }
    }
    
    public convenience init(groupId: String, traits: [String: Any]?, context: [String: Any], integrations: [String: Any]) {
        var groupEvent = GroupEvent(groupId: groupId, traits: try? JSON(nilOrObject: traits))
        groupEvent.context = try? JSON(context)
        groupEvent.integrations = try? JSON(integrations)
        
        self.init(rawEvent: groupEvent)
    }
    
    public required init(rawEvent: RawEvent) {
        super.init(rawEvent: rawEvent)
    }
}

@objcMembers
public class SEGAliasPayload: SEGBasePayload {
    internal var aliasEvent: AliasEvent? {
        get { return rawEvent as? AliasEvent }
        set(value) {
            guard let v = value else { return }
            rawEvent = v
        }
    }
    
    public var theNewId: String? {
        get {
            return aliasEvent?.userId
        }
        set(value) {
            guard let v = value else { return }
            aliasEvent?.userId = v
        }
    }
    
    public convenience init(newId: String, context: [String: Any], integrations: [String: Any]) {
        var aliasEvent = AliasEvent(newId: newId)
        aliasEvent.context = try? JSON(context)
        aliasEvent.integrations = try? JSON(integrations)
        
        self.init(rawEvent: aliasEvent)
    }
    
    public required init(rawEvent: RawEvent) {
        super.init(rawEvent: rawEvent)
    }
}


@objcMembers
public class SEGContext: NSObject {
    public let _analytics: ObjCAnalytics
    public let debug: Bool
    
    public var payload: SEGPayload

    public var eventType: SEGEventType {
        return .unknown
    }
    
    public var userId: String? { return payload.userId }
    
    public var anonymousId: String? { return payload.anonymousId }
    public var error: NSError? { return nil }
    
    init(analytics: ObjCAnalytics, event: RawEvent) {
        _analytics = analytics
        #if DEBUG
        debug = true
        #endif
        
        switch event {
        case is TrackEvent:
            payload = SEGTrackPayload(rawEvent: event)
        case is IdentifyEvent:
            payload = SEGIdentifyPayload(rawEvent: event)
        case is ScreenEvent:
            payload = SEGScreenPayload(rawEvent: event)
        case is GroupEvent:
            payload = SEGGroupPayload(rawEvent: event)
        case is AliasEvent:
            payload = SEGAliasPayload(rawEvent: event)
        default:
            payload = SEGBasePayload(rawEvent: event)
        }
    }
    
    @objc(modify:)
    @discardableResult
    public func modify(_ closure: (SEGContext) -> Void) -> SEGContext {
        closure(self)
        return self
    }
}

#endif
