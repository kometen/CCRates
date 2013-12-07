//
//  CCRWebThings.m
//  CCRates
//
//  Created by Claus Guttesen on 24/11/13.
//  Copyright (c) 2013 Claus Guttesen. All rights reserved.
//

#import "CCRWebThings.h"

@implementation CCRWebThings

-(id)initWithURL:(NSString *)url {
    self = [super init];
    
    if (self) {
        _url = url;
    }
    
    return self;
    
}

@end
