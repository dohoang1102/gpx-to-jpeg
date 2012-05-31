//
//  GPXParser.h
//  SET11104 Desktop
//
//  Created by Jules Coynel on 09/11/2011.
//  Copyright (c) 2011 Jules Coynel. All rights reserved.
//


@interface GPXParserDelegate : NSObject <NSXMLParserDelegate>
{
    NSMutableArray *locations;
    BOOL waitingForTimeElement;
}

@property (nonatomic, retain) NSMutableArray *locations;
@property (nonatomic, getter = isWaitingForTimeElement) BOOL waitingForTimeElement;

@end
