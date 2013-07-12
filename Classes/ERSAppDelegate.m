// Copyright 2012 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//


#import "ERSAppDelegate.h"
#import "MainViewController.h"

@implementation ERSAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize firstRun;
//@synthesize pickerNavigationController;

/*
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    } else {
        self.viewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPad" bundle:nil];
    }
    
    [window setRootViewController:viewController];
    [window makeKeyAndVisible];
}
*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    viewController.firstTime = YES;
    
    // set mainvc as the root
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    
    [[self window] setRootViewController:navController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    //[window setRootViewController:viewController];
    [window makeKeyAndVisible];
    return YES;
}
 

-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    NSLog(@"applicationDidReceiveMemoryWarning");
<<<<<<< HEAD
    [self.viewController removeFromParentViewController];
=======
>>>>>>> 2c2615ae86bfc7960f2543b757ce4380ea48ee82
}

@end
