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
//  Utility.h
//  General Services Administration
//

#import <Foundation/Foundation.h>

#import "ERSAppDelegate.h"

@interface Utility : NSObject {
    
}

+ (UIColor *)recallDescriptionTextColour;
+ (UIColor *)appTextColor;
+ (UIColor *)tableSeparatorColor;

+ (ERSAppDelegate *)appDelegate;

+ (NSString *)documentsDirectory;
+ (NSArray*)arrayFromPlist:(NSString *)fileName;
+ (NSArray *)dataFromPlist :(NSString *)plistPath;

+ (int)getCurrentImageCountWithWeekDay:(NSString *)weekday;
+ (BOOL)connectionSuccess;
+ (void)sendEmail:(NSString *)emailSubject:(NSString *)emailBody :(id)mailDelegate;
+ (void)launchMailAppOnDevice:(NSArray *)emailRecipients:(NSString *)emailSubject:(NSString *)emailBody;
+ (void)displayComposerSheet:(NSArray *)emailRecipients:(NSString *)emailSubject:(NSString *)emailBody delegate:(id)mailDelegate;
+ (CGRect )getFrameFromDict:(NSDictionary *)dict forPosition:(int)pos;
+ (BOOL)hasOperation:(NSOperation *)operation inQueue:(NSOperationQueue *)inputQueue;


+ (void)showAlertWithTitle:(NSString *)titleString message:(NSString *)messageString delegate:(id)delegate;
+ (void)removeWithAlphaEffect:(id)aView;
+ (void)addWithAlphaEffect:(id)aView;


+ (UILabel *)defaultLabel ;
+ (UIImageView *)searchHistorynSuggestionImage ;
+ (UIImageView *)searchHistoryAccessoryImage ;
+ (UILabel *)searchHistorynSuggestionText  ;
+ (UIButton *)clearHistoryButton ;
+ (UIButton *)searchImageWithTag:(int)tag ;
+ (UILabel *)imageFrameWithTag:(int)tag ;
+ (UILabel *)titleLabel ;
+ (UILabel *)contentLabel;
+ (UILabel *)urlLabel ;
+ (UILabel *)deepLinksLabel ;
+ (UIButton *)deepLinksButton;
+ (UILabel *)companyName ;
+ (UIImageView *)recallType;
+ (UILabel *)recallName;
+ (UILabel *)recallTypeName;
+ (UILabel *)unitCountLabel;

+ (UILabel *)datelabel;


@end
