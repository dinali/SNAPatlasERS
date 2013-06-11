//
//  Map.m
//  TableOfContentsSample
//
//  Created by Dina Li on 6/4/13.
//
//

#import "Map.h"

@implementation Map

@synthesize pageURL = _pageURL;
@synthesize urlArray = _urlArray;
@synthesize imageArray = _imageArray;
@synthesize titleArray = _titleArray;
//@synthesize blurbArray = _blurbArray;

-(NSArray*) getTitles{
    
    self.titleArray = [NSArray arrayWithObjects:@"Benefits", @"Participation", @"Participation Per Person in Poverty", @"Socioeconomic indicators", nil];
    return self.titleArray;
}

-(NSArray*) getImages{
    
    self.imageArray = [NSArray arrayWithObjects:@"SNAPbenefits2010.png", @"SNAPparticipation2010.png", @"SNAPperperson2010.png", @"SocioeconomicChildPoverty2010.png", nil];
    return self.imageArray;
}

// if we add the other Atlases, add the related URLS here
-(NSURL*) getURL:mapName{
    
    if([mapName isEqual: @"Benefits"]){
        NSString *siteString = @"http://www.ers.usda.gov/data-products/supplemental-nutrition-assistance-program-(snap)-data-system.aspx";
        self.pageURL = [NSURL URLWithString:siteString];
    }
    return self.pageURL;
}

// returns the ERS map service url so the map display can be changed when the user selects a map using Change Map
-(NSURL*) getMapService:mapName{
    
    NSString *siteString = nil;
    if([mapName isEqual: @"Benefits"])
    {
        siteString = @"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Benefits/MapServer";
    }
    else if([mapName isEqual:@"Participation"]){
        siteString = @"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Participation/MapServer";
    }
    else if([mapName isEqual:@"Participation Per Person in Poverty"]){
        siteString = @"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Participation_Poverty/MapServer";
    }
    else if([mapName isEqual:@"Socioeconomic indicators"]){
        siteString = @"http://gis.ers.usda.gov/ArcGIS/rest/services/fa_socioeconomic/MapServer";
    }

    self.pageURL = [NSURL URLWithString:siteString];
    return self.pageURL;
}

/* ERS does not have one line descriptions for the individual SNAP maps, placeholder */
//- (NSArray) getBlurbs{
    
   // blurbArray = [NSArray arrayWithObjects:@"SNAPbenefits2010.png", @"SNAPparticipation2010.png", @"SNAPperperson2010.png", @"SocioeconomicChildPoverty2010.png", nil];
//    return blurbArray;
//}



@end
