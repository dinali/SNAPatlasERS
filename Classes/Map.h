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
@property (strong,nonatomic) NSArray *titleArray; // titless for MapPickerViewController
//@property (strong,nonatomic) NSArray *blurbArray; // text for MapPickerViewController

- (NSURL*) getURL:(NSString*) mapName;
- (NSArray*) getImages;
- (NSArray*) getTitles;
//- (NSArray*) getBlurbs;

@end
