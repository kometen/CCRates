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

@property (nonatomic, strong) IBOutlet UILabel *btc_usd_label;
@property (nonatomic, strong) IBOutlet UILabel *ltc_btc_label;
@property (nonatomic, strong) IBOutlet UILabel *btc_usd_mt_gox_label;
@property (nonatomic, strong) IBOutlet UILabel *one_ltc_label;
@property (nonatomic, strong) IBOutlet UILabel *litecoinsMinedLabel;
@property (nonatomic, strong) IBOutlet UILabel *ltc2btcLabel;
@property (nonatomic, strong) IBOutlet UILabel *ltc2usdLabel;
@property (nonatomic, strong) IBOutlet UILabel *ltc2nokLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *tickerProgressView;

@end

@implementation CCRViewController {
    NSMutableArray *ticktock;
    NSMutableArray *tickerArray;
    __block float tickerCount;
    __block int tickerIndex;
    __block float btc2usd;
    __block float ltc2btc;
    __block float confirmed_rewards;
    __block float usd2nok;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    tickerArray = [[NSMutableArray alloc] initWithArray:@[@"btc_usd", @"ltc_btc"]];
    tickerCount = (float)[tickerArray count];
    usd2nok = 6.2;
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
    [self getRatesWithCompletionHandler:nil];
}

-(void)getRatesWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSString *btcUsdString = @"http://data.mtgox.com/api/2/BTCUSD/money/ticker_fast";
    NSURLSession *mtgoxSession = [NSURLSession sharedSession];
    [[mtgoxSession dataTaskWithURL:[NSURL URLWithString:btcUsdString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Unable to get BTC to USD ticker");
        } else {
            NSError *jsonError;
            NSMutableDictionary *jsonTicker = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                NSLog(@"Error reading BTC to USD json-ticker, jsonError: %@", jsonError);
            } else {
                NSDictionary *ticker = jsonTicker[@"data"];
                NSDictionary *tickerData = ticker[@"last_local"];
                float tickerValue = [tickerData[@"value"] floatValue];
                btc2usd = tickerValue;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.btc_usd_mt_gox_label.text = [NSString stringWithFormat:@"%.03f", tickerValue];
                });
            }
        }
    }] resume];
    
    NSString *litecoinsMinedString = @"https://give-me-coins.com/pool/api-ltc?api_key=6de2398812392441d22e45f60f9287f79ab4b4cd967c38edfc6c39bdc77438e8";
    NSURLSession *gmcSession = [NSURLSession sharedSession];
    [[gmcSession dataTaskWithURL:[NSURL URLWithString:litecoinsMinedString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Unable to get user information");
        } else {
            NSError *gmcError;
            NSMutableDictionary *gmcUserInformation = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&gmcError];
            if (gmcError) {
                NSLog(@"Error reading user information, gmcError: %@", gmcError);
            } else {
                confirmed_rewards = [gmcUserInformation[@"confirmed_rewards"] floatValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.litecoinsMinedLabel.text = [NSString stringWithFormat:@"%.05f", confirmed_rewards];
                    self.ltc2btcLabel.text = [NSString stringWithFormat:@"%.05f", confirmed_rewards * ltc2btc];
                    self.ltc2usdLabel.text = [NSString stringWithFormat:@"%.05f", confirmed_rewards * ltc2btc * btc2usd];
                    self.ltc2nokLabel.text = [NSString stringWithFormat:@"%.05f", confirmed_rewards *  ltc2btc * btc2usd * usd2nok];
                });
            }
        }
    }] resume];

    for (NSString *ta in tickerArray) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        tickerIndex = 0;
        self.tickerProgressView.progress = 0.0f;
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
                        if (tickerIndex == tickerCount) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                [NSThread sleepForTimeInterval:0.5f];
                                self.tickerProgressView.progress = 0.0f;
                            });
                        }
                    });
                    NSDictionary *ticker = jsonTicker[@"ticker"];
                    float tickerValue = [ticker[@"last"] floatValue];
                    if ([ta isEqualToString:@"btc_usd"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.btc_usd_label.text = [NSString stringWithFormat:@"%.03f", tickerValue];
                        });
                    }
                    if ([ta isEqualToString:@"ltc_btc"]) {
                        ltc2btc = tickerValue;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.ltc_btc_label.text = [NSString stringWithFormat:@"%.05f", tickerValue];
                            self.one_ltc_label.text = [NSString stringWithFormat:@"%.05f", (tickerValue * btc2usd)];
                        });
                    }
                }
            }
        }] resume];
    }
    if (completionHandler) {
        NSLog(@"completionHandler");
        completionHandler(UIBackgroundFetchResultNewData);
//        [self getRatesWithCompletionHandler:nil];
        [UIApplication sharedApplication].applicationIconBadgeNumber++;
    }
}

-(void)getMtGoxRates {
    
}

@end
