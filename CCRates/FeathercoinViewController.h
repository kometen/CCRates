//
//  FeathercoinViewController.h
//  CCRates
//
//  Created by Claus Guttesen on 26/01/14.
//  Copyright (c) 2014 Claus Guttesen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeathercoinViewController : UIViewController

-(void)getRatesWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
