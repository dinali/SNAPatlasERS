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
#import "MainViewController.h"
#import "TOCViewController.h"

@interface MainViewController()
{
    Reachability * internetReachable;
    Reachability * reach;
    Reachability * wifiReach;
}

@property (nonatomic, strong) TOCViewController *tocViewController;

@end

@implementation MainViewController

@synthesize mapView = _mapView;
@synthesize infoButton = _infoButton;
@synthesize legendButton = _legendButton;
@synthesize tocViewController = _tocViewController;
@synthesize popOverController = _popOverController;
@synthesize dynamiclayerID = _dynamiclayerID;
@synthesize activityIndicator = _activityIndicator;
@synthesize activityLabel = _activityLabel;
@synthesize notificationLabel = _notificationLabel;
@synthesize mapName = _mapName;
@synthesize locationManager = _locationManager;
@synthesize startLocation = _startLocation;
@synthesize findMeButton = _findMeButton;
@synthesize ersMapServiceURL = _ersMapServiceURL;
@synthesize ersMap = _ersMap;

#define kTiledLayerURL @"http://gis2.ers.usda.gov/ArcGIS/rest/services/Background_Cache/MapServer"
//#define kDynamicMapServiceURL @"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Benefits/MapServer"
#define kMapServiceURL @"http://gis2.ers.usda.gov/ArcGIS/rest/services/Reference2/MapServer" // states

- (id)init
{
    self = [super init];
    //if (self == nil) {
        _mapName = @"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Benefits/MapServer";
    //}
    NSLog(@"init mapName = %@", _mapName);
    return self;
}

// receive mapName passed from other VC?
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
    
    if(self){
        //_mapName = @"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Benefits/MapServer";
        //  ersMapServiceURL =
    }
    NSLog(@"initWithNibName _ersMapServiceURLe = %@", _ersMapServiceURL);
    return self;
}

// occurs After viewDidLoad
- (void) viewWillAppear:(BOOL)animated {
       
    NSLog(@"viewWillAppear called");
}

- (IBAction)showCurrentLocation:(id)sender
{
    [self.mapView centerAtPoint:[self.mapView.locationDisplay mapLocation] animated:YES];
    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    NSLog(@"showCurrentLocation");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // SET PROPERTIES
    [self setTitle:@"Map View"];
    [self setRestorationIdentifier:@"mainVC"];
    self.restorationClass = [self class];
    
    NSLog(@"map to show = %@", _mapName);
    
    // CHECK internet connection
    BOOL wifiBoolean = [self checkForInternet];
    
    if(wifiBoolean == YES){
        NSLog(@"main viewDidLoad:accessed ERS map service");
        
        // MAP IS LOADING
        
        self.activityIndicator.hidden= NO;
        [self.activityIndicator startAnimating];
        
        // MAP IS LOADING:this hard codes the length of time to display the indicator, that's not such a good approach because the network time might vary; this is the only place it works to call the displayIndicator
        [self performSelector:@selector(stopIndicator)withObject:nil afterDelay:15.0]; // 10 seconds
        
        // LOAD LAYERS
        
        //create the toc view controller, toc view controller changes visibility of the mapView without calling this viewDidLoad method
        self.tocViewController = [[TOCViewController alloc] initWithMapView:self.mapView];
        
        // Calls method that adds the layer to the legend each time layer is loaded
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToLayerLoaded:) name:AGSLayerDidLoadNotification object:nil];
        
        NSURL *mapUrl = [NSURL URLWithString:kTiledLayerURL];
        AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
        [self.mapView addMapLayer:tiledLyr withName:@"Base Map"];
        
        /* LOAD DYNAMIC MAP, default is Benefits */
        
        if(self.mapName.length == 0){
            self.ersMapServiceURL = [NSURL URLWithString:@"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Benefits/MapServer"];
        }
        else{
            NSLog(@"map URL = %@", self.ersMapServiceURL); // use the value passed from MapPickerVC
        }
        
        NSError *error = nil;
        AGSMapServiceInfo *info = [AGSMapServiceInfo mapServiceInfoWithURL:self.ersMapServiceURL error:&error];
        
        AGSDynamicMapServiceLayer* layer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithMapServiceInfo: info];
        
        // specifies which layer(s) are displayed on the map - this is different from what's displayed in the legend; without this code, nothing is displayed
        
        // modify this if the TOC view controller changes selection
        if(layer.loaded)
        {
            // only show the Xth layer
            layer.visibleLayers= [NSArray arrayWithObjects:[NSNumber numberWithInt:0], nil];
            layer.opacity = .8;
        }
        
    NSLog(@"before adding Snap layer");
        [self.mapView addMapLayer:layer withName:@"Snap Benefits"];
    NSLog(@"after adding Snap layer");
        
        NSURL *stateMapUrl = [NSURL URLWithString:kMapServiceURL];
        AGSDynamicMapServiceLayer *dynamicLyr = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:stateMapUrl];
        [self.mapView addMapLayer:dynamicLyr withName:@"States"];
        
        //Zooming to an initial envelope with the specified spatial reference of the map.
        AGSSpatialReference *sr = [AGSSpatialReference webMercatorSpatialReference];
        AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-14314526
                                                    ymin:2616367
                                                    xmax:-7186578
                                                    ymax:6962565
                                        spatialReference:sr];
        [self.mapView zoomToEnvelope:env animated:YES];
        
        // ADDED FOR GEOCODING FIND ADDRESS, also need for popup location!
        
        //set the delegate on the mapView so we get notifications for user interaction with the callout for geocoding
        self.mapView.callout.delegate = self;
        
        // TODO: this might not be necessary
        //create the graphics layer that the geocoding result
        //will be stored in and add it to the map
        self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
        [self.mapView addMapLayer:self.graphicsLayer withName:@"Search Layer"];
        
        // CURRENT LOCATION marker: user's current location as starting point
        [self.mapView.locationDisplay startDataSource];
        
        // LEGEND: a data source that will hold the legend items
        self.legendDataSource = [[LegendDataSource alloc] init];
        
        //Initialize the legend view controller
        //This will be displayed when user clicks on the info button
        
        self.legendViewController = [[LegendViewController alloc] initWithNibName:@"LegendViewController" bundle:nil];
        self.legendViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        self.legendViewController.legendDataSource = self.legendDataSource;
        
        // ADDED FOR POPUP BY LOCATION
        self.mapView.touchDelegate = self;
        
        //create identify task
        self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:[NSURL URLWithString:self.mapName ]];
        self.identifyTask.delegate = self;
        
        //create identify parameters
        self.identifyParams = [[AGSIdentifyParameters alloc] init];
        
        self.mapView.showMagnifierOnTapAndHold = YES;
        self.mapView.allowMagnifierToPanMap = YES;
        
        // CCLocationManager
        /* not used, can be used to find distance between points */
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        self.startLocation = nil;
        
    }
    else{
        NSLog(@"main viewDidLoad:no wifi available");
        
        NSString *titleString = @"No Internet Connection";
        NSString *messageString = @"Warning: an internet connection could not be found";
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString message:messageString
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:  nil];
        [alert show];
    }
}

#pragma mark -
#pragma mark Check for Internet

-(BOOL) checkForInternet{
    
    /* Test for Internet Connection, this is the only URL that works for this purpose */
	Reachability *r = [Reachability reachabilityWithHostname: @"http://m.usa.com"];
   
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL internet;
	if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
		internet = NO;
	} else {
		internet = YES;
	}
	return internet;
}

//-(NSURL*) getDefaultMapURL{
//    
//    if(_mapName.length == 0){
//        self.ersMapServiceURL = @"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Benefits/MapServer";
//    }
//    return self.ersMapServiceURL;
//}


/* NOT USED */
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reachStatus = [note object];
    
    if([reachStatus isReachable])
    {
        _notificationLabel.text = @"ERS map service is available";
    }
    else
    {
        _notificationLabel.text = @"ERS map service is not available";
    }
}

// NOT CURRENTLY USED
-(BOOL) checkConnectionStatus:(NSNotification*)note {
    
    BOOL connectBoolean;
    
    NetworkStatus internetStatus = [reach currentReachabilityStatus];
    
    switch (internetStatus) {
        case NotReachable:
            NSLog(@"check Status: the internet is down.");
            connectBoolean = NO;
            break;
            
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            connectBoolean = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            connectBoolean = YES;
            break;
        }
    }
    return connectBoolean;
}

#pragma mark -
#pragma mark Map is Loading:UIActivityIndicatorView

// stop the spinner for map is loading
-(void) stopIndicator{
    
    [self.activityIndicator stopAnimating];
    self.activityLabel.hidden = YES;
}

#pragma mark -
#pragma mark AGSMapViewDelegate

- (void)respondToLayerLoaded:(NSNotification*)notification {
    
	//Add legend for each layer added to the map
	[self.legendDataSource addLegendForLayer:(AGSLayer *)notification.object];
}


#pragma mark - show the associated table view depending on which button was clicked

// sample code used a popOverController for the iPad, but it got confusing when both the legend and TOC are available.
// TODO: comment out when the other bug has been eliminated
- (IBAction)presentTableOfContents:(id)sender
{
    //If iPad, show legend in the PopOver, else transition to the separate view controller
	/*if([[AGSDevice currentDevice] isIPad]) {
        if(!self.popOverController) {
            self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.tocViewController];
            self.tocViewController.popOverController = self.popOverController;
            self.popOverController.popoverContentSize = CGSizeMake(320, 500);
            self.popOverController.passthroughViews = [NSArray arrayWithObject:self.view];
        }        
		[self.popOverController presentPopoverFromRect:self.infoButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES ];		
	}
    else {
		[self presentModalViewController:self.tocViewController animated:YES];
	}
    */
    [self presentModalViewController:self.tocViewController animated:YES];
}

// OBSOLETE because the legend is visible in the Layers
- (IBAction) presentLegendViewController: (id) sender{
	//If iPad, show legend in the PopOver, else transition to the separate view controller
	/*if([[AGSDevice currentDevice] isIPad]){
        if(!self.popOverController) {
            self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.legendViewController];
            self.legendViewController.popOverController = self.popOverController;
            self.popOverController.popoverContentSize = CGSizeMake(320, 500);
            self.popOverController.passthroughViews = [NSArray arrayWithObject:self.view];
        }
		[self.popOverController presentPopoverFromRect:self.legendButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES ];
    }
    else {
		[self presentModalViewController:self.legendViewController animated:YES];
	}
    */
    [self presentModalViewController:self.legendViewController animated:YES];
}

#pragma mark -
#pragma mark AGSCalloutDelegate -- DISPLAYS THE box with related information for the location

- (void) didClickAccessoryButtonForCallout:(AGSCallout *) callout
{
    AGSGraphic* graphic = (AGSGraphic*) callout.representedObject;
    //The user clicked the callout button, so display the complete set of results
    ResultsViewController *resultsVC = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil];
    
    // this is the set to Exclude from the display in the popup
       
    NSMutableDictionary * tempDictionary = [graphic allAttributes].mutableCopy;
    [tempDictionary removeObjectForKey:@"OBJECTID"];
    [tempDictionary removeObjectForKey:@"Shape"];
    [tempDictionary removeObjectForKey:@"Shape_Area"];
    [tempDictionary removeObjectForKey:@"Shape_Length"];
    
    //set our attributes/results into the results VC
    resultsVC.results = tempDictionary;
    
    //display the results vc modally
    [self presentModalViewController:resultsVC animated:YES];
}


#pragma mark -
#pragma mark AGSLocatorDelegate

- (void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{
    //check and see if we didn't get any results
	if (candidates == nil || [candidates count] == 0)
	{
        //show alert if we didn't get results
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results"
                                                        message:@"No Results Found By Locator"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
	}
	else
	{
        //use these to calculate extent of results
        double xmin = DBL_MAX;
        double ymin = DBL_MAX;
        double xmax = -DBL_MAX;
        double ymax = -DBL_MAX;
		
		//create the callout template, used when the user displays the callout
		self.calloutTemplate = [[AGSCalloutTemplate alloc]init];
        
        //loop through all candidates/results and add to graphics layer
		for (int i=0; i<[candidates count]; i++)
		{
			AGSAddressCandidate *addressCandidate = (AGSAddressCandidate *)[candidates objectAtIndex:i];
            
            //get the location from the candidate
            AGSPoint *pt = addressCandidate.location;
            
            //accumulate the min/max
            if (pt.x  < xmin)
                xmin = pt.x;
            
            if (pt.x > xmax)
                xmax = pt.x;
            
            if (pt.y < ymin)
                ymin = pt.y;
            
            if (pt.y > ymax)
                ymax = pt.y;
            
			//create a marker symbol to use in our graphic
            AGSPictureMarkerSymbol *marker = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"BluePushpin.png"];
            marker.offset = CGPointMake(9,16);
            marker.leaderPoint = CGPointMake(-9, 11);
            
            //set the text and detail text based on 'Name' and 'Descr' fields in the attributes
            self.calloutTemplate.titleTemplate = @"${Name}";
            self.calloutTemplate.detailTemplate = @"${Descr}";
			
            //create the graphic
			AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry: pt
																symbol:marker
															attributes:[addressCandidate.attributes mutableCopy]
                                                  infoTemplateDelegate:self.calloutTemplate];
            
            
            //add the graphic to the graphics layer
			[self.graphicsLayer addGraphic:graphic];
            
            if ([candidates count] == 1)
            {
                //we have one result, center at that point
                [self.mapView centerAtPoint:pt animated:NO];
                
				// set the width of the callout
				self.mapView.callout.width = 250;
                
                //show the callout
                [self.mapView.callout showCalloutAtPoint:(AGSPoint*)graphic.geometry forGraphic:graphic animated:YES];
            }
			
			//release the graphic bb
		}
        
        //if we have more than one result, zoom to the extent of all results
        int nCount = [candidates count];
        if (nCount > 1)
        {
            AGSMutableEnvelope *extent = [AGSMutableEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.mapView.spatialReference];
            [extent expandByFactor:1.5];
			[self.mapView zoomToEnvelope:extent animated:YES];
        }
	}
    
}

#pragma mark - Show location data in popup:AGSCalloutDelegate methods

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphicsDict {
    
    //store for later use
    self.mappoint = mappoint;
    
	//the layer we want is layer ‘5’ (from the map service doc)
	self.identifyParams.layerIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], nil];
	self.identifyParams.tolerance = 3;
	self.identifyParams.geometry = self.mappoint;
	self.identifyParams.size = self.mapView.bounds.size;
	self.identifyParams.mapEnvelope = self.mapView.visibleArea.envelope;
	self.identifyParams.returnGeometry = YES;
	self.identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
	self.identifyParams.spatialReference = self.mapView.spatialReference;
    
	//execute the task
	[self.identifyTask executeWithParameters:self.identifyParams];
}


#pragma mark - Display Callout:AGSIdentifyTaskDelegate methods

- (void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didExecuteWithIdentifyResults:(NSArray *)results {
    
    //clear previous results
    [self.graphicsLayer removeAllGraphics];
    
    if ([results count] > 0) {
        
        //add new results
        AGSSymbol* symbol = [AGSSimpleFillSymbol simpleFillSymbol];
        symbol.color = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
        
        NSString *title = nil;
        NSUInteger layerID = 0;
        
        @try {
            
            // for each result, set the symbol and add it to the graphics layer
            for (AGSIdentifyResult* result in results) {
                result.feature.symbol = symbol;
                [self.graphicsLayer addGraphic:result.feature];
                _graphic = result.feature;
                title = result.layerName;
                layerID = result.layerId; // can this be a filter? not used
            }
            
            self.mapView.callout.title = title; // this is just the title
            self.mapView.callout.detail = @"Click for details";
            
            // Show callout for graphic
            [self.mapView.callout showCalloutAtPoint:self.mappoint forGraphic:_graphic animated:YES];
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
        @finally {
            NSLog(@"finally");
        }
    }
}

//if there's an error with the query display it to the user
- (void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:[error localizedDescription]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

- (void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFailLocationsForAddress:(NSError *)error
{
    //The location operation failed, display the error
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Locator Failed"
                                                    message:[NSString stringWithFormat:@"Error: %@", error.description]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}


#pragma mark - UI:BarButton items

/* display the WebViewController that shows
 * the overview etc.
*/

- (IBAction)showWebDetails:(id)sender {
    WebsiteViewController *webVC = [[WebsiteViewController alloc] initWithNibName:@"WebsiteViewController" bundle:nil];
    
    Map * myMap = [[Map alloc]init];
    
    /* pass the URL depending on which map is being displayed */
    webVC.pageURL = [myMap getURL:@"SNAP"];
    
    [self presentViewController:webVC animated:YES completion:nil];
}

- (IBAction)showPhoneLocation:(id)sender {
}

/* display the UITableViewController that shows
 * the map options
*/
- (void)changeMap:(id)sender {
       
    MapPickerViewController *pickerViewController = [[MapPickerViewController alloc]initWithNibName:@"MapPickerViewController" bundle:nil];
    
    PickerNavigationController *pickerNC = [[PickerNavigationController alloc]initWithRootViewController:pickerViewController];
    
    [self presentViewController:pickerNC animated:YES completion:nil];
}

#pragma mark - cleanup and startup

+(UIViewController*)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    UIViewController * mainViewController = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
    return mainViewController;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


// probably unecessary in iOS6
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if(self.view!=nil){
        internetReachable = nil;
        reach = nil;
        wifiReach = nil;
        self.mapView = nil;
    
        self.locationManager = nil;
        self.startLocation = nil;
    
        if([[AGSDevice currentDevice] isIPad])
        self.popOverController = nil;
        [self setFindMeButton:nil];
    
        self.graphicsLayer = nil;
        self.locator = nil;
        self.calloutTemplate = nil;
        self.legendDataSource = nil;
        self.identifyTask = nil;
        self.identifyParams = nil;
        self.mappoint = nil;
        self.graphic = nil;
    
        NSLog(@"didReceiveMemoryWarning in MainVC");
    }
}


@end
