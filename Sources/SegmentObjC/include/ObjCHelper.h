//
//  ObjCHelper.h
//  
//
//  Created by Brandon Sneed on 4/16/23.
//

#import <Foundation/Foundation.h>

@import Segment;

typedef SEGContext SEGMutableContext;

typedef void (^SEGMiddlewareNext)(SEGContext *_Nullable newContext);

typedef void (^SEGMiddlewareBlock)(SEGContext *_Nonnull context, SEGMiddlewareNext _Nonnull next);

@interface SEGBlockMiddleware : NSObject <SEGMiddleware>
@property (nonnull, nonatomic, readonly) SEGMiddlewareBlock block;
- (instancetype _Nonnull)initWithBlock:(SEGMiddlewareBlock _Nonnull)block;
@end

