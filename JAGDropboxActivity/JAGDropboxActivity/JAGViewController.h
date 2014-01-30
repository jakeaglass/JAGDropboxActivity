//
//  JAGViewController.h
//
//  Created by Jake Glass on 1/29/14.
//  Copyright (c) 2014 Jake Glass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAGDropboxActivity.h"
#import "MBProgressHUD.h"

@interface JAGViewController : UIViewController
{
    NSString *fileName;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) JAGDropboxActivity *dbUploader;
@property (strong, nonatomic) UIActivityViewController *shareMenu;
@property (strong, nonatomic) UIPopoverController *sharePopup;


@end
