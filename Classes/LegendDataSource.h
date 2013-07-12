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


#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface LegendDataSource : NSObject <UITableViewDataSource,AGSMapServiceInfoDelegate> {
	UITableView* _tableView;
	NSMutableArray* _legendInfos;
}

- (id) init;
- (void) reload;
- (void) addLegendForLayer:(AGSLayer*)layer;
- (void) updateLayerNotification:(NSNotification *)pNotification;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)mapServiceInfo:(AGSMapServiceInfo *)mapServiceInfo operationDidRetrieveLegendInfo:(NSOperation*)op;
- (void)mapServiceInfo:(AGSMapServiceInfo *)mapServiceInfo operation:(NSOperation*)op didFailToRetrieveLegendInfoWithError:(NSError*)error;


@property (nonatomic, strong) NSMutableArray* legendInfos;
@property (nonatomic, strong) NSString *layerName;

@end

@interface LegendInfo : NSObject {
@protected
    NSString *_name;
    UIImage *_image;
	NSString *_detail;
    NSString *sublayerName;
}

@property (nonatomic,strong) NSString *name; // root name, e.g., Benefits
@property (nonatomic,strong) NSString *detail;
@property (readwrite,strong) UIImage *image;
@property (nonatomic,strong) NSString *sublayerName; // lower level name - leaf node, 2010 total SNAP benefits

@end