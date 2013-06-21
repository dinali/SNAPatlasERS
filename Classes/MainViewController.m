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
@synthesize currentMapLabel = _currentMapLabel;
@synthesize layerName = _layerName;
@synthesize legendInfo = _legendInfo;

#define kTiledLayerURL @"http://gis2.ers.usda.gov/ArcGIS/rest/services/Background_Cache/MapServer"
#define kSnapRetailURL @"http://www.snapretailerlocator.com/ArcGIS/rest/services/retailer/MapServer" //SNAP retail locator
#define kMapServiceURL @"http://gis2.ers.usda.gov/ArcGIS/rest/services/Reference2/MapServer" // states

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

/* NEW CODE */

// pass layerName
-(void)handleNotification:(NSNotification *)pNotification
{
    self.layerName = (NSString*)[pNotification object];
        
    if ([self.layerName isEqual: nil]){
        self.layerName = @"2010 total SNAP benefits";
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// DON'T DELETE THIS, the iPad version will thrown an exception
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
    
    if(self){
        //_mapName = @"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Benefits/MapServer";
        //  ersMapServiceURL =
    }
    return self;
}

// display the map name or the layer name
- (void) viewWillAppear:(BOOL)animated {
    
    if(self.layerName.length == 0){
        self.currentMapLabel.text = self.mapName;
    }
    else{
        self.currentMapLabel.text = self.layerName;  // set by TOCViewControler!
    }

    // test color
    self.view.backgroundColor = [UIColor yellowColor];
  
    if([self isMovingFromParentViewController]){
        NSLog(@"pushed: I am moving From my ParentViewController");
        //[self.mapView removeFromSuperview];
        //self.mapView = nil;
    }
    if([self isMovingToParentViewController]){
        NSLog(@"viewWillAppear:moving TO parent");
    }
    else{
        NSLog(@"viewWillAppear:unspecified");
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotification:)
     name:@"changedLayerNotification"
     object:nil];
    
   // [super viewWillAppear];
}

- (IBAction)showCurrentLocation:(id)sender
{
    if([CLLocationManager locationServicesEnabled]){
        [self.mapView centerAtPoint:[self.mapView.locationDisplay mapLocation] animated:YES];
        self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    }
    else{
        
        NSString *titleString = @"No Location Services";
        NSString *messageString = @"Your location could not be found, did you turn Location Services off?";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString message:messageString
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:  nil];
        [alert show];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // SET PROPERTIES
    [self setTitle:@"Map View"];
    [self setRestorationIdentifier:@"mainVC"];
    self.restorationClass = [self class];
    
    // CHECK internet connection
    BOOL wifiBoolean = [self checkForInternet];
    
    if(wifiBoolean == YES){
        
        // MAP IS LOADING
        
        self.activityIndicator.hidden= NO;
        [self.activityIndicator startAnimating];
        
        // MAP IS LOADING:this hard codes the length of time to display the indicator, that's not such a good approach because the network time might vary; this is the only place it works to call the displayIndicator
        [self performSelector:@selector(stopIndicator)withObject:nil afterDelay:15.0]; // 15 seconds
        
        // LOAD LAYERS
        //create the toc view controller, toc view controller changes visibility of the mapView without calling this viewDidLoad method
        self.tocViewController = [[TOCViewController alloc] initWithMapView:self.mapView];
        
        // LEGEND: calls method that adds the layer to the legend each time layer is loaded
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToLayerLoaded:) name:AGSLayerDidLoadNotification object:nil];
        
        NSURL *mapUrl = [NSURL URLWithString:kTiledLayerURL];
        AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
        [self.mapView addMapLayer:tiledLyr withName:@"Base Map"];
        
        /* TEST SNAP RETAIL LOCATOR see above for URL */
        
//        NSURL *retailUrl = [NSURL URLWithString:kSnapRetailURL];
//        AGSDynamicMapServiceLayer *dynamicRetailLyr = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:retailUrl];
//        [self.mapView addMapLayer:dynamicRetailLyr withName:@"Retail Locations"];
        
        /* LOAD DYNAMIC MAP, default is Benefits */
        
        if(self.mapName.length == 0){
            self.ersMapServiceURL = [NSURL URLWithString:@"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Benefits/MapServer"];
            self.mapName = @"Benefits";
           // NSLog(@"map URL = %@", self.ersMapServiceURL);
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
        
        // this is the title of the layer in the TOC - mapName must match definition in Map class! changed dynamically
        
        if(self.mapName.length !=0){
             [self.mapView addMapLayer:layer withName:self.mapName];
        }
        else{
            [self.mapView addMapLayer:layer withName:@"Benefits"];
        }
        
       /* STATES */
        
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
        //[self.mapView zoomToEnvelope:env animated:YES];
        
     
        
        // ADDED FOR GEOCODING FIND ADDRESS, also need for popup location!
        
        //set the delegate on the mapView so we get notifications for user interaction with the callout for geocoding
        self.mapView.callout.delegate = self;
        
        // TODO: not sure how this works, but without it, there seems to be a Thread Target Deallocated error?
        // create the graphics layer that the geocoding result
        // will be stored in and add it to the map
        self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
        [self.mapView addMapLayer:self.graphicsLayer withName:@"Search Layer"];
        
        if([CLLocationManager locationServicesEnabled]){
            
            NSLog(@"Location Services Enabled");
        
            // Switch through the possible location
            // authorization states
            switch([CLLocationManager authorizationStatus]){
                case kCLAuthorizationStatusAuthorized:
                {
                    NSLog(@"We have access to location services");
                          // CURRENT LOCATION marker: user's current location as starting point
                    [self.mapView.locationDisplay startDataSource];
                          //[self.mapView centerAtPoint:[self.mapView.locationDisplay mapLocation] animated:YES];
                    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
                }
                    break;
                case kCLAuthorizationStatusDenied:
                {
                    NSLog(@"Location services denied by user");
                    
                    AGSPoint *newPoint = [AGSPoint pointWithX:-93.032201 y:49.636213 spatialReference:self.mapView.spatialReference];
                    [self.mapView centerAtPoint:newPoint animated:NO];
                }
                    break;
                case kCLAuthorizationStatusRestricted:
                {
                    NSLog(@"Parental controls restrict location services");
                }
                    break;
                case kCLAuthorizationStatusNotDetermined:
                {
                    NSLog(@"Unable to determine, possibly not available");
                }
            }
              }
          else{
                  // TODO: locationServicesEnabled was set to NO -- this might be wrong
                    NSLog(@"Location Services Are Disabled");
                    AGSPoint *newPoint = [AGSPoint pointWithX:-77.0300 y:38.8900 spatialReference:self.mapView.spatialReference];
                    [self.mapView centerAtPoint:newPoint animated:NO];
                    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
              }
        
        
        // LEGEND: a data source that will hold the legend items
        self.legendDataSource = [[LegendDataSource alloc] init];
        self.legendViewController = [[LegendViewController alloc] initWithNibName:@"LegendViewController" bundle:nil];
        self.legendViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.legendViewController.legendDataSource = self.legendDataSource;
        
        // ADDED FOR POPUP BY LOCATION
        self.mapView.touchDelegate = self;
        
        //create identify task
        self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:self.ersMapServiceURL];
        
       // self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:[NSURL URLWithString:self.mapName ]];
        
        //NSLog(@"mapName passed to identifyTask = %@", self.mapName);
        self.identifyTask.delegate = self;
        
        //create identify parameters
        self.identifyParams = [[AGSIdentifyParameters alloc] init];
        
        self.mapView.showMagnifierOnTapAndHold = YES;
        self.mapView.allowMagnifierToPanMap = YES;
        
        // CCLocationManager
        /* not used, can be used to find distance between points */
//        self.locationManager = [[CLLocationManager alloc]init];
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        self.locationManager.delegate = self;
//        [self.locationManager startUpdatingLocation];
//        self.startLocation = nil;
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
    
   //[self.navigationController pushViewController:self.tocViewController animated:YES];
    
   [self presentViewController:self.tocViewController animated:YES completion:nil];
    
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
    [self.navigationController pushViewController:self.legendViewController animated:YES];
   // [self presentViewController:self.legendViewController animated:YES completion:nil];
    
}

#pragma mark -
#pragma mark  -- LOCATION CALLOUT: displays the box with related information for the location; AGSCalloutDelegate

- (void) didClickAccessoryButtonForCallout:(AGSCallout *) callout
{
    AGSGraphic* graphic = (AGSGraphic*) callout.representedObject;
    
    ResultsViewController *resultsVC = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil];
    
    resultsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    // this is the set to Exclude from the popup
       
    NSMutableDictionary * tempDictionary = [graphic allAttributes].mutableCopy;
    [tempDictionary removeObjectForKey:@"OBJECTID"];
    [tempDictionary removeObjectForKey:@"Shape"];
    [tempDictionary removeObjectForKey:@"Shape_Area"];
    [tempDictionary removeObjectForKey:@"Shape_Length"];
    
    // set our attributes/results into the results VC
    resultsVC.results = tempDictionary;
    [self.navigationController pushViewController:resultsVC animated:YES];
    //[self presentViewController:resultsVC animated:YES completion:nil];
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
    
    // TODO: why is this hard coded to 1???
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
                
        @try {
            
            // for each result, set the symbol and add it to the graphics layer
            for (AGSIdentifyResult* result in results) {
                result.feature.symbol = symbol;
                [self.graphicsLayer addGraphic:result.feature];
                _graphic = result.feature;
            ///    title = result.layerName;
                title = self.layerName;
            }
            
            self.mapView.callout.title = title; 
            self.mapView.callout.detail = @"Click for details";
            
            // Show callout for graphic
            [self.mapView.callout showCalloutAtPoint:self.mappoint forGraphic:_graphic animated:YES];
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
        @finally {
            //NSLog(@"finally");
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
 * the overview etc., there's only one URL for all the SNAP maps
*/

- (IBAction)showWebDetails:(id)sender {
    WebsiteViewController *webVC = [[WebsiteViewController alloc] initWithNibName:@"WebsiteViewController" bundle:nil];
    webVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    Map * myMap = [[Map alloc]init];
    
    /* pass the URL depending on which map is being displayed */
    webVC.pageURL = [myMap getURL:@"Benefits"];
    
    [self.navigationController pushViewController:webVC animated:YES];
}


/* display the UITableViewController that shows
 * the map options
*/
- (void)changeMap:(id)sender {
       
    MapPickerViewController *pickerViewController = [[MapPickerViewController alloc]initWithNibName:@"MapPickerViewController" bundle:nil];
    pickerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
   // [self.navigationController popViewControllerAnimated:YES]; // doesn't help
    [self.navigationController pushViewController:pickerViewController animated:YES];
  
}

#pragma mark - cleanup and startup

// ([self isDismissing] || [self isMovingFromParentViewController])

//-(void)viewWillDisappear:(BOOL)animated{
//    
//    if([self isBeingDismissed]){
//        NSLog(@"covered: I am being dismissed");
//    }
//    if([self isMovingFromParentViewController]){
//        NSLog(@"pushed: I am moving From my ParentViewController");
//        [self.mapView removeFromSuperview];
//        self.mapView = nil;
//    }
//    if([self isMovingToParentViewController]){
//        NSLog(@"moving TO parent");
//    }
//}

// destroy the legend data source so that when the user selects a different layer, the legend items only appear once
-(void)viewDidDisappear:(BOOL)animated{
    
    if(![self.legendDataSource isEqual:nil]){
        self.legendDataSource = nil;
    }
    if([self isBeingDismissed]){
        NSLog(@"covered: I am being dismissed");
    }
    if([self isMovingFromParentViewController]){
        NSLog(@"pushed: I am moving From my ParentViewController");
        //[self.mapView removeFromSuperview];
       // self.mapView = nil;  // THIS IS CALLED THE SECOND TIME
    }
    if([self isMovingToParentViewController]){
        NSLog(@"moving TO parent");
    }
    else{
        NSLog(@"unspecified");
    }
    
    // this approach releases memory, but the ViewController would have to be re-built
   // [self.mapView removeFromSuperview];
   //  self.mapView = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    NSUInteger ind = [[self.navigationController viewControllers] indexOfObject:self];
    if (ind == NSNotFound) {
        // do something, we're coming off the stack.
        NSLog(@"viewWillDisappear: coming off the stack");
    }
}

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
    
        if([[AGSDevice currentDevice] isIPad]){
            self.popOverController = nil;
        }
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

/* NOT USED */
//-(void)reachabilityChanged:(NSNotification*)note
//{
//    Reachability * reachStatus = [note object];
//
//    if([reachStatus isReachable])
//    {
//        _notificationLabel.text = @"ERS map service is available";
//    }
//    else
//    {
//        _notificationLabel.text = @"ERS map service is not available";
//    }
//}

// NOT CURRENTLY USED
//-(BOOL) checkConnectionStatus:(NSNotification*)note {
//
//    BOOL connectBoolean;
//
//    NetworkStatus internetStatus = [reach currentReachabilityStatus];
//
//    switch (internetStatus) {
//        case NotReachable:
//            NSLog(@"check Status: the internet is down.");
//            connectBoolean = NO;
//            break;
//
//        case ReachableViaWiFi:
//        {
//            NSLog(@"The internet is working via WIFI.");
//            connectBoolean = YES;
//            break;
//        }
//        case ReachableViaWWAN:
//        {
//            NSLog(@"The internet is working via WWAN.");
//            connectBoolean = YES;
//            break;
//        }
//    }
//    return connectBoolean;
//}




@end
