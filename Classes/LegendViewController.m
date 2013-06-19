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

#import "LegendViewController.h"

@implementation LegendViewController
@synthesize legendTableView = _legendTableView;
@synthesize legendDataSource = _legendDataSource;
@synthesize popOverController=_popOverController;

@synthesize legendInfo = _legendInfo; // TODO: dead end?

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setRestorationIdentifier:@"legendVC"];
    self.restorationClass = [self class];
	//Hook up the table view with the data source to display legend
	self.legendTableView.dataSource = self.legendDataSource;
    
   // NSLog(@"LEGEND VC sublayername = %@", self.legendInfo.sublayerName); // tried to populate this from MainVC, does it work?
}

- (IBAction) dismiss {
	/*if([[AGSDevice currentDevice] isIPad])
		[self.popOverController dismissPopoverAnimated:YES];
	else */
		[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
     if(self.view!=nil){
         self.legendTableView = nil;
         self.legendDataSource = nil;
         self.popOverController = nil;
     }
}

+(UIViewController*)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    UIViewController * legendVC = [[LegendViewController alloc]initWithNibName:@"LegendViewController" bundle:nil];
    return legendVC;
}


@end
