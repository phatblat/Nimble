#import "CurrentTestCaseTracker.h"
#import <XCTest/XCTest.h>
#import <objc/runtime.h>

#pragma mark - Private

@interface XCTestObservationCenter (Private)
- (void)_addLegacyTestObserver:(id)observer;
- (void)Nimble_original_addTestObserver:(id<XCTestObservation>)observer;
- (void)Nimble_original__addLegacyTestObserver:(id)observer;
@end

@implementation XCTestObservationCenter (Swizzling)

#pragma mark - Method Swizzling

+ (void)load {
//    [self swizzleSelector:@selector(addTestObserver:) withSelector:@selector(xxx_addTestObserver:)];
//    [self swizzleSelector:@selector(_addLegacyTestObserver:) withSelector:@selector(xxx__addLegacyTestObserver:)];

    // Swizzle -_addLegacyTestObserver:
    Method addLegacyTestObserverMethod = class_getInstanceMethod(self, @selector(_addLegacyTestObserver:));
    if (addLegacyTestObserverMethod) {
        class_addMethod(self, @selector(Nimble_original__addLegacyTestObserver:), method_getImplementation(addLegacyTestObserverMethod), method_getTypeEncoding(addLegacyTestObserverMethod));

        IMP newAddLegacyTestObserverImp = imp_implementationWithBlock(^void(id self, id observer){
            [self Nimble_original__addLegacyTestObserver:observer];
            // Only add CurrentTestCaseTracker once `XCTestLog` has been added
            [self addTestObserver:[CurrentTestCaseTracker sharedInstance]];
        });
        class_replaceMethod(self, @selector(_addLegacyTestObserver:), newAddLegacyTestObserverImp, method_getTypeEncoding(addLegacyTestObserverMethod));
    } else {
        // Swizzle -addTestObserver:, only if -_addLegacyTestObserver: is not implemented
        Method addTestObserverMethod = class_getInstanceMethod(self, @selector(addTestObserver:));
        class_addMethod(self, @selector(Nimble_original_addTestObserver:), method_getImplementation(addTestObserverMethod), method_getTypeEncoding(addTestObserverMethod));

        IMP newAddTestObserverImp = imp_implementationWithBlock(^void(id self, id observer){
            [self Nimble_original_addTestObserver:observer];
            // Only add CurrentTestCaseTracker once `XCTestLog` has been added
            [self addTestObserver:[CurrentTestCaseTracker sharedInstance]];
        });
        class_replaceMethod(self, @selector(addTestObserver:), newAddTestObserverImp, method_getTypeEncoding(addTestObserverMethod));
    }
}

//+ (void)swizzleSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector {
//    Class class = [self class];
//    Method originalMethod = class_getInstanceMethod(class, originalSelector);
//    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//
//    BOOL didAddMethod =
//    class_addMethod(class,
//                    originalSelector,
//                    method_getImplementation(swizzledMethod),
//                    method_getTypeEncoding(swizzledMethod));
//
//    if (didAddMethod) {
//        class_replaceMethod(class,
//                            swizzledSelector,
//                            method_getImplementation(originalMethod),
//                            method_getTypeEncoding(originalMethod));
//    } else {
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//}
//
//- (void)xxx_addTestObserver:(id <XCTestObservation>)testObserver {
//    //    static dispatch_once_t onceToken;
//    //    dispatch_once(&onceToken, ^{
//    //        [self listTestObservers];
//    //    });
//
//    // XCTestLog
//    // _XCTestDriverTestObserver
//
//    //    if (![testObserver isKindOfClass:NSClassFromString(@"_XCTestDriverTestObserver")]) {
//    //        [self xxx_addTestObserver:testObserver];
//    //    }
//
//    // Nimble.CurrentTestCaseTracker
//    // _TtC6Nimble22CurrentTestCaseTracker
//
//    [self xxx_addTestObserver:testObserver];
//}
//
//- (void)xxx__addLegacyTestObserver:(id <XCTestObservation>)testObserver {
//    [self xxx__addLegacyTestObserver:testObserver];
//
//}

@end
