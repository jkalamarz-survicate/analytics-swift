//
//  ObjCHelper.m
//  
//
//  Created by Brandon Sneed on 4/16/23.
//

#import "ObjCHelper.h"

@implementation SEGBlockMiddleware

- (instancetype)initWithBlock:(SEGMiddlewareBlock)block
{
    if (self = [super init]) {
        _block = block;
    }
    return self;
}

- (void)context:(SEGContext *)context next:(__attribute__((noescape)) SEGMiddlewareNext)next
{
    self.block(context, next);
}

@end
