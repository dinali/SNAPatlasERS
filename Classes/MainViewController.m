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
@synthesize whoCalled = _whoCalled; // name of the viewcontroller triggering viewWillAppear; passed by NotificationCenter
@synthesize mapViewLevelLayerInfo = _mapViewLevelLayerInfo;

#define kTiledLayerURL @"http://gis2.ers.usda.gov/ArcGIS/rest/services/Background_Cache/MapServer"
#define kSnapRetailURL @"http://www.snapretailerlocator.com/ArcGIS/rest/services/retailer/MapServer" //SNAP retail locator
#define kMapServiceURL @"http://gis2.ers.usda.gov/ArcGIS/rest/services/Reference2/MapServer" // states

// THIS IS A TEST

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

// gets the new URL
-(void)handleMapNotification:(NSNotification *)mapNotifictation{
    
    self.ersMapServiceURL = (NSURL*)[mapNotifictation object];
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// pass layerName
-(void)updateLayerNotification:(NSNotification *)pNotification
{
    self.layerName = (NSString*)[pNotification object];
        
    if (self.layerName.length == 0){
        self.layerName = @"2011 total SNAP benefits";
    }
    
   //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

// get the new map name
-(void)updateNameNotification:(NSNotification *)nameNotification
{
    self.mapName = (NSString*)[nameNotification object];
    if([self.mapName isEqual:nil]){
        self.mapName = @"Benefits";
    }
}

// triggered when the TOCVC calls viewWillAppear
-(void)whoCalledNotification:(NSNotification *) whoNotification{
    
    self.whoCalled = (NSString*)[whoNotification object];
    NSLog(@"who called = %@", self.whoCalled);
}


// DON'T DELETE THIS, the iPad version will thrown an exception
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
    
    if(self){
        self.whoCalled = @"MainVC";
    }
    return self;
}

// display the map name or the layer name
/*You should use the viewWillAppear method in MainViewController to reset the map and add new layers to reflect the map that the user picked. If many of the layers are common between the maps, you don't need to reset the map, you can individually remove & add layers.
 */
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSLog(@"new map URL = %@", self.ersMapServiceURL); // use the value passed from MapPickerVC using the notification center

    NSError *error = nil;
    
    if(self.ersMapServiceURL == nil){
        // set the default here
        self.ersMapServiceURL = [NSURL URLWithString:@"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Benefits/MapServer"];
        self.mapName = @"Benefits";
    }
    
    // don't reload if we're here because the user fiddled with the TOC layers
    if([self.whoCalled isEqualToString:@"TOC"]){
        self.currentMapLabel.text = self.layerName;
    }
    
    // remove the topmost, leave the 2 base maps
    // viewDidLoad = 3 layers - delete additional layers from changing maps
    if([self.whoCalled isEqualToString:@"MapPicker"] || [self.whoCalled isEqualToString:@"MainVC"] || [self.whoCalled isEqualToString:@"Legend"]){
        
        AGSLayer *removeLayer;
        NSArray *oldLayersArray = self.mapView.mapLayers;
        
        if (self.mapView.mapLayers.count > 3){
                    for(int j=0;j < 2;j++){
                        removeLayer = [oldLayersArray objectAtIndex:(j + 2)];
                        [self.mapView removeMapLayer:removeLayer];
                    }
        }
    
// it should pick up the new URL from the NotificationCenter to create the new map from the URL
    AGSMapServiceInfo *info = [AGSMapServiceInfo mapServiceInfoWithURL:self.ersMapServiceURL error:&error];
    AGSDynamicMapServiceLayer* layer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithMapServiceInfo: info];
    
    if(self.mapName.length !=0){
        [self.mapView addMapLayer:layer withName:self.mapName];
    }
    else{
        [self.mapView addMapLayer:layer withName:@"Benefits"];
    }

    // ADDING THE LAYER HERE WILL TRIGGER THE OBSERVER THAT CREATES THE LEGEND
        
    AGSLayerInfo *firstInfo = [layer.mapServiceInfo.layerInfos objectAtIndex:0];
    NSString *firstTitle = firstInfo.name;
        
    NSLog(@"sublayer name = %@", firstTitle);
    self.currentMapLabel.text = firstTitle;
        
    [self setTitle:self.mapName]; // controls the name in the nav bar
        
   // NSLog(@"mapName = %@", self.mapName);
  //  NSLog(@"layerName = %@", self.layerName);
    
    // modify this if the TOC view controller changes selection
    if(layer.loaded)
    {
        // only show the Xth layer
        layer.visibleLayers= [NSArray arrayWithObjects:[NSNumber numberWithInt:0], nil];
        layer.opacity = .8;
        layer.name = self.mapName;
    }
    
    // CALLOUT:create identify task, get the new URL
    self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:self.ersMapServiceURL];
    self.identifyTask.delegate = self;
        
    //create identify parameters
    self.identifyParams = [[AGSIdentifyParameters alloc] init];
    
    // TODO: LEGEND - very tricky!!
   // self.legendDataSource = [[LegendDataSource alloc] init];
   // self.legendViewController.legendDataSource = self.legendDataSource;
    
    // TOC
    self.tocViewController.mapView = nil; // delete it first
    self.tocViewController.mapView = self.mapView; // refresh it here
      
 } // end outer if MapPicker or MainVOC
}

- (IBAction)showCurrentLocation:(id)sender
{
    if([CLLocationManager locationServicesEnabled]){
        [self.mapView centerAtPoint:[self.mapView.locationDisplay mapLocation] animated:YES];
        self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    }
    else{
        // TODO: set default to Washington D.C.
        // 1
        //CLLocationCoordinate2D zoomLocation;
        //zoomLocation.latitude = 39.281516;
        //zoomLocation.longitude= -76.580806;
        
        // 2
        //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        
        // 3
        //[_mapView setRegion:viewRegion animated:YES];
        
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
    [self setRestorationIdentifier:@"mainVC"];
    self.restorationClass = [self class];
    
    // CHECK internet connection
    BOOL wifiBoolean = [self checkForInternet];
    
    if(wifiBoolean == YES){
        
        // MAP IS LOADING
        
        self.activityIndicator.hidden= NO;
        [self.activityIndicator startAnimating];
        
        // this hard codes the length of time to display the indicator, that's not such a good approach because the network time might vary; this is the only place it works to call the displayIndicator
        [self performSelector:@selector(stopIndicator)withObject:nil afterDelay:15.0]; // 15 seconds
        
        // map URL
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMapNotification:) name:@"changedMapNotification" object:nil];
        
       
        // layer name
        [[NSNotificationCenter defaultCenter] addObserver:self
                        selector:@selector(updateLayerNotification:) name:@"handleLayerNotification" object:nil];
        // map name
        [[NSNotificationCenter defaultCenter] addObserver:self
                        selector:@selector(updateNameNotification:) name:@"handleNameNotification" object:nil];
        
        // which controller is calling
        [[NSNotificationCenter defaultCenter]addObserver:self
        selector:@selector(whoCalledNotification:)name:@"lookWhoCalledNotification" object:nil];
        
        // LOAD LAYERS
    
        NSURL *mapUrl = [NSURL URLWithString:kTiledLayerURL];
        AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
        [self.mapView addMapLayer:tiledLyr withName:@"Base Map"];
                
    /* dynamic layer is loaded in viewWillAppear */
        
       /* STATES */
        
        NSURL *stateMapUrl = [NSURL URLWithString:kMapServiceURL];
        AGSDynamicMapServiceLayer *dynamicLyr = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:stateMapUrl];
        [self.mapView addMapLayer:dynamicLyr withName:@"States"];
        
        // ADD THE LEGEND OBSERVER
        // add legend for a layer; moving it here doesn't make a difference, it still adds it for every layer
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToLayerLoaded:) name:AGSLayerDidLoadNotification object:nil];
        
        //Zooming to an initial envelope with the specified spatial reference of the map.
        AGSSpatialReference *sr = [AGSSpatialReference webMercatorSpatialReference];
        AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-14314526
                                                    ymin:2616367
                                                    xmax:-7186578
                                                    ymax:6962565
                                        spatialReference:sr];
        //[self.mapView zoomToEnvelope:env animated:YES];
        
        //create the toc view controller, toc view controller changes visibility of the mapView without calling this viewDidLoad method
        
        self.tocViewController = [[TOCViewController alloc]init];
        
        // GPS enabled
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
                  // TODO: locationServicesEnabled was set to NO -- this should be D.C.
                    NSLog(@"Location Services Are Disabled");
                    AGSPoint *newPoint = [AGSPoint pointWithX:-77.0300 y:38.8900 spatialReference:self.mapView.spatialReference];
                    [self.mapView centerAtPoint:newPoint animated:NO];
                    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
              }
        
        // TODO: ADD THE LEGEND OBSERVER -- this results in a lot of extra processing because it's called for each layer and for every time viewWillAppear is called; skip it for now
     // add legend for a layer;
     //   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToLayerLoaded:) name:AGSLayerDidLoadNotification object:nil];
        
        // TODO: legend not implemented; LEGEND: a data source that will hold the legend items
       // self.legendViewController = [[LegendViewController alloc] initWithNibName:@"LegendViewController" bundle:nil];
       // self.legendViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
        // ASSIGN DELEGATES
        // ADDED FOR GEOCODING FIND ADDRESS, also need for popup location!
        
        //set the delegate on the mapView so we get notifications for user interaction with the callout for geocoding
        self.mapView.callout.delegate = self;
        self.mapView.layerDelegate = self;
        self.mapView.touchDelegate = self;
        self.mapView.showMagnifierOnTapAndHold = YES;
        self.mapView.allowMagnifierToPanMap = YES;
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

// maybe need to call this again when the layer changes?? it should work automatically from then on
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
    
   // self.tocViewController = [[TOCViewController alloc]init];
   [self presentViewController:self.tocViewController animated:YES completion:nil];
}

// TODO because the legend is visible in the Layers
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
    
    // this doesn't seem to make a difference?
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
    
    NSLog(@"AGSPoint = %@", mappoint);
    
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
    //TODO: not updating title correctly
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
    
    [self.navigationController pushViewController:pickerViewController animated:YES];
  
}

#pragma mark - error handling for loading layers

- (void) mapView:(AGSMapView*) mapView didLoadLayerForLayerView:(UIView *) layerView {
  	NSLog(@"Layer added successfully");
}

- (void) mapView:(AGSMapView*) mapView  failedLoadingLayerForLayerView:(UIView *) layerView withError:(NSError*) error {
    NSLog(@"Error: %@",error);
}


#pragma mark - cleanup and startup

// destroy the legend data source so that when the user selects a different layer, the legend items only appear once
-(void)viewDidDisappear:(BOOL)animated{
    
    if(![self.legendDataSource isEqual:nil]){
        self.legendDataSource = nil;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    NSUInteger ind = [[self.navigationController viewControllers] indexOfObject:self];
    if (ind == NSNotFound) {
        // do something, we're coming off the stack.
        //NSLog(@"viewWillDisappear: coming off the stack");
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
    
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.view = nil;
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
