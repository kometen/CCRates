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

@property (nonatomic, strong) IBOutlet UILabel *btc_usd;
@property (nonatomic, strong) IBOutlet UILabel *ltc_btc;
@property (nonatomic, strong) IBOutlet UILabel *ftc_btc;
@property (nonatomic, strong) IBOutlet UIProgressView *tickerProgressView;

@end

@implementation CCRViewController {
    NSMutableArray *ticktock;
    NSMutableArray *tickerArray;
    __block float tickerCount;
    __block int tickerIndex;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    tickerArray = [[NSMutableArray alloc] initWithArray:@[@"btc_usd", @"ltc_btc", @"ftc_btc"]];
    tickerCount = (float)[tickerArray count];
    [self getRates];
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)getRates {
    tickerIndex = 0;
    self.tickerProgressView.progress = 0.0f;
    [self getRatesWithCompletionHandler:nil];
}

-(void)getRatesWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
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
                    // stackoverflow.com/questions/8803189/setprogress-is-no-longer-updating-uiprogressview-since-ios-5
                    tickerIndex++;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.tickerProgressView.progress = (tickerIndex / tickerCount);
                    });
                    NSDictionary *ticker = jsonTicker[@"ticker"];
                    float tickerValue = [ticker[@"last"] floatValue];
                    if ([ta isEqualToString:@"btc_usd"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.btc_usd.text = [NSString stringWithFormat:@"%.03f", tickerValue];
                        });
                    }
                    if ([ta isEqualToString:@"ltc_btc"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.ltc_btc.text = [NSString stringWithFormat:@"%.05f", tickerValue];
                        });
                    }
                    if ([ta isEqualToString:@"ftc_btc"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.ftc_btc.text = [NSString stringWithFormat:@"%.05f", tickerValue];
                        });
                    }
//                    NSLog(@"ticker: %@,\tlast: %@,\tlow: %@,\thigh: %@", ta, ticker[@"last"], ticker[@"low"], ticker[@"high"]);
                }
            }
        }] resume];
    }
    if (completionHandler) {
        NSLog(@"completionHandler");
        //[self getRates];
        completionHandler(UIBackgroundFetchResultNewData);
        [UIApplication sharedApplication].applicationIconBadgeNumber++;
    }
}

@end
