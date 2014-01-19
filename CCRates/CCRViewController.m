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
    tickerCount = 3.0f;
    usd2nok = 6.08;
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
    tickerIndex = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });

    [self getMtGoxRates];
    [self giveMeCoins];
    [self getBtcExchRates];

    if (completionHandler) {
        NSLog(@"completionHandler");
        completionHandler(UIBackgroundFetchResultNewData);
//        [self getRatesWithCompletionHandler:nil];
        [UIApplication sharedApplication].applicationIconBadgeNumber++;
    }
}

-(void)getBtcExchRates {

    // 1
    NSString *btc_exch_btc_usd = [NSString stringWithFormat:@"https://btc-e.com/api/2/btc_usd/ticker"];
    NSURLSession *session1 = [NSURLSession sharedSession];
    [[session1 dataTaskWithURL:[NSURL URLWithString:btc_exch_btc_usd]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // NSLog(@"Got response %@ with error %@.\n", response, error);
        if (error) {
            NSLog(@"Unable to GET %@", btc_exch_btc_usd);
        } else {
            //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSError *jsonError;
            NSMutableDictionary *jsonTicker = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                NSLog(@"Error reading json-ticker: jsonError: %@", [jsonError localizedDescription]);
            } else {
                NSDictionary *ticker = jsonTicker[@"ticker"];
                float tickerValue = [ticker[@"last"] floatValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self tickerProgress];
                    self.btc_usd_label.text = [NSString stringWithFormat:@"%.03f", tickerValue];
                });
            }
        }
    }] resume];

    // 2
    NSString *btc_exch_ltc_btc = [NSString stringWithFormat:@"https://btc-e.com/api/2/ltc_btc/ticker"];
    NSURLSession *session2 = [NSURLSession sharedSession];
    [[session2 dataTaskWithURL:[NSURL URLWithString:btc_exch_ltc_btc]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSLog(@"Got response %@ with error %@.\n", response, error);
        if (error) {
            NSLog(@"Unable to GET %@", btc_exch_btc_usd);
        } else {
            //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSError *jsonError;
            NSMutableDictionary *jsonTicker = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                NSLog(@"Error reading json-ticker: jsonError: %@", [jsonError localizedDescription]);
            } else {
                NSDictionary *ticker = jsonTicker[@"ticker"];
                float tickerValue = [ticker[@"last"] floatValue];
                ltc2btc = tickerValue;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Hardcoded colorscheme, bad, bad. If usefull place in some preference
                    if (tickerValue > 0.03) { self.ltc_btc_label.textColor = [UIColor blueColor];
                    } else {
                        self.ltc_btc_label.textColor = [UIColor blackColor];
                    }
                    self.ltc_btc_label.text = [NSString stringWithFormat:@"%.05f", tickerValue];
                    
                    if (tickerValue * btc2usd > 30) {
                        self.one_ltc_label.textColor = [UIColor blueColor];
                    } else {
                        self.one_ltc_label.textColor = [UIColor blackColor];
                    }
                    self.one_ltc_label.text = [NSString stringWithFormat:@"%.05f", (tickerValue * btc2usd)];
               });
            }
        }
    }] resume];
}

-(void)getMtGoxRates {
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
                    [self tickerProgress];
                    // Hardcoded colorscheme, bad, bad. If usefull place in some preference
                    if (tickerValue > 1000) {
                        self.btc_usd_mt_gox_label.textColor = [UIColor blueColor];
                    } else {
                        self.btc_usd_mt_gox_label.textColor = [UIColor blackColor];
                    }
                    self.btc_usd_mt_gox_label.text = [NSString stringWithFormat:@"%.03f", tickerValue];
                });
            }
        }
    }] resume];
}

-(void)giveMeCoins {
    [self tickerProgress];
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSThread sleepForTimeInterval:0.5f];
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                        self.tickerProgressView.progress = 0.0f;
                    });
                });
            }
        }
    }] resume];
}

-(void)tickerProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tickerProgressView.progress = (++tickerIndex / tickerCount);
    });
}

@end
