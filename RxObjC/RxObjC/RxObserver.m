//
//  Observer.m
//  RxObjC
//
//  Created by Krunoslav Zaher on 7/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import "RXObserver.h"

@interface RXObserver()

@property (nonatomic, copy) ObserverOnNext onNextBlock;
@property (nonatomic, copy) ObserverOnError onErrorBlock;
@property (nonatomic, copy) ObserverOnCompleted onCompletedBlock;

@end

@implementation RXObserver

-(void)onNext:(id)element {
    self.onNextBlock(element);
}

-(void)onError:(NSError *)error {
    self.onErrorBlock(error);
}

-(void)onCompleted {
    self.onCompletedBlock();
}
+(instancetype)observerWithOnNext:(void (^)(id))onNext
                          onError:(ObserverOnError)onError
                      onCompleted:(ObserverOnCompleted)onCompleted {
    RXObserver *observer = [[self alloc] init];

    if (!observer) return nil;
    
    observer.onNextBlock = onNext;
    observer.onErrorBlock = onError;
    observer.onCompletedBlock = onCompleted;
    
    return observer;
}

@end
