//
//  MapPickerViewController.h
//  TableOfContentsSample
//
//  Created by Dina Li on 6/4/13.
//
//  DESCRIPTION: works with PickerNavigationController

#import <UIKit/UIKit.h>
#import "Map.h"
#import "MainViewController.h"

@interface MapPickerViewController : UITableViewController <UIViewControllerRestoration>

@property (strong,nonatomic) Map* aMap;
@property (strong,nonatomic) UIBarButtonItem *backButton;

-(void)goBack:(id)sender; // go back button

@end
