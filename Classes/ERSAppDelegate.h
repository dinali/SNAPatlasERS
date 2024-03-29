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

#import <UIKit/UIKit.h>

@class MainViewController;
//@class PickerNavigationController;

@interface ERSAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *viewController;
   // PickerNavigationController *pickerNavigationController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
//@property (nonatomic,strong) IBOutlet PickerNavigationController *pickerNavigationController;
@property (nonatomic, strong) IBOutlet MainViewController *viewController;
@property BOOL firstRun;

@end

