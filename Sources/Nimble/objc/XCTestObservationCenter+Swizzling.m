//
//  XCTestObservationCenter+Swizzling.m
//  Test
//  Copied from https://git.yopeso.com/iOS/Swetler/blob/a1504f450862bdb1aea27b8990618b426ce240b2/IntegrationTests/SwetlerTestsPrettyPrinting/TXCCleanReporter/XCTestObservationCenter+Swizzling.m
//
//  Created by Andrei Raifura on 9/9/15.
//  Copyright © 2015 thelvis. All rights reserved.
//

#import "XCTestObservationCenter+Swizzling.h"
#import <objc/runtime.h>

#pragma mark - Private

@interface XCTestObservationCenter (Private)
- (void)_addLegacyTestObserver:(id)arg1;
@end

#pragma mark - XCTestObservationCenter

@implementation XCTestObservationCenter (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        [self swizzleSelector:@selector(addTestObserver:) withSelector:@selector(xxx_addTestObserver:)];
        [self swizzleSelector:@selector(_addLegacyTestObserver:) withSelector:@selector(xxx__addLegacyTestObserver:)];
    });
}

#pragma mark - Method Swizzling

+ (void)swizzleSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector {
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)xxx_addTestObserver:(id <XCTestObservation>)testObserver {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self listTestObservers];
//    });

    // XCTestLog
    // _XCTestDriverTestObserver

//    if (![testObserver isKindOfClass:NSClassFromString(@"XCTestLog")]) {
//        [self xxx_addTestObserver:testObserver];
//    }

    // Nimble.CurrentTestCaseTracker
    // _TtC6Nimble22CurrentTestCaseTracker

    [self xxx_addTestObserver:testObserver];
}

- (void)xxx__addLegacyTestObserver:(id <XCTestObservation>)testObserver {
    [self xxx__addLegacyTestObserver:testObserver];
}

- (void)listTestObservers {
    SEL aSelector = NSSelectorFromString(@"observers");
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];

    [invocation setTarget:self];
    [invocation setSelector:aSelector];

    [invocation invoke];
    NSSet *returnValue = [NSSet set];
    [invocation getReturnValue:&returnValue];

    NSArray *observers = [returnValue allObjects];

    for (id object in observers) {
//        if ([object isKindOfClass:NSClassFromString(@"XCTestLog")]) {
//            [[XCTestObservationCenter sharedTestObservationCenter] removeTestObserver:object];
//        }
        NSLog(@"%@", object);
    }
}

@end