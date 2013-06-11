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
// SAMPLE: ESRI TableOfContents
//
/* DESCRIPTION: displays all the map layers with the legend items as a UITableView drop down
*/

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "MainViewController.h"

@interface TOCViewController : UIViewController <UIViewControllerRestoration>


@property (nonatomic, weak) UIPopoverController *popOverController;

- (id)initWithMapView:(AGSMapView *)mapView;




@end
