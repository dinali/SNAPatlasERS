/*
 * This project constitutes a work of the United States Government and is
 * not subject to domestic copyright protection under 17 USC § 105.
 *
 * However, because the project utilizes code licensed from contributors
 * and other third parties, it therefore is licensed under the MIT
 * License. http://opensource.org/licenses/mit-license.php. Under that
 * license, permission is granted free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the conditions that any appropriate copyright notices and this
 * permission notice are included in all copies or substantial portions
 * of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

//
//  Utility.m
//  General Services Administration
//


#import "Utility.h"
#import "Reachability.h"



@implementation Utility


+ (UIColor *)appTextColor {
	return [UIColor colorWithRed:0.23137 green:0.36078 blue:0.67058 alpha:1];
}

+ (UIColor *)recallDescriptionTextColour {
	return [UIColor colorWithRed:0.511787 green:0.511787 blue:0.511787 alpha:1];
}

+ (UIColor *)tableSeparatorColor {
	return [UIColor clearColor];
}

+ (ERSAppDelegate *)appDelegate {
    return (ERSAppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSArray*)arrayFromPlist:(NSString *)fileName {
	NSString *writablePath = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
	return [self dataFromPlist:writablePath];
}

+ (NSArray *)dataFromPlist :(NSString *)plistPath {
	
	NSArray *plistDetails =  [[NSArray alloc] initWithContentsOfFile:plistPath];
	
	if([plistDetails count] > 0) {
		return plistDetails;
	}
	else {
		return [[NSArray alloc] init];
	}
	
}

+ (int)getCurrentImageCountWithWeekDay:(NSString *)weekday {
	if (weekday) {
		if([weekday isEqualToString:@"Sunday"]) {
			return 0;
		} else if([weekday isEqualToString:@"Monday"]) {
			return 1;
		} else if([weekday isEqualToString:@"Tuesday"]) {
			return 2;
		} else if([weekday isEqualToString:@"Wednesday"]) {
			return 3;
		} else if([weekday isEqualToString:@"Thursday"]) {
			return 4;
		} else if([weekday isEqualToString:@"Friday"]) {
			return 5;
		} else if([weekday isEqualToString:@"Saturday"]) {
			return 6;
		} else {
			return 0;
		}
	} else {
		return 0;
	}
    
}

+ (BOOL)connectionSuccess {
	//Test for Internet Connection
	Reachability *r = [Reachability reachabilityWithHostName: @"http://m.usa.com"];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL internet;
	if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
		internet = NO;
	} else {
		internet = YES;
	}
	return internet;
}

//For getting the frame from passed initial and final frames for a fixed position
+ (CGRect )getFrameFromDict:(NSDictionary *)dict forPosition:(int)pos {
	NSArray *posArray;
	if (pos == 1) {//initialFrame
		posArray = [dict objectForKey:@"iFrame"];
	} else {
		posArray = [dict objectForKey:@"finalFrame"];
	}
	
	CGRect frame = CGRectMake([[posArray objectAtIndex:0] floatValue], [[posArray objectAtIndex:1] floatValue], [[posArray objectAtIndex:2] floatValue], [[posArray objectAtIndex:3] floatValue]);
    
	return frame;
}


//For launching the mail app
+ (void)sendEmail:(NSString *)emailSubject:(NSString *)emailBody :(id)mailDelegate {
	
	NSMutableArray *emailRecipients = [[NSMutableArray alloc] init];
	[emailRecipients addObject:@"musa.gov@mail.fedinfo.gov"];
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    emailSubject = @"USA.gov Mobile Inquiry";
	emailBody = @"<br /> <br /><br /><br /> <br /><br /><br /><br /> <br /><br /><br /><br /> <br /><br />[FORMGEN]";
	if (mailClass != nil){
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail]) {
            [Utility displayComposerSheet:emailRecipients:emailSubject:emailBody delegate:mailDelegate];
        }
        else {
            [Utility launchMailAppOnDevice:emailRecipients:emailSubject:emailBody];
        }
    }
    else {
        [Utility launchMailAppOnDevice:emailRecipients:emailSubject:emailBody];
    }
}


+ (void)launchMailAppOnDevice:(NSArray *)emailRecipients:(NSString *)emailSubject:(NSString *)emailBody {
	
	NSString *text = @"";
    int i;
    int recipientCount = [emailRecipients count];
    for(i=0; i<recipientCount; i++) {
        text = [text stringByAppendingString:[NSString stringWithFormat:@"%@,",[emailRecipients objectAtIndex:i]]];
    }
	
	NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@", text, emailSubject, emailBody];
	mailString = [mailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
	
}

// Displays an email composition interface inside the application. Populates all the Mail fields.
+ (void)displayComposerSheet:(NSArray *)emailRecipients:(NSString *)emailSubject:(NSString *)emailBody delegate:(id)mailDelegate {
    MFMailComposeViewController *composeView = [[MFMailComposeViewController alloc] init];
    composeView.mailComposeDelegate = mailDelegate;
    [composeView setSubject:emailSubject];
	[composeView setToRecipients:emailRecipients];
    [composeView setMessageBody:emailBody isHTML:YES];
	[mailDelegate presentModalViewController:composeView animated:YES];
    [composeView release];
}



#pragma mark -
+ (BOOL)hasOperation:(NSOperation *)operation inQueue:(NSOperationQueue *)inputQueue {
	for (NSOperation *x in [inputQueue operations]) {
		if ([[x class] isEqual:[operation class]]) {
			return YES;
		}
	}
	
	return NO;
}

+ (void)showAlertWithTitle:(NSString *)titleString message:(NSString *)messageString delegate:(id)delegate {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString message:messageString
												   delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:  nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark viewAnimations

+ (void)removeWithAlphaEffect:(id)aView {
	
	[UIView beginAnimations:@"removeWithAlphaEffect" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.8];
	[aView setAlpha:0.0];
	[UIView commitAnimations];
}

+ (void)addWithAlphaEffect:(id)aView {
	
	[aView setAlpha:0.0];
	[UIView beginAnimations:@"addWithAlphaEffect" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.8];
	[aView setAlpha:1.0];
	[UIView commitAnimations];
}


#pragma mark UI methods
+ (UILabel *)defaultLabel {
	
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.frame = CGRectMake(10, 2, 200, 36);
	label.tag = defaultTag;
    label.adjustsFontSizeToFitWidth = NO;
    label.textColor = [UIColor blackColor];
	label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

+ (UIImageView *)searchHistorynSuggestionImage {
	UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    imageView.frame = CGRectMake(5, 12, 20, 20);
	imageView.tag = searchHistoryImageTag;
	return imageView;
}

+ (UIImageView *)searchHistoryAccessoryImage {
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
	imageView.frame = CGRectMake(290, 10, 20, 20);
    imageView.tag = searchHistoryAccessoryImageTag;
    return imageView;
}

+ (UILabel *)searchHistorynSuggestionText  {
    UILabel *label = [[self class] defaultLabel];
    label.adjustsFontSizeToFitWidth = NO;
	label.frame = CGRectMake(35, 5, 200, 34);
	label.font = [UIFont systemFontOfSize:14];
    label.textAlignment= UITextAlignmentLeft;
    label.tag = searchHistoryLabelTag;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

+ (UIButton *)clearHistoryButton {
	
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.userInteractionEnabled = NO;
    [button setImage:[UIImage imageNamed:@"clear_history_button.png"] forState:UIControlStateNormal];
    button.alpha = 0.0;
    button.tag = clearHistoryButtonTag;
    return button;
}

+ (UIButton *)searchImageWithTag:(int)tag {
    UIButton *image = [UIButton buttonWithType:UIButtonTypeCustom];
    image.tag = tag;
	[image setBackgroundImage:nil forState:UIControlStateNormal];
    return image;
}

+ (UILabel *)imageFrameWithTag:(int)tag {
	
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.tag = tag;
    label.alpha = 0.75;
    label.backgroundColor = [UIColor clearColor];
    return label;
}

+ (UILabel *)titleLabel {
	
    UILabel *titleLabel = [self defaultLabel];
    titleLabel.frame = CGRectMake(10, 8, 300, 20);
	titleLabel.numberOfLines = 1;
    titleLabel.textAlignment = UITextAlignmentLeft;
    titleLabel.tag = titleTag;
    titleLabel.textColor = [UIColor colorWithRed:0.23 green:0.36 blue:0.67 alpha:1];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
	
	
    return titleLabel;   
}

+ (UILabel *)contentLabel {
	
    UILabel *contentLabel = [self defaultLabel];
    contentLabel.frame = CGRectMake(10, 30, 300, 50);
    contentLabel.numberOfLines = 3;
	contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textColor = [UIColor colorWithRed:0.51171875 green:0.51171875 blue:0.51171875 alpha:1.0];
    contentLabel.textAlignment = UITextAlignmentLeft;
    contentLabel.tag = contentTag;
    return contentLabel;
}

+ (UILabel *)urlLabel {
	
    UILabel *urlLabel = [self defaultLabel];
    urlLabel.frame = CGRectMake(10, 82, 300, 15);
    urlLabel.font = [UIFont systemFontOfSize:12];
    urlLabel.textColor = [UIColor colorWithRed:0.18 green:0.592 blue:0.18 alpha:1];
    urlLabel.tag = urlTag;
    return urlLabel;
}

+ (UILabel *)deepLinksLabel {
	
    UILabel *distanceLabel = [self defaultLabel];
    distanceLabel.frame = CGRectMake(70, 47, 150, 20);
    distanceLabel.font = [UIFont systemFontOfSize:12];
    distanceLabel.textColor = [UIColor lightGrayColor];
    return distanceLabel;
}

+ (UIButton *)deepLinksButton {
	
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 100, 200, 20);
    button.backgroundColor = [UIColor clearColor];
	
    return button;
}

+ (UILabel *)companyName {
    UILabel *label = [[self class] defaultLabel];
    label.adjustsFontSizeToFitWidth = NO;
	label.frame = CGRectMake(70, 5, 240, 30);
	label.font = [UIFont boldSystemFontOfSize:15];
    label.textAlignment= UITextAlignmentLeft;
    label.numberOfLines = 0;
    label.tag = recallCompanyLabelTag;
    label.textColor = [UIColor colorWithRed:0.23 green:0.36 blue:0.67 alpha:1];
    label.backgroundColor = [UIColor clearColor];
    return label;
	
}

+ (UIImageView *)recallType {
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    imageView.frame = CGRectMake(5, 5, 60, 60);
    imageView.tag = recallImageTag;
    return imageView;
}

+ (UILabel *)recallName {
    UILabel *label = [[self class] defaultLabel];
    label.adjustsFontSizeToFitWidth = NO;
	label.frame = CGRectMake(70, 30, 240, 70);
	label.font = [UIFont systemFontOfSize:14];
	label.numberOfLines = 4;
    label.textAlignment= UITextAlignmentLeft;
    label.tag = recallNameLabelTag;
    label.textColor = [UIColor colorWithRed:0.514 green:0.514 blue:0.514 alpha:1];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

+ (UILabel *)recallTypeName {
    UILabel *label = [[self class] defaultLabel];
    label.adjustsFontSizeToFitWidth = NO;
	label.frame = CGRectMake(0, 60, 70, 20);
	label.font = [UIFont boldSystemFontOfSize:12];
    label.textAlignment= UITextAlignmentCenter;
    label.tag = recallTypeLabelTag;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

+ (UILabel *)unitCountLabel {
    UILabel *label = [[self class] defaultLabel];
    label.adjustsFontSizeToFitWidth = NO;
	label.frame = CGRectMake(150, 100, 160, 20);
	label.font = [UIFont systemFontOfSize:12];
	label.textAlignment= UITextAlignmentLeft;
    label.numberOfLines = 1;
    label.tag = recallUnitLabelTag;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

+ (UILabel *)datelabel {
    UILabel *label = [[self class] defaultLabel];
    label.adjustsFontSizeToFitWidth = NO;
	label.frame = CGRectMake(70, 100, 75, 20);
	label.font = [UIFont boldSystemFontOfSize:12];
    label.textAlignment= UITextAlignmentLeft;
    label.numberOfLines = 0;
    label.tag = recallDateLabelTag;
    label.textColor = [UIColor colorWithRed:0.353 green:0.353 blue:1.0 alpha:1];
    label.backgroundColor = [UIColor clearColor];
    return label;
}


@end
