/*
Lingon version 2.1.1, 2008-12-18
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://tuppis.com/lingon

Copyright 2005-2008 Peter Borg

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

// Based on ImageAndTextCell.m by Chuck Pisula (Apple)

#import "LINStandardHeader.h"


@implementation LINPlistListCell

@synthesize image;

- (id)copyWithZone:(NSZone *)zone
{
	LINPlistListCell *cell = (LINPlistListCell *)[super copyWithZone:zone];
	cell->image = image;
	return cell;
}


- (NSRect)imageFrameForCellFrame:(NSRect)cellFrame 
{
    if (image != nil) {
        NSRect imageFrame;
        imageFrame.size = [image size];
        imageFrame.origin = cellFrame.origin;
        imageFrame.origin.x += 3;
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        return imageFrame;
    } else {
        return NSZeroRect;
	}
}


- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if (image != nil) {
        NSSize imageSize;
        NSRect imageFrame;
		
        imageSize = [image size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
        if ([self drawsBackground]) {
            [[self backgroundColor] set];
            NSRectFill(imageFrame);
        }
        imageFrame.origin.x += 3;
        imageFrame.size = imageSize;
		
        if ([controlView isFlipped]) {
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
        } else {
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
		}
		
        [image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
    }
	
    NSSize contentSize = [self cellSize];
    cellFrame.origin.y += ceil((cellFrame.size.height - contentSize.height) / 2);
    cellFrame.size.height = contentSize.height;
	
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}


- (NSSize)cellSize 
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (image ? [image size].width : 0) + 3;
    return cellSize;
}

@end
