//
//  AppDelegate.m
//  SET11104 Desktop
//
//  Created by Jules Coynel on 09/11/2011.
//  Copyright (c) 2011 Jules Coynel. All rights reserved.
//

#import "AppDelegate.h"
#import "Location.h"

@implementation AppDelegate
@synthesize progress;
@synthesize startMonitoringDate;

@synthesize loadPhotosLabel;
@synthesize loadPhotosLabelTime;
@synthesize generateFileLabelTime;
@synthesize parseGPXLabelTime;
@synthesize matchGPSPhotosLabelTime;
@synthesize tagPhotosLabelTime, tagPhotosGCDLabelTime;
@synthesize parseGPXLabel, matchGPSPhotosLabel, tagPhotosGCDLabel, generateFileGCDLabelTime;

@synthesize window = _window;
@synthesize parserDelegate;
@synthesize selectedPhotosURLs;
@synthesize selectedPhotosInfo;
@synthesize photosWithCoordinates;
@synthesize locations;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setSelectedPhotosURLs:nil];
    [self setSelectedPhotosInfo:nil];
    [self setPhotosWithCoordinates:nil];
    [self setLocations:nil];
    [self setStartMonitoringDate:nil];
    
    [self setParserDelegate:[[GPXParserDelegate alloc] init]];
}

// Display an Open Panel to select photos
- (IBAction)loadPhotos:(id)sender 
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:YES];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:YES];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"jpeg", @"jpg", nil]];
    
    NSInteger i = [panel runModal];
	if(i == NSOKButton)
    {
        [self startMonitoringTime];
        
		[self setSelectedPhotosURLs:[[panel URLs] mutableCopy]];
        
        [[self loadPhotosLabelTime] setTitle:[NSString stringWithFormat:@"%fs", [self stopMonitoringTime]]];
        
        [[self loadPhotosLabel] setTitle:[NSString stringWithFormat:@"%d photos selected.", [[self selectedPhotosURLs]count]]];
    }
}

// Extract the timestamp and name from selected photos
- (IBAction)extractInfo:(id)sender 
{
    [self startMonitoringTime];
    
    [self setSelectedPhotosInfo:[NSMutableDictionary dictionary]];
    
    for(NSURL *url in [self selectedPhotosURLs])
    {
        [self extract:url];
    }
    
    [[self generateFileLabelTime] setTitle:[NSString stringWithFormat:@"%fs", [self stopMonitoringTime]]];
}

- (IBAction)extractInfoGCD:(id)sender 
{
    [self startMonitoringTime];
    
    [self setSelectedPhotosInfo:[NSMutableDictionary dictionary]];
    
    NSUInteger count = [[self selectedPhotosURLs] count];
    
    dispatch_async(dispatch_queue_create("SET11104queue1", NULL), ^(void) {
        dispatch_apply(count, dispatch_get_global_queue(0, 0), ^(size_t i){
            [self extract:[[self selectedPhotosURLs] objectAtIndex:i]];
        });
        [[self generateFileGCDLabelTime] setTitle:[NSString stringWithFormat:@"%fs", [self stopMonitoringTime]]];
    });
}

- (void)extract:(NSURL *)url
{
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source) {
        CFDictionaryRef propsCF = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
        NSDictionary* props = (__bridge NSDictionary*) propsCF;
        
        NSString *date = [props valueForKeyPath:@"{Exif}.DateTimeOriginal"];
        NSString *photoID = [url path];
        
        [[self selectedPhotosInfo] setValue:date forKey:photoID];
        
        CFRelease(propsCF);
        CFRelease(source);
    }    
}

- (IBAction)parseGPX:(id)sender
{
    [self startMonitoringTime];
    
    NSURL *GPXFileURL = [[NSBundle mainBundle] URLForResource:@"28_10_2011 30_10_2011" 
                                                withExtension:@"gpx"];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:GPXFileURL];
    [parser setDelegate:[self parserDelegate]];
    
    if ([parser parse])
    {
        [self setLocations:[(GPXParserDelegate *)[parser delegate] locations]];
    }
    else
    {
        // Parse failed
        NSLog(@"parseGPX:\n%@", [[parser parserError] localizedDescription]);
    }
    
    [[self parseGPXLabelTime] setTitle:[NSString stringWithFormat:@"%fs", [self stopMonitoringTime]]];
    
    [[self parseGPXLabel] setTitle:[NSString stringWithFormat:@"%d locations found.", [[self locations] count]]];
}


- (IBAction)matchCooPhoto:(id)sender 
{	
    [self startMonitoringTime];
    
	// Initialise the array that will contain the photos with the coordinates to send to flickr
	photosWithCoordinates = [[NSMutableArray alloc] init];
	
	NSArray *locs = [self locations];
    
	// Date formatter to create a date from flickr date string
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[df setDateFormat:@"yyyy:MM:dd HH:mm:ss"]; // e.g. 2010-12-08 12:01:37
	
	NSDateFormatter *dfCoo = [[NSDateFormatter alloc] init];
	[dfCoo setDateFormat:@"yyyy:MM:dd HH:mm:ss"]; // e.g. 2010-12-08 12:01:37
    
	// We go through the photos from flickr
	for (NSString *photoId in [self selectedPhotosInfo]) {
        NSString *dateString = [[self selectedPhotosInfo] objectForKey:photoId];
		NSDate *photoDate = [df dateFromString:dateString];
        
		int locationIndex = 0;
		Location *lastLocation = nil;
		Location *foundLocation = nil;
		
		
		// We go through the array of locations to find one that match our photos from flickr
		while (!foundLocation && locationIndex < [locs count]) {
            
			Location *currentLocation = (Location *)[locs objectAtIndex:locationIndex];
			NSDate *currentDate = [currentLocation timestamp];
            
			NSComparisonResult dateComparisonResult = [currentDate compare:photoDate];
			
            switch (dateComparisonResult) {
                case NSOrderedSame:
                    foundLocation = currentLocation;
                    break;
                case NSOrderedAscending:
                    lastLocation = currentLocation;
                    break;
                case NSOrderedDescending:
                    foundLocation = lastLocation;
                    break;                    
                default:
                    break;
            }			
			locationIndex++;
		}
		
		if (foundLocation) {
			NSMutableDictionary *photoDictWithCoo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
													 photoId, @"photoID",
													 [NSString stringWithFormat:@"%f", foundLocation.latitude], @"lat",
													 [NSString stringWithFormat:@"%f",foundLocation.longitude], @"lon",
													 nil];
			[photosWithCoordinates addObject:photoDictWithCoo];	
        }
	}
    
    [[self matchGPSPhotosLabelTime] setTitle:[NSString stringWithFormat:@"%fs", [self stopMonitoringTime]]];  
    
    [[self matchGPSPhotosLabel] setTitle:[NSString stringWithFormat:@"%d matches.", [[self photosWithCoordinates] count]]];
}

- (void)tagPhotos:(id)sender
{
    [[self progress] setMinValue:0];
    [[self progress] setIntValue:0];
    [[self progress] setMaxValue:[[self photosWithCoordinates] count]-1];
    
    [self startMonitoringTime];
    
    for (NSMutableDictionary *photo in [self photosWithCoordinates]) 
    {
        [self tag:photo];
        self.progress.integerValue = self.progress.integerValue + 1;
    }
    
    [[self tagPhotosLabelTime] setTitle:[NSString stringWithFormat:@"%fs", [self stopMonitoringTime]]];  
}

- (void)tagPhotosGCD:(id)sender
{
    [[self tagPhotosGCDLabel] setTitle:@"Tagging in progress..."];
    
    [[self progress] setMinValue:0];
    [[self progress] setIntValue:0];
    [[self progress] setMaxValue:[[self photosWithCoordinates] count]-1];
    
    [self startMonitoringTime];
    
    NSUInteger count = [[self photosWithCoordinates] count];
    
    dispatch_async(dispatch_queue_create("SET11104queue", NULL), ^(void) {
        dispatch_apply(count, dispatch_get_global_queue(0, 0), ^(size_t i){
            [self tag:[[self photosWithCoordinates] objectAtIndex:i]];
            
            self.progress.integerValue = self.progress.integerValue + 1;
        });
        
        
        [[self tagPhotosGCDLabelTime] setTitle:[NSString stringWithFormat:@"%fs", [self stopMonitoringTime]]];
        [[self tagPhotosGCDLabel] setTitle:@""];
    });
}


- (void)tag:(NSDictionary *)photo
{
    NSString *photoID = [photo objectForKey:@"photoID"];
    NSURL *photoURL = [NSURL fileURLWithPath:photoID];
    NSString *photoLat = [photo objectForKey:@"lat"];
    double photoLatNum = [photoLat doubleValue];
    NSString *photoLon = [photo objectForKey:@"lon"];
    double photoLonNum = [photoLon doubleValue];
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef) photoURL,NULL);
    
    // Get all the metadata in the photo
    CFDictionaryRef metadataCF = CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
    NSDictionary *metadata = (__bridge NSDictionary *)metadataCF;
    
    // Make the metadata dictionary editable
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
    
    CFRelease(metadataCF);
    
    NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
    NSMutableDictionary *GPSDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
    
    if(!EXIFDictionary) {
        EXIFDictionary = [NSMutableDictionary dictionary];
    }
    if(!GPSDictionary) {
        GPSDictionary = [NSMutableDictionary dictionary];
    }
    
    if (photoLonNum < 0) {
        photoLonNum = -photoLonNum;
        [GPSDictionary setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } else {
        [GPSDictionary setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    }
    [GPSDictionary setValue:[NSNumber numberWithDouble:photoLonNum] forKey:(NSString*)kCGImagePropertyGPSLongitude];
    
    
    if (photoLatNum < 0) {
        photoLatNum = -photoLatNum;
        [GPSDictionary setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } else {
        [GPSDictionary setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    }
    [GPSDictionary setValue:[NSNumber numberWithDouble:photoLatNum] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    
    
    // Add our modified EXIF/GPS data to photo’s metadata
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    
    // Type of the image (e.g., public.jpeg)
    CFStringRef UTI = CGImageSourceGetType(source);
    
    // Data CGImageDestinationRef will write into
    NSMutableData *data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data,UTI,1,NULL);
    
    if(!destination)
    {
        NSLog(@"AppDelegate: Could not create image destination.");
    }
    else
    {
        
        // Add the image contained in the image source to the destination
        // overidding the old metadata with our modified metadata
        CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadataAsMutable);
        
        // Write the image data and metadata into our data object
        BOOL success = NO;
        success = CGImageDestinationFinalize(destination);
        
        if(!success)
        {
            NSLog(@"AppDelegate: Could not create data from image destination.");
        }
        
        // Write to disk
        [data writeToFile:photoID atomically:YES];
        
        // Cleanup
        CFRelease(destination);
    }
    CFRelease(source);
}

#pragma mark - Monitoring Time

- (void)startMonitoringTime
{
    [self setStartMonitoringDate:[NSDate date]];
}

- (NSTimeInterval)stopMonitoringTime
{
    NSDate *endDate = [NSDate date];
    
    NSTimeInterval diff = [endDate timeIntervalSinceDate:[self startMonitoringDate]];
    
    [self setStartMonitoringDate:nil];
    
    return diff;
}


@end
