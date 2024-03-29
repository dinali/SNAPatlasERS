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

#import "TOCViewController.h"
#import "LayerInfo.h"
#import "LayerInfoCell.h"
#import "LayerLegendCell.h"

@interface TOCViewController() <LayerInfoCellDelegate, UITableViewDelegate, UITableViewDataSource>



//this is the map level layer info object, acting as the invisible root of the entire tree. 
@property (nonatomic, strong) LayerInfo *mapViewLevelLayerInfo;

//navbar to control the view
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;

//tableview to display the layers.
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *checkedLayer;

//adds the layer to the array of layer views to be displayed in the Table of Contents.
//This is called when the layer is loaded.
- (void)insertLayer:(AGSLayer*)layer atIndex:(int)index;

//method to add/remove the layers to/from the ToC
- (void)processMapLayers;

//to dismiss the view. 
- (IBAction)doneButtonPressed;

@end


@implementation TOCViewController

@synthesize mapView = _mapView;
@synthesize mapViewLevelLayerInfo = _mapViewLevelLayerInfo;
@synthesize popOverController = _popOverController;
@synthesize navBar = _navBar;
@synthesize tableView = _tableView;

// access the mapview that was created in MainViewController and passed here in ViewDidLoad()
- (id)init {
    self = [super init];
    if (self) {
        
        //create the map level layer info object with id of -2 and layer view as nil.
      //  self.mapViewLevelLayerInfo = [[LayerInfo alloc] initWithLayer:nil layerID:-2 name:@"Map" target:nil];
        
        // map Name for MainVC title
        // TODO: safe to delete this? this does nothing
       // self.checkedLayer = @"TESTING";
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"handleNameNotification"
         object:self.checkedLayer];
    }
    return self;
}

// obsolete?
- (id)initWithMapView:(AGSMapView *)mapView
{
    self = [super initWithNibName:@"TOCViewController" bundle:nil];
    if (self) {
      //  self.mapView = mapView;
        
        //display list of sublayers 
        [self processMapLayers];
        
        //create the map level layer info object with id of -2 and layer view as nil.
        self.mapViewLevelLayerInfo = [[LayerInfo alloc] initWithLayer:nil layerID:-2 name:@"Map" target:nil];
    }
    // map Name for MainVC title
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"handleNameNotification"
     object:self.checkedLayer];
    
    return self;
}

// pass the new mapView to TOCVC
//-(void)getMapViewNotification:(NSNotification *) mNotification{
//    self.mapView = (AGSMapView *)[mNotification object];
//    NSLog(@"TOC new mapView number of layers = %d", self.mapView.mapLayers.count);
//    
//}

// when the user clicks the Icon
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //create the map level layer info object with id of -2 and layer view as nil.
    self.mapViewLevelLayerInfo = [[LayerInfo alloc] initWithLayer:nil layerID:-2 name:@"Map" target:nil];
    [self processMapLayers];
}

// ????
-(void)viewWillDisappear:(BOOL)animated{
  //  self.mapView = nil;
}

#pragma mark -
#pragma mark LayerInfoCellDelegate
/* CHANGES the display of the map view layer depending on which layer was selected in the TOC, does not trigger ViewDidLoad in MainViewController, so there's no way the legend or Location popup data will be refreshed!! */
- (void)layerVisibilityChanged:(BOOL)visibility forCell:(UITableViewCell *)cell
{
    //retrieve the corresponding cell
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    
    //get the layer info represented by the cell
    LayerInfo *layerInfo = [[self.mapViewLevelLayerInfo flattenElementsWithCacheRefresh:NO withLegend:YES] objectAtIndex:(cellIndexPath.row)];
    
    NSLog(@"TOC layerName %@", layerInfo.layerName);
    
    [layerInfo setVisible:visibility];
    
    // is this redundant? also in doneButtonPressed
    // pass the name of the checked sublayer to MainVC
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"handleLayerNotification"
     object:layerInfo.layerName];
                                                                    
}

#pragma mark -
#pragma mark Helper Methods

// DESCRIPTION: this is where the layer is actually inserted into the TOC; also see ProcessMapLayers; adds the title to the TOC
- (void)insertLayer:(AGSLayer*)layer atIndex:(int)index
{
    //creates the layer info node for a layer in the map after it is loaded in the map view. and the delegate method is called after the tree is constructed. 
     LayerInfo *layerInfo = [[LayerInfo alloc] initWithLayer:layer layerID:-1 name:layer.name target:self];
    
    // delete the Search, States, and Base maps so they don't appear in the Table of Contents - doesn't make a difference here
    
    NSString *string = layerInfo.layerName;
    
  //  NSLog(@"layerName = %@", string);
    
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    // leave this in case you decide to add one of these back in the TOC
     if (([trimmedString isEqualToString: @"Search Layer"]) ||
         ([trimmedString isEqualToString: @"States"]) ||
         ([trimmedString isEqualToString: @"Base Map"]))
     {
         // don't do anything - exclude them
     }
    else
     {
         [self.mapViewLevelLayerInfo insertChild:layerInfo atIndex:0];
     }
}

- (void)doneButtonPressed {
    
    // map Name for MainVC title
   // [[NSNotificationCenter defaultCenter]
    // postNotificationName:@"handleNameNotification"
   //  object:self];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"handleLayerNotification"
     object:self.checkedLayer];  // sublayer name

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"lookWhoCalledNotification"
     object:@"TOC"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //uses the descendant count with legend. 
    return [self.mapViewLevelLayerInfo descendantAndLegendCount];
}


// Contains both the legend and the list of topics
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LayerInfoCellIdentifier = @"LayerInfoCell";
    static NSString *LayerLegendCellIdentifier = @"LayerLegendCell";
    
    LayerInfoCell *layerInfoCell;
    LayerLegendCell *layerLegendCell;
    
    //obtain the object contained in the flat array of the tree nodes, that includes the legend. 
    id tempObject = [[self.mapViewLevelLayerInfo flattenElementsWithCacheRefresh:NO withLegend:YES] objectAtIndex:indexPath.row];
    
    //if it is a legend info class, form a legend info cell. 
    if([tempObject isKindOfClass:[LayerInfo class]])
    {
        LayerInfo *layerInfo = (LayerInfo *)tempObject;    
        layerInfoCell = [[LayerInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:LayerInfoCellIdentifier 
                                                        level:[layerInfo levelDepth] - 1 
                                          canChangeVisibility:layerInfo.canChangeVisibility
                                                   visibility:layerInfo.visible
                                                     expanded:layerInfo.inclusive];   
      
        //assign the title.
        layerInfoCell.valueLabel.text = layerInfo.layerName;
        
        NSLog(@"layer name = %@", layerInfo.layerName);
        
        //assign the delegate to call the method when the visibility is changed. 
        layerInfoCell.layerInfoCellDelegate = self;
        
        //no selection style. 
        layerInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return layerInfoCell;
    }
    else
    {
        LegendElement *legentElement = (LegendElement *)tempObject;  
        layerLegendCell = [[LayerLegendCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:LayerLegendCellIdentifier 
                                                            level:legentElement.level];
        
        //assign the title. 
        layerLegendCell.legendLabel.text = legentElement.title;
        
        //assign the image. 
        layerLegendCell.legendImage.image = legentElement.swatch;
        
        //no selection style. 
        layerLegendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return layerLegendCell;
    } 
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //obtain the object contained in the flat array of the tree nodes, that includes the legend. 
	id tempObject = [[self.mapViewLevelLayerInfo flattenElementsWithCacheRefresh:NO withLegend:YES] objectAtIndex:indexPath.row];
    
    //do nothing if this is a legend cell. 
    if([tempObject isKindOfClass:[LegendElement class]])
        return;
    
    //else expand or contract the layer. 
    LayerInfo *layerInfo = (LayerInfo *)tempObject;    
	layerInfo.inclusive = !layerInfo.inclusive;	
	[self.mapViewLevelLayerInfo flattenElementsWithCacheRefresh:YES withLegend:YES];
    
    //NSLog(@"checked layer name = %@", layerInfo.layerName);
    self.checkedLayer = layerInfo.layerName; // pass this to MainViewController label
    
    //reload the table. 
	[tableView reloadData];
}

#pragma mark -
#pragma mark Helper Methods
// DESCRIPTION: this is what loads the map layers into the TOC
- (void)processMapLayers
{
    //pruning the tree to remove the layers that are not in the mapview anymore.       
    NSMutableArray *layersToBeRemoved = [NSMutableArray array];
    for (LayerInfo *layerInfo in self.mapViewLevelLayerInfo.children)
    {       
        //bool indicating whether the layer is present or not. 
        BOOL layerPresent = NO;
        
        //iterate through the map layers to check the layer has been removed since previous display. 
        for (AGSLayer *layer in self.mapView.mapLayers) {
            if([layer.name isEqualToString:layerInfo.layerName])
            {
                //layer is present
                layerPresent = YES;
                break;
            }               
        }
        if(layerPresent)
        {
            //if layer is present continue to the next one. 
            continue;
        }
        else
        {
            //if the layer is not present, then add the corresponding layerinfo to the array of layers to be removed. 
            [layersToBeRemoved addObject:layerInfo]; 
        }
    }   
    
    //iterating through the "to be removed" layers, if any, as they were removed from the mapview. 
    for (LayerInfo *layerInfo in layersToBeRemoved)
    {
        //remove the layerinfo.
        [self.mapViewLevelLayerInfo removeChildWithLayerName:layerInfo.layerName];
    }

    //adds the layers to the tree ( (starting from top most layer, going to bottom)
    for (int i = 0, j=self.mapView.mapLayers.count-1; i < self.mapView.mapLayers.count ; i++,j--)
    {     
        //get the agsLayer from the mapLayers array 
        AGSLayer *agsLayer = [self.mapView.mapLayers objectAtIndex:j];
        
        //check to see if the agsLayer exists in the toc or not. 
        if(![self.mapViewLevelLayerInfo containsChildWithLayerName:agsLayer.name])
        {
            //if not, check for whether it has been loaded
            if(agsLayer.loaded)
            {            
                //if loaded, insert the layer's 'LayerInfo' at the appropriate index of the ToC
                [self insertLayer:agsLayer atIndex:i];
            }
            else
            {
                //if not loaded yet, add a kvo on the loaded property of the agsLayer. 
                [agsLayer addObserver:self forKeyPath:@"loaded" options:0 context:(__bridge void *)([NSNumber numberWithInt:i])];
            }
        }
    }  
    
    //refresh the flattened tree cache. 
    [self.mapViewLevelLayerInfo flattenElementsWithCacheRefresh:YES withLegend:YES];
      
    //reload the table view. 
    [self.tableView reloadData];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{    
    AGSLayer *layer = (AGSLayer *)object;
    
    //obtain the index from the context
    NSNumber *index = (__bridge NSNumber *) context;
    
    //insert the layer's 'LayerInfo' at the appropriate index of the ToC
    [self insertLayer:layer atIndex:index.intValue];
    
    //remove the observer. 
    [layer removeObserver:self forKeyPath:@"loaded"];
    
    //refresh the flattened tree cache.
    [self.mapViewLevelLayerInfo flattenElementsWithCacheRefresh:YES withLegend:YES];
    
    //reload the table view.
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setRestorationIdentifier:@"tocVC"];
    self.restorationClass = [self class];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

+(UIViewController*)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    UIViewController * tocViewController = [[TOCViewController alloc]initWithNibName:@"TOCViewController" bundle:nil];
    return tocViewController;
}

@end
