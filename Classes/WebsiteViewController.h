//
//  WebsiteViewController.h
//  TableOfContentsSample

//  DESCRIPTION: displays the ERS webpage associated with the selected map; parameter: url

//  Created by Dina Li on 6/3/13.
//
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface WebsiteViewController : UIViewController <UIViewControllerRestoration>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) NSURL *pageURL; // passed from MainViewController;

- (IBAction)goBack:(id)sender;

@end
