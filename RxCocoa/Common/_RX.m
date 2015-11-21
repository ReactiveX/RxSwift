//
//  _RX.m
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#import "_RX.h"

// self + cmd
#define HIDDEN_ARGUMENT_COUNT   2

// inspired by https://github.com/ReactiveCocoa/ReactiveCocoa/blob/swift-development/ReactiveCocoa/Objective-C/NSInvocation%2BRACTypeParsing.m
// awesome work
id __nonnull RX_extract_argument_at_index(NSInvocation * __nonnull invocation, NSUInteger index) {
    const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:index];
    
#define RETURN_VALUE(type) \
    else if (strcmp(argumentType, @encode(type)) == 0) {\
        type val = 0; \
        [invocation getArgument:&val atIndex:index]; \
        return @(val); \
    }

    // Skip const type qualifier.
    if (argumentType[0] == 'r') {
        argumentType++;
    }
    
    if (strcmp(argumentType, @encode(id)) == 0
        || strcmp(argumentType, @encode(Class)) == 0
        || strcmp(argumentType, @encode(void (^)())) == 0
    ) {
        __unsafe_unretained id argument = nil;
        [invocation getArgument:&argument atIndex:index];
        return argument;
    }
    RETURN_VALUE(char)
    RETURN_VALUE(int)
    RETURN_VALUE(short)
    RETURN_VALUE(long)
    RETURN_VALUE(long long)
    RETURN_VALUE(unsigned char)
    RETURN_VALUE(unsigned int)
    RETURN_VALUE(unsigned short)
    RETURN_VALUE(unsigned long)
    RETURN_VALUE(unsigned long long)
    RETURN_VALUE(float)
    RETURN_VALUE(double)
    RETURN_VALUE(BOOL)
    RETURN_VALUE(const char *)
    else {
        NSUInteger size = 0;
        NSGetSizeAndAlignment(argumentType, &size, NULL);
        NSCParameterAssert(size > 0);
        uint8_t data[size];
        [invocation getArgument:&data atIndex:index];
        
        return [NSValue valueWithBytes:&data objCType:argumentType];
    }
}

BOOL RX_is_method_void(NSInvocation * __nonnull invocation) {
    const char *methodReturnType = invocation.methodSignature.methodReturnType;
    return strcmp(methodReturnType, @encode(void)) == 0;
}

BOOL RX_is_method_with_description_void(struct objc_method_description method) {
    return strncmp(method.types, @encode(void), 1) == 0;
}

NSArray *RX_extract_arguments(NSInvocation *invocation) {
    NSUInteger numberOfArguments = invocation.methodSignature.numberOfArguments;
    NSUInteger numberOfVisibleArguments = numberOfArguments - HIDDEN_ARGUMENT_COUNT;
    
    NSCParameterAssert(numberOfVisibleArguments >= 0);
    NSCParameterAssert(RX_is_method_void(invocation));
    
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:numberOfVisibleArguments];
    
    for (NSUInteger index = HIDDEN_ARGUMENT_COUNT; index < numberOfArguments; ++index) {
        [arguments addObject:RX_extract_argument_at_index(invocation, index) ?: [NSNull null]];
    }
    
    return arguments;
}
