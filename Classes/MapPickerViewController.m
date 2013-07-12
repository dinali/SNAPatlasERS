//
//  MapPickerViewController.m
//  TableOfContentsSample
//
//  Created by Dina Li on 6/4/13.
//
//

#import "MapPickerViewController.h"

@interface MapPickerViewController ()

@end

@implementation MapPickerViewController{
    
    NSArray *tableDataArray;
    NSArray *imagesArray;
    NSURL *webURL;
}

@synthesize aMap = _aMap;
@synthesize backButton = _backButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
       // self.title = @"USDA ERS";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setRestorationIdentifier:@"MapPickerVC"];
    self.restorationClass = [self class];
    
    self.aMap = [[Map alloc]init];
    
    tableDataArray = [self.aMap getTitles];
    imagesArray = [self.aMap getImages];
    webURL = [self.aMap getURL:@"SNAP"];
    
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(goBack:)];
    
    [self.navigationItem setLeftBarButtonItem:self.backButton animated:YES];
    
    self.title = @"Choose a map";    
    self.navigationItem.leftBarButtonItem = self.backButton;
}


- (void)goBack:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return imagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
   cell.imageView.image = [UIImage imageNamed:[imagesArray objectAtIndex:indexPath.row]];
   cell.textLabel.text = [tableDataArray objectAtIndex:indexPath.row];
   cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
   return cell;
}


#pragma mark - Table view delegate
// pass the info back to MainVC to create the new layer given these parameters
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [[self tableView].indexPathForSelectedRow row];
    
    NSArray *allTitlesArray = self.aMap.getTitles;
    
    NSString *newMapName = [allTitlesArray objectAtIndex:row];
    NSURL *newURL = [self.aMap getMapService:newMapName];
    
    /* NEW CODE */
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"changedMapNotification"
     object:newURL];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"lookWhoCalledNotification"
     object:@"MapPicker"];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"handleNameNotification"
     object:newMapName];
    
    [self.navigationController popViewControllerAnimated:YES];
   // mainVC.ersMapServiceURL = [self.aMap getMapService:mainVC.mapName];
   // NSLog(@"map url = %@", mainVC.ersMapServiceURL);
    
   //[self.navigationController pushViewController:mainVC animated:YES];
   // doesn't work because new selected map is not shown
    // pop the MapPicker but somehow re-set the map on MVC
   // [self presentViewController:mainVC animated:YES completion:nil];
    
}

#pragma mark - setup & cleanup
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if(self.view!=nil){
        self.aMap = nil;
        tableDataArray = nil;
        imagesArray = nil;
        webURL = nil;
        self.view = nil;
    }
    
  //  NSLog(@"MapPicker, didReceiveMemoryWarning");
}


+(UIViewController*)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    UIViewController * mpViewController = [[MapPickerViewController alloc]initWithNibName:@"MapPickerViewController" bundle:nil];
    return mpViewController;
}


@end
