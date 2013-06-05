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
    
    _titleArray = [NSArray arrayWithObjects:@"Benefits", @"Participation", @"Participation Per Person in Poverty", @"Socioeconomic indicators", nil];
    return _titleArray;
}

-(NSArray*) getImages{
    
    _imageArray = [NSArray arrayWithObjects:@"SNAPbenefits2010.png", @"SNAPparticipation2010.png", @"SNAPperperson2010.png", @"SocioeconomicChildPoverty2010.png", nil];
    return _imageArray;
}

// if we add the other Atlases, add the related URLS here
-(NSURL*) getURL:mapName{
    
    if([mapName isEqual: @"SNAP"])
    {
        NSString *siteString = @"http://www.ers.usda.gov/data-products/supplemental-nutrition-assistance-program-(snap)-data-system.aspx";
        _pageURL = [NSURL URLWithString:siteString];
    }
    return _pageURL;
}

/* ERS does not have one line descriptions for the individual SNAP maps, placeholder */
//- (NSArray) getBlurbs{
    
   // blurbArray = [NSArray arrayWithObjects:@"SNAPbenefits2010.png", @"SNAPparticipation2010.png", @"SNAPperperson2010.png", @"SocioeconomicChildPoverty2010.png", nil];
//    return blurbArray;
//}


// Initialize thumbnails


@end
