//
//  CCRWebThings.h
//  CCRates
//
//  Created by Claus Guttesen on 24/11/13.
//  Copyright (c) 2013 Claus Guttesen. All rights reserved.
//
// developer.apple.com/library/ios/documentation/cocoa/Conceptual/URLLoadingSystem/Articles/UsingNSURLSession.html

#import <Foundation/Foundation.h>

@interface CCRWebThings : NSObject

@property (readonly) NSString *url;

-(id)initWithURL:(NSString *)url;
-(void)getLastTicker;

@end
