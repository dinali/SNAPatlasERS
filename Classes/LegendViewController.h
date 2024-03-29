// Copyright 2012 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
// SAMPLE: ESRI LegendSample code
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//
/* DESCRIPTION: displays the Legend; may not be used
 */

#import <UIKit/UIKit.h>
#import "LegendDataSource.h"

//#import "MainViewController.h"

@interface LegendViewController : UIViewController <UIViewControllerRestoration> {
	UITableView* _legendTableView;
	LegendDataSource* _legendDataSource;
	UIPopoverController* _popOverController;
    LegendInfo* _legendInfo;
}

@property (strong, nonatomic) IBOutlet UITableView *legendTableView;
@property (nonatomic,strong) LegendDataSource* legendDataSource;
@property (nonatomic,strong) UIPopoverController* popOverController;
@property (nonatomic,strong) LegendInfo* legendInfo;

//- (IBAction) dismiss;
@property (weak, nonatomic) IBOutlet UIButton *backNowButton;

- (IBAction)dismissMe:(id)sender;


@end
