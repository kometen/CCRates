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

//@property (nonatomic, weak) IBOutlet UIButton *ratesButton;

@end

@implementation CCRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)getRates {
    CCRWebThings *ftcBtc = [[CCRWebThings alloc] initWithURL:@"https://btc-e.com/api/2/ftc_btc/ticker"];
    NSLog(@"ftc-btc-ticker: %@", ftcBtc.url);
    NSString *ftcBtcTicker = @"https://btc-e.com/api/2/ltc_btc/ticker";
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:ftcBtcTicker]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSLog(@"Got response %@ with error %@.\n", response, error);
        NSLog(@"\nDATA:\n%@\nEND DATA\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSError *jsonError;
        NSMutableDictionary *jsonTicker = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError) {
            NSLog(@"Error reading json-ticker: jsonError: %@", [jsonError localizedDescription]);
        } else {
            NSDictionary *ticker = jsonTicker[@"ticker"];
                NSLog(@"last: %@", ticker[@"last"]);
        }
    }] resume];
}

-(void)getRatesWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (completionHandler) {
        NSLog(@"completionHandler");
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

@end
