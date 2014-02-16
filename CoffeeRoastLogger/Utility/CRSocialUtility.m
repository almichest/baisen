//
//  CRSocialUtility.m
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/16.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRSocialUtility.h"
#import <Social/Social.h>

@implementation CRSocialUtility

+ (void)showTwitterPostViewWithMessage:(NSString *)message image:(UIImage *)image onViewController:(UIViewController *)viewController completion:(CRSocialUtilityCompletion)completion
{
    SLComposeViewController *twitterPostViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterPostViewController setInitialText:message];
    [twitterPostViewController addImage:image];
    twitterPostViewController.completionHandler = ^(SLComposeViewControllerResult result) {
        switch (result) {
            case SLComposeViewControllerResultDone :
                completion(CRSocialUtilitySharingResultSuccess);
                break;
            case SLComposeViewControllerResultCancelled :
            default :
                completion(CRSocialUtilitySharingResultFailure);
        }
    };
    [viewController presentViewController:twitterPostViewController animated:YES completion:nil];
}

+ (void)showFacebookPostViewWithMessage:(NSString *)message image:(UIImage *)image onViewController:(UIViewController *)viewController completion:(CRSocialUtilityCompletion)completion
{
    SLComposeViewController *facebookPostViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookPostViewController setInitialText:message];
    [facebookPostViewController addImage:image];
    facebookPostViewController.completionHandler = ^(SLComposeViewControllerResult result) {
        switch (result) {
            case SLComposeViewControllerResultDone :
                completion(CRSocialUtilitySharingResultSuccess);
                break;
            case SLComposeViewControllerResultCancelled :
            default :
                completion(CRSocialUtilitySharingResultFailure);
        }
    };
    [viewController presentViewController:facebookPostViewController animated:YES completion:nil];
}

@end
