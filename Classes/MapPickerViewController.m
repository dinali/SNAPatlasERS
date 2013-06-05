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
        self.title = @"USDA ERS";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _aMap = [[Map alloc]init];
    
    tableDataArray = [_aMap getTitles];
    imagesArray = [_aMap getImages];
    webURL = [_aMap getURL:@"SNAP"];
    
    _backButton = [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(goBack:)];
    
    [self.navigationItem setLeftBarButtonItem:_backButton animated:YES];
    
    self.title = @"Choose a map";    
    self.navigationItem.leftBarButtonItem = _backButton;
    
}


- (void)goBack:(id)sender {
    
    MainViewController *mainVC = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
    
    [self presentViewController:mainVC animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // which map to load first?
     NSInteger row = [[self tableView].indexPathForSelectedRow row];
    
    Map *atlasMap = [[Map alloc]init];
    NSArray *allTitlesArray = atlasMap.getTitles;
    
    mainVC.mapName = [allTitlesArray objectAtIndex:row];
    
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:mainVC animated:YES];
}

@end
