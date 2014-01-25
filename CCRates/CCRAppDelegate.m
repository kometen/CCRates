//
//  CCRAppDelegate.m
//  CCRates
//
//  Created by Claus Guttesen on 23/11/13.
//  Copyright (c) 2013 Claus Guttesen. All rights reserved.
//

#import "CCRAppDelegate.h"
#import "LitecoinViewController.h"

@implementation CCRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
     You must invoke setMinimumBackgroundFetchInterval:. The default value is UIApplicationBackgroundFetchIntervalNever which means the app will never be woken for a background fetch.
     */
    
    // From apple.com simple fetch-example

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    return YES;
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{

    /*
     This method gets called when a background fetch happens. The app will have a limited amount of time to update itself in the background, so be careful on how you use this.
     When are done with this, you must call completionHandler with a suitable UIBackgroundFetchResult constant:
     * UIBackgroundFetchResultNewData if the app was able to successfully update itself.
     * UIBackgroundFetchResultNoData if the app did not have any additional data to update itself with.
     * UIBackgroundFetchResultFailed if the app failed to update for some reason.
     
     Be careful not to cache the completionHandler, although as shown in this example you can pass it through to the corresponding methods where you intend to do call it.
     
     Replace this implementation with whatever makes sense in your app.
     
     */
    
    /*
     ** For the purposes of illustration in this particular example only**, consider the fetch successful only if the navigation controller's top view controller is the master table view controller. (You can then test the two scenarios by navigating from the master to the detail view controller.)
     * If the master view controller is the top view controller, invoke its insertNewObjectForFetchWithCompletionHandler: method. The insertNewObjectForFetchWithCompletionHandler: method takes as its argument the completion handler which is then invoked in the method with the argument UIBackgroundFetchResultNewData.
     * If the detail view controller is the top view controller, then pretend that the fetch failed and invoke the completion handler with the argument UIBackgroundFetchResultFailed.
     
     Important: Not shown here is a case where the background fetch didn't have new data to fetch. If the fetch fails in this way, you must call the completion handler with the argument UIBackgroundFetchResultNoData.
     */
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    id topViewController = navigationController.topViewController;
    if ([topViewController isKindOfClass:[LitecoinViewController class]]) {
        /*
         The master view controller's insertNewObjectForFetchWithCompletionHandler: method simply adds some new data to the tableview in this app. Replace this with what's appropriate for your app.
         
         The insertNewObjectForFetchWithCompletionHandler: method invokes the completion handler with the argument UIBackgroundFetchResultNewData.
         */
        [(LitecoinViewController *)topViewController getRatesWithCompletionHandler:completionHandler];
    } else {
        completionHandler(UIBackgroundFetchResultFailed);
    }
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
