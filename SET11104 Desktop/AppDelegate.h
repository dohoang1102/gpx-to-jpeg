//
//  AppDelegate.h
//  SET11104 Desktop
//
//  Created by Jules Coynel on 09/11/2011.
//  Copyright (c) 2011 Jules Coynel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "GPXParserDelegate.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSDate *startMonitoringDate;
    
    NSTextFieldCell *loadPhotosLabel;
    NSTextFieldCell *loadPhotosLabelTime;
    NSTextFieldCell *generateFileLabelTime;
    NSTextFieldCell *generateFileGCDLabelTime;
    NSTextFieldCell *parseGPXLabel;
    NSTextFieldCell *parseGPXLabelTime;
    NSTextFieldCell *loadPhotosInfoLabelTime;
    NSTextFieldCell *matchGPSPhotosLabelTime;
    NSTextFieldCell *matchGPSPhotosLabel;
    NSTextFieldCell *tagPhotosLabelTime;
    NSTextFieldCell *tagPhotosGCDLabelTime;
    NSTextFieldCell *tagPhotosGCDLabel;
    NSLevelIndicator *progress;

    GPXParserDelegate *parserDelegate;
    
    NSMutableArray *selectedPhotosURLs; // URLs of photo files
    
    NSMutableDictionary *selectedPhotosInfo; // File name & timestamp
    
    NSArray *locations; // Loaded from GPX file

    NSMutableArray *photosWithCoordinates; // Photos with their matching location
}
@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) NSDate *startMonitoringDate;

@property (strong) IBOutlet NSTextFieldCell *loadPhotosLabel;
@property (strong) IBOutlet NSTextFieldCell *loadPhotosLabelTime;
@property (strong) IBOutlet NSTextFieldCell *generateFileLabelTime;
@property (strong) IBOutlet NSTextFieldCell *generateFileGCDLabelTime;
@property (strong) IBOutlet NSTextFieldCell *parseGPXLabelTime;
@property (strong) IBOutlet NSTextFieldCell *parseGPXLabel;
@property (strong) IBOutlet NSTextFieldCell *matchGPSPhotosLabelTime;
@property (strong) IBOutlet NSTextFieldCell *matchGPSPhotosLabel;
@property (strong) IBOutlet NSTextFieldCell *tagPhotosLabelTime;
@property (strong) IBOutlet NSTextFieldCell *tagPhotosGCDLabelTime;
@property (strong) IBOutlet NSTextFieldCell *tagPhotosGCDLabel;
@property (strong) IBOutlet NSLevelIndicator *progress;

@property (nonatomic, retain) GPXParserDelegate *parserDelegate;
@property (nonatomic, retain) NSMutableArray *selectedPhotosURLs;
@property (nonatomic, retain) NSMutableDictionary *selectedPhotosInfo;
@property (nonatomic, retain) NSMutableArray *photosWithCoordinates;
@property (nonatomic, retain) NSArray *locations;


- (void)startMonitoringTime;
- (NSTimeInterval)stopMonitoringTime;

- (IBAction)loadPhotos:(id)sender;
- (IBAction)extractInfo:(id)sender;
- (IBAction)extractInfoGCD:(id)sender;
- (IBAction)parseGPX:(id)sender;
- (IBAction)matchCooPhoto:(id)sender;
- (IBAction)tagPhotos:(id)sender;
- (IBAction)tagPhotosGCD:(id)sender;

- (void)tag:(NSDictionary *)photo;
- (void)extract:(NSURL *)url;

@end
