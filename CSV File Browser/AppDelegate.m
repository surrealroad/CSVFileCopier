//
//  AppDelegate.m
//  CSV File Browser
//
//  Created by Jack James on 20/02/2014.
//  Copyright (c) 2014 Jack James. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
}

-(id) init {
    self = [super init];
    
    // initialise properties - this must be done here
    /*
    self.csvFilePath = [[NSURL alloc] init];
    self.destinationFolder = [[NSURL alloc] init];
     */
    self.fileActions = [[NSMutableArray alloc] init]; // required or will raise an exception
    self.sourceFolders = [[NSMutableArray alloc] init]; // ditto
    self.totalFileActions = 0;
    self.completedFileActions = 0;
    self.successfulFileActions = 0;
    self.logMessage = @"Application started.";
    
    /*
     FileActionItem *sampleAction = [[FileActionItem alloc] init];
    [self.fileActions insertObject:sampleAction atIndex:[self.fileActions count]];
    [self.fileActions insertObject:sampleAction atIndex:[self.fileActions count]];
    [self.sourceFolders insertObject:@"default folder" atIndex:[self.sourceFolders count]];
     */
    
    return self;
}

- (IBAction)chooseDestinationFolder:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    
    // adjust defaults http://stackoverflow.com/questions/3396081/how-can-i-use-nssavepanel-to-select-a-directory
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setTitle:@"Browse for output folder"];
    
    // https://developer.apple.com/library/mac/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/UsingtheOpenandSavePanels/UsingtheOpenandSavePanels.html#//apple_ref/doc/uid/TP40010672-CH4-SW1
    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        // or use  [panel beginWithCompletionHandler:^(NSInteger result){ for unattached window
        if (result == NSFileHandlingPanelOKButton) {
            NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
            
            // Open  the document.
            
            self.destinationFolder = theDoc;
        }
        
    }];
}

- (IBAction)chooseCSVFile:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    
    // adjust defaults http://stackoverflow.com/questions/3396081/how-can-i-use-nssavepanel-to-select-a-directory
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setTitle:@"Browse for CSV file"];
    NSArray *allowedTypes = [NSArray arrayWithObjects:@"CSV",@"csv",nil];
    [panel setAllowedFileTypes:allowedTypes];
    
    // https://developer.apple.com/library/mac/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/UsingtheOpenandSavePanels/UsingtheOpenandSavePanels.html#//apple_ref/doc/uid/TP40010672-CH4-SW1
    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        // or use  [panel beginWithCompletionHandler:^(NSInteger result){ for unattached window
        if (result == NSFileHandlingPanelOKButton) {
            NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
            
            self.csvFilePath = theDoc;
            self.csvArray = [NSArray arrayWithContentsOfCSVFile:self.csvFilePath.path];
            self.logMessage = [[NSString alloc] initWithFormat:@"%lu lines read",(unsigned long)self.csvArray.count];
            [self populateFileActions];
        }
        
    }];

}

- (IBAction)addSourceFolder:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    
    // adjust defaults http://stackoverflow.com/questions/3396081/how-can-i-use-nssavepanel-to-select-a-directory
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setTitle:@"Add a search folder"];
    
    // https://developer.apple.com/library/mac/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/UsingtheOpenandSavePanels/UsingtheOpenandSavePanels.html#//apple_ref/doc/uid/TP40010672-CH4-SW1
    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        // or use  [panel beginWithCompletionHandler:^(NSInteger result){ for unattached window
        if (result == NSFileHandlingPanelOKButton) {
            NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
            
            // Open  the document.
            
            [self.sourceFolderController addObject:theDoc];
        }
        
    }];

}

- (IBAction)processFileActions:(id)sender {
    self.completedFileActions = 0;
    [self updateFileActionStatus];
    if(self.totalFileActions<1) self.logMessage = @"Nothing to process";
    else if (self.sourceFolders.count<1) self.logMessage = @"Please specify at least one search folder";
    else if (self.destinationFolder.path.length<1) self.logMessage = @"Please specify a destination folder";
    else {
        [self.progressBar startAnimation:self];
        [self.progressBar setIndeterminate:NO];
        // run asynchronously in background
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.fileActions enumerateObjectsUsingBlock:^(FileActionItem *fileAction, NSUInteger idx, BOOL *stop) {
                // look for source file
                // iterate over sourceFolders
                for(id sourceFolder in self.sourceFolders) {
                    // http://stackoverflow.com/questions/3696736/how-to-change-nsurl-file-name
                    NSURL *sourceFile = [NSURL URLWithString:fileAction.filename relativeToURL:sourceFolder];
                    // http://stackoverflow.com/questions/1927754/testing-file-existence-using-nsurl
                    NSError *err;
                    if ([sourceFile checkResourceIsReachableAndReturnError:&err] != NO) {
                        fileAction.sourcePath = sourceFile;
                        break;
                    }
                }
                if(fileAction.sourcePath ==nil) {
                    fileAction.status = @"File not found";
                    // set status
                    self.completedFileActions++;
                    [self updateFileActionStatus];
                } else {
                    // attempt to copy file to destination
                    fileAction.destinationPath = [NSURL URLWithString:fileAction.filename relativeToURL:self.destinationFolder ];
                    // It's good habit to alloc/init the file manager for move/copy operations,
                    // just in case you decide to add a delegate later.
                    NSFileManager* theFM = [[NSFileManager alloc] init];
                    // Just try to copy the file.
                    NSError* fmError;
                    if ([theFM copyItemAtURL:fileAction.sourcePath toURL:fileAction.destinationPath error:&fmError]) {
                        fileAction.status = @"OK";
                        self.successfulFileActions++;
                        NSLog(@"Copied %@",fileAction.destinationPath);
                    } else {
                        // If an error occurs, it's probably because the file already exists
                        fileAction.status = [fmError localizedDescription];
                    }
                    // set status
                    self.completedFileActions++;
                    [self updateFileActionStatus];
                }
            }];
            
            [[self progressBar] stopAnimation:self];
            [self updateFileActionStatus];
        });
    }
}

- (void)populateFileActions {
    // TODO: run this asynchronously so ui doesn't hang
    // clear the array
    [self.fileActions removeAllObjects];
    // create a new set
    NSMutableSet *fileList = [[NSMutableSet alloc] init];
    // http://stackoverflow.com/questions/992901/how-do-i-iterate-over-an-nsarray
    [self.csvArray enumerateObjectsUsingBlock:^(id csvRow, NSUInteger idx, BOOL *stop) {
        // loop through fields
        [csvRow enumerateObjectsUsingBlock:^(id field, NSUInteger idx, BOOL *stop) {
            // move into list
            if([[field description] length]>0) [fileList addObject:[field description]];
        }];
    }];
    
    // http://stackoverflow.com/questions/2538748/check-duplicate-objects-in-nsmutablearray
    [fileList enumerateObjectsUsingBlock:^(id filename, BOOL *stop) {
        // create new action for each item
        FileActionItem *fileaction = [[FileActionItem alloc] init];
        fileaction.filename = filename;
        // http://stackoverflow.com/questions/6164505/nstableview-bindings-how-to-add-a-row
        [self.fileActionController addObject:fileaction];
    }];
    [self updateFileActionStatus];
}

-(void)updateFileActionStatus {
    // http://stackoverflow.com/questions/2509612/how-do-i-update-a-progress-bar-in-cocoa-during-a-long-running-loop
    //NOTE: It is important to let all UI updates occur on the main thread,
    //so we put the following UI updates on the main queue.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.totalFileActions = self.fileActions.count;
        NSString *status = [[NSString alloc] initWithFormat:@"%i files to process, %i files copied successfully out of %i.",(self.totalFileActions - self.completedFileActions), self.successfulFileActions, self.totalFileActions];
        self.logMessage = status;
        double completion = 0;
        if(self.totalFileActions>0) completion = ((double)self.completedFileActions / (double)self.totalFileActions) * 100;
        [[self progressBar] setDoubleValue:completion];
        if(self.totalFileActions>0) NSLog(@"Complete: %i Total: %i (%f)",self.completedFileActions,self.totalFileActions,completion);
        [[self progressBar] displayIfNeeded];
    });
}
@end
