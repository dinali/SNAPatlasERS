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
    
    MainViewController *mainVC = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
    
    [self presentViewController:mainVC animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
     if(self.view!=nil){
         self.aMap = nil;
         tableDataArray = nil;
         imagesArray = nil;
         webURL = nil;
     }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    MainViewController *mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    
    NSInteger row = [[self tableView].indexPathForSelectedRow row];
    
    NSArray *allTitlesArray = self.aMap.getTitles;
    
    mainVC.mapName = [allTitlesArray objectAtIndex:row];
    
    mainVC.ersMapServiceURL = [self.aMap getMapService:mainVC.mapName];
    NSLog(@"map url = %@", mainVC.ersMapServiceURL);
    
    // but we don't need the navigation controller anymore because MainViewController already has the navigation bar at the top
    [self presentViewController:mainVC animated:YES completion:nil];
}

#pragma mark - setup

+(UIViewController*)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    UIViewController * mpViewController = [[MapPickerViewController alloc]initWithNibName:@"MapPickerViewController" bundle:nil];
    return mpViewController;
}


@end
