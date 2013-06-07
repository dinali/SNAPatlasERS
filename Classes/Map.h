//
//  Map.h
//  TableOfContentsSample
//
//  Created by Dina Li on 6/4/13.
//
//

#import <Foundation/Foundation.h>

@interface Map : NSObject

@property (strong,nonatomic) NSURL *pageURL; // webpage with description info
@property (strong,nonatomic) NSArray *urlArray; // contains the pageURL
@property (strong,nonatomic) NSArray *imageArray; // images for MapPickerViewController
@property (strong,nonatomic) NSArray *titleArray; // titles for MapPickerViewController
//@property (strong,nonatomic) NSArray *blurbArray; // text for MapPickerViewController
@property (strong,nonatomic) NSURL *gisURL; // ers gis ws URL for the map

- (NSURL*) getURL:(NSString*) mapName;
- (NSArray*) getImages;
- (NSArray*) getTitles;
//- (NSArray*) getBlurbs;
- (NSURL*) getMapService:(NSString*) mapName;

@end
