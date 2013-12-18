//
//  CCRViewController.m
//  CCRates
//
//  Created by Claus Guttesen on 23/11/13.
//  Copyright (c) 2013 Claus Guttesen. All rights reserved.
//

#import "CCRViewController.h"
#import "CCRWebThings.h"

@interface CCRViewController ()

@end

@implementation CCRViewController {
    NSMutableArray *ticktock;
    NSMutableArray *tickerArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tickerArray = [[NSMutableArray alloc] initWithArray:@[@"btc_usd", @"ltc_btc", @"ftc_btc"]];
    [self getRates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)getRates {
    for (NSString *ta in tickerArray) {
        NSString *url = [NSString stringWithFormat:@"https://btc-e.com/api/2/%@/ticker", ta];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            // NSLog(@"Got response %@ with error %@.\n", response, error);
            if (error) {
                NSLog(@"Unable to GET %@", url);
            } else {
                //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSError *jsonError;
                NSMutableDictionary *jsonTicker = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) {
                    NSLog(@"Error reading json-ticker: jsonError: %@", [jsonError localizedDescription]);
                } else {
                    NSDictionary *ticker = jsonTicker[@"ticker"];
                    NSLog(@"ticker: %@,\tlast: %@,\tlow: %@,\thigh: %@", ta, ticker[@"last"], ticker[@"low"], ticker[@"high"]);
                }
            }
        }] resume];
    }
}

-(void)getRatesWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (completionHandler) {
        NSLog(@"completionHandler");
        [self getRates];
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

@end
