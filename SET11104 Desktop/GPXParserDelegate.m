//
//  GPXParser.m
//  SET11104 Desktop
//
//  Created by Jules Coynel on 09/11/2011.
//  Copyright (c) 2011 Jules Coynel. All rights reserved.
//

#import "GPXParserDelegate.h"
#import "Location.h"

@implementation GPXParserDelegate
@synthesize locations;
@synthesize waitingForTimeElement;

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    [self setLocations:[[NSMutableArray alloc] init]];
    [self setWaitingForTimeElement:NO];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"GPXParserDelegate\nparser:parseErrorOccurred:\n%@", [parseError localizedDescription]);    
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"wpt"])
    {
        double lat = [[attributeDict objectForKey:@"lat"] doubleValue];
        double lon = [[attributeDict objectForKey:@"lon"] doubleValue];
        
        Location *location = [[Location alloc] initWithLatitude:lat longitude:lon];
        
        [[self locations] addObject:location];
    }
    else if ([elementName isEqualToString:@"time"])
    {
        [self setWaitingForTimeElement:YES];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([self isWaitingForTimeElement]) {
        // e.g. 2011-10-28T06:39:12Z
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        NSDate *date = [dateFormatter dateFromString:string];  
        
        Location *currentLocation = (Location *)[[self locations] lastObject];
        [currentLocation setTimestamp:date];
    }
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"time"])
    {
        [self setWaitingForTimeElement:NO];
    }
}

@end