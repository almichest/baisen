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

+ (void)showTwitterPostViewWithMessage:(NSString *)message onViewController:(UIViewController *)viewController
{
    SLComposeViewController *twitterPostViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterPostViewController setInitialText:message];
    [viewController presentViewController:twitterPostViewController animated:YES completion:nil];
}

+ (void)showFacebookPostViewWithMessage:(NSString *)message onViewController:(UIViewController *)viewController
{
    SLComposeViewController *facebookPostViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookPostViewController setInitialText:message];
    [viewController presentViewController:facebookPostViewController animated:YES completion:nil];
}

@end
