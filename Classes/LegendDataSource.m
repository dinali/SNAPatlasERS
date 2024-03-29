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

#import "LegendDataSource.h"


@implementation LegendDataSource

@synthesize legendInfos=_legendInfos;
@synthesize layerName = _layerName;

- (id)init {
    self = [super init];
    if (self) {
		//Initialize member variables.
		//legendInfos will hold objects containing information for each legend item
		self.legendInfos = [[NSMutableArray alloc] init];
        
        // layer name
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLayerNotification:) name:@"handleLayerNotification" object:nil];
        
        
    }
    return self;
}

/* NEW CODE */

// pass layerName
-(void)updateLayerNotification:(NSNotification *)pNotification
{
    self.layerName = (NSString*)[pNotification object];
    
    if (self.layerName.length == 0){
        self.layerName = @"2011 total SNAP benefits";
    }
    
    NSLog(@"NotificationCenter layerName = %@", self.layerName);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// THIS IS CALLED BY THE OBSERVER WHEN A LAYER IS ADDED, IT GETS THE LEGENDINFO
- (void) addLegendForLayer:(AGSLayer *)layer{
	//Check type of layer
	if ([layer isKindOfClass: [AGSDynamicMapServiceLayer class]]) {
		
		//Get the service info
		AGSMapServiceInfo* msi =  ((AGSDynamicMapServiceLayer*)layer).mapServiceInfo;

		//Legend only supported for services from  10 Service Pack 1 or above
		if(msi.version>=10.01){ 
			msi.delegate = self;
			[msi retrieveLegendInfo];
		}else {
			// NSLog(@"Skipping layer [%@]. ArcGIS Service must be version 10 SP1 or above",msi.URL );
		}

		
	}else if ([layer isKindOfClass: [AGSTiledMapServiceLayer class]]) {
		//Get the service info
		AGSMapServiceInfo* msi =  ((AGSTiledMapServiceLayer*)layer).mapServiceInfo;

		//Legend only supported for services from  10 Service Pack 1 or above
		if(msi.version>=10.01){ 
			msi.delegate = self;
			[msi retrieveLegendInfo];

		} else {
			// NSLog(@"Skipping layer [%@]. ArcGIS Service must be version 10 SP1 or above",msi.URL);
		}
	
	}else if ([layer isKindOfClass: [AGSFeatureLayer class]]) {
		AGSFeatureLayer* featLayer = (AGSFeatureLayer*)layer;

		//Loop through the Types in feature layer
		NSArray* featTypes = featLayer.types;
		for (int i=0; i<[featTypes count]; i++) {
			AGSFeatureType* type = (AGSFeatureType*)[featTypes objectAtIndex:i];
			
			//Get a Template for the Type
			AGSFeatureTemplate* template = [type.templates objectAtIndex:0];
			
			//Get information of Template to display as a legend item
			LegendInfo* info = [[LegendInfo alloc] init];
			info.image = [featLayer.renderer swatchForGraphic:template.prototype geometryType:featLayer.geometryType size:CGSizeMake(20, 20)];
			info.name = type.name;
			[self.legendInfos addObject:info];
		}
		//Loop through the Templates in feature layer
		NSArray* featTemplates = featLayer.templates;
		for (int i=0; i<[featTemplates count]; i++) {
			AGSFeatureTemplate* template = (AGSFeatureTemplate*) [featTemplates objectAtIndex:i];

			//Get information of Template to display as a legend item
			LegendInfo* info = [[LegendInfo alloc] init];
			info.image = [featLayer.renderer swatchForGraphic:template.prototype geometryType:featLayer.geometryType size:CGSizeMake(20, 20)];
			info.name = template.name;
			[self.legendInfos addObject:info];
		}		

		//Reload the table to display newly added legend items
		[self reload];
	}else {
		//skip other layer types
		//legend not supported
		NSLog(@"Skipping layer of type %@. Legend not supported.",[layer class]);
	}
}

#pragma mark -
#pragma mark AGSMapServiceInfoDelegate
//TODO: maybe need to pass the mapServiceInfo using the NSNotificationCenter??
// THIS IS RELATED TO THE ADDLEGENDFORLAYER METHOD
- (void)mapServiceInfo:(AGSMapServiceInfo *)mapServiceInfo operationDidRetrieveLegendInfo:(NSOperation*)op {
    
        NSArray* layerInfos = mapServiceInfo.layerInfos;
        
        //Loop through all sub-layers
        for (int i=0; i<[layerInfos count]; i++) {
            
            AGSMapServiceLayerInfo* layerInfo = (AGSMapServiceLayerInfo*)[layerInfos objectAtIndex:i];
            
              //   NSLog(@"LEGEND name = %@", layerInfo.name);
            NSLog(@"LEGEND layerInfo.name = %@", layerInfo.name);
            
            // pass an identifier for the layer that you want to display
            if(self.layerName.length == 0){
                self.layerName = (@"2011 total annual SNAP benefits");
            }
            
            if([layerInfo.name isEqual: self.layerName]){
                NSArray* legendLabels = layerInfo.legendLabels;
                NSArray* legendImages = layerInfo.legendImages;
                
                // HAVE to extract just the sublayer being displayed...
                LegendInfo* legendInfo = [[LegendInfo alloc] init];
                legendInfo.name = @"1,000 dollars";
                [self.legendInfos addObject:legendInfo];
                
                for(int j=0;j<[legendImages count];j++){
                    
                    //Store info for each legend item
                    LegendInfo* legendInfo = [[LegendInfo alloc] init];
                    
                    legendInfo.detail = [legendLabels objectAtIndex:j];
                    legendInfo.image = [legendImages objectAtIndex:j];
                    [self.legendInfos addObject:legendInfo];
                }
            }
        }
        //Reload the table to display newly added legend items
        [self reload];
    
}

- (void)mapServiceInfo:(AGSMapServiceInfo *)mapServiceInfo operation:(NSOperation*)op didFailToRetrieveLegendInfoWithError:(NSError*)error{
	NSLog(@"Error encountered while fetching legend : %@",error);
}


- (void) reload {
	[_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	_tableView = tableView;
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//Number of legend items we have
    NSLog(@"LEGEND numberOfRows = %d", [self.legendInfos count]);
	return [self.legendInfos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	// Set up the cell with the legend image, text, and detail
	LegendInfo *legendInfo = [self.legendInfos objectAtIndex:indexPath.row];
    
	cell.detailTextLabel.text = legendInfo.detail;
	cell.textLabel.font = [UIFont systemFontOfSize:12.0];
	cell.textLabel.text = legendInfo.name;
	cell.imageView.image = legendInfo.image;
    
    //NSLog(@"cellForRowAtIndexPath");
	
    return cell;
}


@end

//A convenience class to hold information about each legend item
@implementation LegendInfo
@synthesize image = _image,name=_name,detail=_detail;


@end