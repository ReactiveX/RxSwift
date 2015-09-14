//
//  _RX.h
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#import <Foundation/Foundation.h>


#if DEBUG
#   define DLOG(...)  NSLog(__VA_ARGS__)
#else
#   define DLOG(...)
#endif