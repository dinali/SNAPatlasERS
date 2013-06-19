//
//  WebsiteViewController.m
//  TableOfContentsSample
//
//  Created by Dina Li on 6/3/13.
//
//

#import "WebsiteViewController.h"

@interface WebsiteViewController ()

@end

@implementation WebsiteViewController

@synthesize pageURL = _pageURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       // self.title = @"USDA ERS";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Website"];
    [self setRestorationIdentifier:@"websiteVC"];
    self.restorationClass = [self class];
    
    NSURL *url = self.pageURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [_webView loadRequest:request];
}


- (IBAction)goBack:(id)sender {
    
    MainViewController *mainVC = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
    
    [self presentViewController:mainVC animated:YES completion:nil];
}

#pragma mark - cleanup and startup

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
     if(self.view!=nil){
         [self setWebView:nil];
     }
}


+(UIViewController*)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    UIViewController * webViewController = [[WebsiteViewController alloc]initWithNibName:@"WebsiteViewController" bundle:nil];
    return webViewController;
}


@end
