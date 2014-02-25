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
    self.csvParser = [[CSVParser alloc]init];
    self.csvParser.csvFilePath = @"Test path.csv";
    self.destinationFolder = [[NSURL alloc] initFileURLWithPath:@"/"];
    self.fileActions = [[NSMutableArray alloc] init];
    self.sourceFolders = [[NSMutableArray alloc] init];
    
    FileActionItem *sampleAction = [[FileActionItem alloc] init];
    [self.fileActions insertObject:sampleAction atIndex:[self.fileActions count]];
    
    [self.sourceFolders insertObject:@"default folder" atIndex:[self.sourceFolders count]];
    
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
@end
