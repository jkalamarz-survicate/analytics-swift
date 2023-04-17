//
//  AppDelegate.m
//  ObjCExample
//
//  Created by Brandon Sneed on 8/13/21.
//

#import "AppDelegate.h"
#import "ObjCExample-Swift.h"

@import SegmentObjC;
@import SegmentMixpanel;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    SEGConfiguration *config = [[SEGConfiguration alloc] initWithWriteKey:@"<writekey>"];
    config.trackApplicationLifecycleEvents = YES;
    
    _analytics = [[SEGAnalytics alloc] initWithConfiguration: config];
    
    [self.analytics track:@"test"];
    [self.analytics track:@"testProps" properties:@{@"email": @"blah@blah.com"}];
    
    [self.analytics flush];
    
    SEGTestDestination *testDestination = [[SEGTestDestination alloc] init];
    [self.analytics addPlugin:testDestination];
    
    SEGBlockMiddleware *customizeAllTrackCalls = [[SEGBlockMiddleware alloc] initWithBlock:^(SEGContext * _Nonnull context, SEGMiddlewareNext  _Nonnull next) {
        if ([context.payload isKindOfClass:[SEGTrackPayload class]]) {
            SEGTrackPayload *track = (SEGTrackPayload *)context.payload;
            next([context modify:^(SEGMutableContext * _Nonnull ctx) {
                NSString *newEvent = [NSString stringWithFormat:@"[New] %@", track.event];
                NSMutableDictionary *newProps = (track.properties != nil) ? [track.properties mutableCopy] : [@{} mutableCopy];
                newProps[@"customAttribute"] = @"Hello";
                ctx.payload = [[SEGTrackPayload alloc] initWithEvent:newEvent
                                                          properties:newProps
                                                             context:track.context
                                                        integrations:track.integrations];
            }]);
        } else {
            next(context);
        }
    }];
    
    [self.analytics addSourceMiddleware: customizeAllTrackCalls];
    
        
    /*
    [self.analytics addSourceMiddleware:^NSDictionary<NSString *,id> * _Nullable(NSDictionary<NSString *,id> * _Nullable event) {
        NSMutableDictionary<NSString *, id> *newEvent = [event mutableCopy];
        if (event.seg_eventType == SEGEventTypeTrack) {
            newEvent[@"event"] = [NSString stringWithFormat:@"[New] \%@", event[@"event"]];
            NSMutableDictionary *newProps = ([event[@"properties"] mutableCopy] ?: [NSMutableDictionary new]);
            newProps[@"customAttribute"] = @"Hello";
            newEvent[@"properties"] = newProps;
        }
        return newEvent;
    }];
    
    [self.analytics addDestinationMiddleware:^NSDictionary<NSString *,id> * _Nullable(NSDictionary<NSString *,id> * _Nullable event) {
        NSMutableDictionary<NSString *, id> *newEvent = [event mutableCopy];
        if (event.seg_eventType == SEGEventTypeTrack) {
            newEvent[@"event"] = [NSString stringWithFormat:@"[Amplitude] \%@", event[@"event"]];
            NSMutableDictionary *newProps = ([event[@"properties"] mutableCopy] ?: [NSMutableDictionary new]);
            newProps[@"customAttribute"] = @"Hello";
            newEvent[@"properties"] = newProps;
        }
        return newEvent;
    } forKey: @"Amplitude"];*/
    
    //[self.analytics addDestination:[[SEGMixpanelDestination alloc] init]];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.analytics track:@"booya"];
    });
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
