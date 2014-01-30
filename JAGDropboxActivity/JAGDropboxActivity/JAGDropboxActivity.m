//
//  DropboxShareActivity.m
//  ÜberHighlighter
//
//  Created by Jake Glass on 11/18/13.
//  Copyright (c) 2013 Squee! Apps. All rights reserved.
//

#import "JAGDropboxActivity.h"

@implementation JAGDropboxActivity

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

- (NSString *)activityType
{
    return @"Dropbox.upload";
}

- (NSString *)activityTitle
{
    return @"Upload to Dropbox";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"dropboxShareActivity-iPad.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
}

- (UIViewController *)activityViewController
{
    return nil;
}

- (void)performActivity
{
    /*
     //show a progress indicatour
     UIActivityIndicatorView *uploadingIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
     uploadingIndicator.backgroundColor=[UIColor grayColor];
     uploadingIndicator.frame=CGRectMake(0, 0, 300, 300);
     UILabel *loadingText=[[UILabel alloc]init];
     loadingText.textColor=[UIColor whiteColor];
     loadingText.frame=CGRectMake(75, 200, 250, 100);
     loadingText.text=@"Loading...";
     loadingText.font=[UIFont systemFontOfSize:35];
     
     [uploadingIndicator addSubview:loadingText];
     uploadingIndicator.center = CGPointMake(768 / 2.0, 370.0);
     
     uploadingIndicator.layer.cornerRadius = 8;
     uploadingIndicator.layer.masksToBounds = YES;
     
     [uploadingIndicator startAnimating];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:uploadingIndicator animated:YES completion:nil];
     */
    
    //DB session check
    DBSession* dbSession =
    [[DBSession alloc]
     initWithAppKey:@"APP_KEY"
     appSecret:@"APP_SECRET"
     root:kDBRootDropbox];
    [DBSession setSharedSession:dbSession];
   // dbSession.delegate=self;
    
    if ([[DBSession sharedSession] isLinked]) {
        
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *fileList=[prefs arrayForKey:@"fileList"];
    
    currentPath=[fileList objectAtIndex:([fileList count]-1)];
    
    
    filePathArray=[currentPath componentsSeparatedByString:@"/"];

    
        
    //prompt user for file upload directory path
        pickerNav=[[UINavigationController alloc]init];
        
    directoryPicker=[[JAGDirectoryPicker alloc]initWithStyle:UITableViewStylePlain];
    
    pickerNav.modalPresentationStyle=UIModalPresentationFormSheet;
        [pickerNav setNavigationBarHidden:NO];
     //   pickerNav.navigationItem.title=@"Dropbox Directory";
        
        directoryPicker.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(uploadFile)];
        
     
        
     [pickerNav addChildViewController:directoryPicker];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:pickerNav
 animated:YES completion:nil];

    }
    else{
        UIAlertView *notLinked=[[UIAlertView alloc]initWithTitle:@"Dropbox Upload Failed" message:@"You are not linked with Dropbox. To link, go to the settings menu and tap 'Link with Dropbox.'" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [notLinked show];
    }
    
    
    [self activityDidFinish:YES];
}

-(void)uploadFile
{
    [pickerNav dismissViewControllerAnimated:YES completion:nil];
    
   /* //activity indicatour setup here
    activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.backgroundColor=[UIColor grayColor];
    activityView.frame=CGRectMake(0, 0, 300, 300);
    UILabel *loadingText=[[UILabel alloc]init];
    loadingText.textColor=[UIColor whiteColor];
    loadingText.frame=CGRectMake(75, 200, 250, 100);
    loadingText.text=@"Loading...";
    loadingText.font=[UIFont systemFontOfSize:35];
    
    [activityView addSubview:loadingText];
    activityView.center = CGPointMake(768 / 2.0, 370.0);
    
    activityView.layer.cornerRadius = 8;
    activityView.layer.masksToBounds = YES;
    activityView.alpha=.4;
    
    [activityView startAnimating];

    [[[[UIApplication sharedApplication] keyWindow] rootViewController].view addSubview:[UIProgress]];
    */
    
    [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] keyWindow] rootViewController].view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *directory=[directoryPicker getDirectory];
        //uploadinar die fielen
        if([directory isEqualToString:@""]){
            directory=@"/";
        }
        [[self restClient] uploadFile:[filePathArray objectAtIndex:([filePathArray count]-1)] toPath:directory withParentRev:nil fromPath:currentPath];
    });
   
    
}
- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    //shut up the indicator of loadingness
    [MBProgressHUD hideHUDForView:[[[UIApplication sharedApplication] keyWindow] rootViewController].view animated:YES];
    
    UIAlertView *happy=[[UIAlertView alloc]initWithTitle:@"Success!" message:[NSString stringWithFormat:@"File uploaded successfully to path: %@", metadata.path] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [happy show];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    //shut up the indicator of loadingness
    
    UIAlertView *sad=[[UIAlertView alloc]initWithTitle:@"Failed to Upload" message:[NSString stringWithFormat:@"File upload failed with error - %@", error] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [sad show];
}

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            [currentDirectoryFiles arrayByAddingObject:metadata.path];
        }
    }
}

@end
