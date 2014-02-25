//
//  AppDelegate.h
//  CSV File Browser
//
//  Created by Jack James on 20/02/2014.
//  Copyright (c) 2014 Jack James. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileActionItem.h"
#import "CHCSVParser.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSArrayController *fileActionController;
@property (weak) IBOutlet NSArrayController *sourceFolderController;

@property (strong) NSURL *csvFilePath;
@property (assign) BOOL isCSVValid;
@property (strong) NSArray *csvArray;
@property (strong) NSURL *destinationFolder;
@property (strong) NSMutableArray *sourceFolders;
@property (strong) NSMutableArray *fileActions;
@property (strong) NSString *logMessage;

- (IBAction)chooseDestinationFolder:(id)sender;
- (IBAction)chooseCSVFile:(id)sender;
- (IBAction)addSourceFolder:(id)sender;

- (void)populateFileActions;
- (void)updateFileActionStatus;

@end
