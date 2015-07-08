//
//  TestProofOfConteptOfRxObjC.m
//  RxObjC
//
//  Created by Krunoslav Zaher on 7/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RxObjc/RxObjc.h>

@interface TestProofOfConteptOfRxObjC : XCTestCase

@end

@implementation TestProofOfConteptOfRxObjC

- (void)testExample {
    RXObservable *observable = [RXObservable createObservable:^RXDisposable *(RXObserver *observer) {
        
        NSLog(@"Subscribed %@", observer);
        [observer onNext:@(0)];
        [observer onNext:@(1)];
        [observer onCompleted];
        
        return [RXDisposable disposableWithDisposeBlock:^{
            
        }];
    }];
    
    observable.map(^NSNumber*(NSNumber *number) {
        return @(number.integerValue + 1);
    })
    .filter(^BOOL(NSNumber *number) {
        return number.integerValue > 0;
    })
    .subscribeNext(^(NSNumber *number) {
        NSLog(@"Element: %@", number);
    });
}
@end
