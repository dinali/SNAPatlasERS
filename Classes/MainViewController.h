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

// DESCRIPTION: This is for SNAP and all the identical ERS maps.
// FEATURES: switch between layers using a callout, display legend, display location-specific popup with data
// DEVELOPER NOTES: the same code for the callout for the layers works auto-magically with the location-specific popup feature, doesn't requre extra coding; hard coded for just one map - SNAP 2009 Benefits
// TODO: changes in selection of map layer need to be reflected in the PopUp location; sort order of items in TOC
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import <CoreLocation/CoreLocation.h>
#import "LegendDataSource.h"
#import "LegendViewController.h"
#import "Reachability.h"
#import "WebsiteViewController.h"
#import "ResultsViewController.h"
#import "MapPickerViewController.h"
//#import "PickerNavigationController.h"
#import "Map.h"
#import "TOCViewController.h"
#import "LayerInfo.h"

@interface MainViewController : UIViewController <AGSMapViewLayerDelegate, AGSLocatorDelegate, AGSCalloutDelegate, AGSMapViewTouchDelegate, AGSIdentifyTaskDelegate, UIViewControllerRestoration, CLLocationManagerDelegate, AGSLayerDelegate > {
    
	AGSMapView *_mapView;
	UIButton* _infoButton;
    
    // find adddress feature and display popup for location
    //UISearchBar *_searchBar;
    AGSGraphicsLayer *_graphicsLayer;
	AGSLocator *_locator;
	AGSCalloutTemplate *_calloutTemplate;
    
    // legend feature
    UIButton* _changeMapButton;
    
	LegendDataSource* _legendDataSource;
    LegendInfo* _legendInfo;
	LegendViewController* _legendViewController;
    
    //Only used with iPad - obsolete??
	UIPopoverController* _popOverController;
}

@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) IBOutlet UIButton* infoButton; // map layers/subjects
@property (nonatomic, strong) UIPopoverController *popOverController;
@property (weak, nonatomic) IBOutlet AGSMapView *legendButton;

// find address feature & call-out popup?
//@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, strong) AGSLocator *locator;
@property (nonatomic, strong) AGSCalloutTemplate *calloutTemplate;

// show legend
@property (nonatomic, strong) LegendDataSource *legendDataSource;
@property (nonatomic, strong) LegendInfo *legendInfo;
@property (nonatomic, strong) LegendViewController *legendViewController;

// location popup
@property (nonatomic, retain) AGSIdentifyTask *identifyTask;
@property (nonatomic, retain) AGSIdentifyParameters *identifyParams;
@property (nonatomic, retain) AGSPoint* mappoint;
@property (nonatomic, retain) AGSGraphic *graphic;

@property NSInteger *dynamiclayerID;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;

// display the activity indicator Map is Loading
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

// name of the map to load
@property (strong,nonatomic) NSString * mapName;
@property (strong, nonatomic) Map * ersMap;
@property(weak,nonatomic) IBOutlet UILabel *currentMapLabel; // this is the sublayer
@property (strong, nonatomic) NSString *layerName;

// location
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) CLLocation *startLocation;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *findMeButton;

@property (weak, nonatomic) IBOutlet UIToolbar *detailsButon;

@property (strong,nonatomic) NSURL *ersMapServiceURL;
@property (strong,nonatomic) NSString * whoCalled;
@property (nonatomic, strong) LayerInfo *mapViewLevelLayerInfo;

/****** METHODS ******/

- (IBAction)presentTableOfContents:(id)sender;  // display layers
- (IBAction)presentLegendViewController:(id)sender; // display legend
- (IBAction)showCurrentLocation:(id)sender; // click to display where you are
- (IBAction)showWebDetails:(id)sender;

- (void)changeMap:(id)sender; // display TableViewController for choosing a different SNAP map


@end

