//
//  PickerNavigationController.m
//  TableOfContentsSample
//
//  Created by Dina Li on 6/4/13.
//
//

#import "PickerNavigationController.h"

@interface PickerNavigationController ()

@end

@implementation PickerNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(id)initWithRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setRestorationIdentifier:@"PickerNavigation"];
    self.restorationClass = [self class];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup

+(UIViewController*)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    UIViewController * pickerController = [[PickerNavigationController alloc]initWithNibName:@"pickerController" bundle:nil];
    return pickerController;
}

@end
