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

-(void)getLastTicker
{
    NSString *ftcBtcTicker = @"https://btc-e.com/api/2/ltc_btc/ticker";
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:ftcBtcTicker]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //        NSLog(@"Got response %@ with error %@.\n", response, error);
        if (error) {
            NSLog(@"Unable to GET %@", ftcBtcTicker);
        } else {
            NSLog(@"\nDATA:\n%@\nEND DATA\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSError *jsonError;
            NSMutableDictionary *jsonTicker = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                NSLog(@"Error reading json-ticker: jsonError: %@", [jsonError localizedDescription]);
            } else {
                NSDictionary *ticker = jsonTicker[@"ticker"];
                NSLog(@"last: %@", ticker[@"last"]);
            }
        }
    }] resume];

}

@end
