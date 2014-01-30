JAGDropboxActivity
==================

A simple UIActivity subclass in iOS 7 that enables dropbox uploading on iPad.

##Dependencies
- MBProgressHUD class
- Dropbox SDK

##Classes & Files
- JAGDropboxActivity
- JAGDirectoryPicker (works through JAGDropboxActivity)
- dropboxShareActivity-iPad.png (and the @2x version for retina)

I've also included a few key implementation examples (though the demo app doesn't do anything real) with JAGViewController.

##Implementation
####1. Add the necessary files to your Xcode project (above).
####2. Get an App secret and App key from Dropbox's developer portal.
JAGDropboxActivity.m contains:
```
//DB session check
DBSession* dbSession =
[[DBSession alloc]
 initWithAppKey:@"APP_KEY"
 appSecret:@"APP_SECRET"
 root:kDBRootDropbox];
[DBSession setSharedSession:dbSession];
```
####3. Change some file- and application-specific details in your implementation code.
In the demo JAGViewController.m, I included three methods that go through the save process: saveButton (triggered on button tap), which shows an alertView that prompts the user for a filename, which then runs saveProcess. The saveProcess method contains this code: 
```
//check for the filetype--did the user add one? if not, you'll probably want to add an extension
if ([fileName rangeOfString:@".pdf"].location == NSNotFound) {
    fileName=[fileName stringByAppendingString:@".pdf"];
}

//<INSERT DOCUMENT SAVING CODE HERE>

//get the path of the file we just saved
NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];


//Set up some NSUserDefaults objects so we can save the filePaths and access them later
NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
NSMutableArray *currentFileList=[prefs objectForKey:@"fileList"];

//if there's nothing in NSUserDefaults yet, create the array
if(currentFileList==nil){
    currentFileList=[[NSMutableArray alloc]init];
}

//make a new array to overwrite the old one with
NSMutableArray *uberList=[NSMutableArray arrayWithArray:currentFileList];
[uberList setObject:filePath atIndexedSubscript:[uberList count]];

//add it to
[prefs setObject:uberList forKey:@"fileList"];
[prefs synchronize];
```
You'll need to implement your own app-specific file-saving code here. You'll also want to change the file extension (from pdf) in the if statement so you don't end up with extensionless files or some with the wrong extension entirely.

All this is extremely vital to making everything work. The above code adds to the "fileList" array set in NSUserDefaults, and add the path of your saved file to it. Then, later in the implementation method, you simply initialise the UIActivityViewController popover with the new dbUploader (an instance of JAGDropboxActivity) and present the activity view from a popup. 

If the user clicks "Upload to Dropbox," the activity we've created, then it executes and pulls out the last filePath (a string) on the "fileList" NSUserDefaults array and uploads that file to Dropbox. This calls JAGDirectoryPicker at some point and the user is allowed to pick from Dropbox in which directory they want to save the file.

####4. Make sure you have Dropbox authorized
If your app doesn't authorize itself with Dropbox for upload anywhere, I can guarantee this won't work. Make sure you're linked.

####5. Have fun and tell me if there's anything wrong
My goal in publishing this is for it to be useful and also a tool for sharing programming knowledge. If you should have any questions or comments, or on the very slim chance that I've made a mistake somewhere, drop me a line via jake at jglass.me

##More?
[http://jglass.me](http://jglass.me)