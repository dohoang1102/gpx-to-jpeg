//
//  Location.m
//  SET11104 Desktop
//
//  Created by Jules Coynel on 09/11/2011.
//  Copyright (c) 2011 Jules Coynel. All rights reserved.
//

#import "Location.h"

@implementation Location
@synthesize latitude, longitude, timestamp;

- (id)init
{
	return [self initWithLatitude:0 longitude:0 timestamp:nil];
}

- (id)initWithLatitude:(double)lat longitude:(double)lon
{
    return [self initWithLatitude:lat longitude:lon timestamp:nil];
}

- (id)initWithLatitude:(double)lat longitude:(double)lon timestamp:(NSDate *)t
{
    self = [super init];
	
	if (self != nil) {
		latitude = lat;
		longitude = lon;
		timestamp = [t copy];
	}
	
	return self;
}

@end