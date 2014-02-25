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
            
            // Open  the document.
            
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

- (void)populateFileActions {
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
    NSString *status = [[NSString alloc] initWithFormat:@"%lu files to process.",(unsigned long)self.fileActions.count];
    self.logMessage = status;
}
@end
