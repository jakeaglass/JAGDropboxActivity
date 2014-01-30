//
//  DropboxShareActivity.h
//  ÜberHighlighter
//
//  Created by Jake Glass on 11/18/13.
//  Copyright (c) 2013 Squee! Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "JAGDirectoryPicker.h"
#import "MBProgressHUD.h"



@interface JAGDropboxActivity : UIActivity
{
    JAGDirectoryPicker *directoryPicker;
    NSMutableArray *currentDirectoryFiles;
    
    
    NSArray *filePathArray;
    NSString *currentPath;
    
    UINavigationController *pickerNav;
    UIActivityIndicatorView *activityView;
}

@property (nonatomic, strong) DBRestClient *restClient;

@end
