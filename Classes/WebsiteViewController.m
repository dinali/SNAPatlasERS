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
   // NSURL *url =  [NSURL URLWithString: @"http://www.ers.usda.gov"];
    
    NSURL *url = _pageURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // NSLog(@"viewDidLoad url = %@", url);
    
    [_webView loadRequest:request];
    
    [self setTitle:@"Website"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
}

- (IBAction)goBack:(id)sender {
    
    MainViewController *mainVC = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
    
    [self presentViewController:mainVC animated:YES completion:nil];
}
@end
