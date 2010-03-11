/*
Lingon version 2.1.1, 2008-12-18
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://tuppis.com/lingon

Copyright 2005-2008 Peter Borg
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import "LINStandardHeader.h"

@implementation LINVariousPerformer

static id sharedInstance = nil;

+ (LINVariousPerformer *)sharedInstance
{ 
	if (sharedInstance == nil) { 
		sharedInstance = [[self alloc] init];
	} 
	return sharedInstance; 
}


- (id)init 
{
    if (sharedInstance == nil) {
        sharedInstance = [super init];
	}
    return sharedInstance;
}


- (void)updatePlistsOutlineView
{
	NSOutlineView *outlineView = [LINInterface plistsOutlineView];
	NSTreeController *treeController = [LINInterface plistsTreeController];
	[treeController setSelectsInsertedObjects:NO];
	
	[outlineView setDelegate:nil];
	
	[treeController setContent:nil];
	[treeController setContent:[NSMutableArray array]];
	
	NSIndexPath *folderIndexPath;
	NSMutableDictionary *node;
	
	NSArray *launchdDirectories = [NSArray arrayWithObjects:MYAGENTS, USERSAGENTS, USERSDAEMONS, SYSTEMAGENTS, SYSTEMDAEMONS, nil];
	NSArray *launchdDirectoriesStrings = [NSArray arrayWithObjects:MYAGENTSSTRING, USERSAGENTSSTRING, USERSDAEMONSSTRING, SYSTEMAGENTSSTRING, SYSTEMDAEMONSSTRING, nil];
	NSInteger stringIndex = 0;
	
	NSInteger folderIndex = 0;
	for (id directory in launchdDirectories) {

		node = [NSMutableDictionary dictionary];
		
		NSArray *plists = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
		[node setValue:[[NSNumber numberWithInteger:[plists count]] stringValue] forKey:@"plistCount"];
		
		[node setValue:[[launchdDirectoriesStrings objectAtIndex:stringIndex] uppercaseString] forKey:@"name"];
		
		[node setValue:directory forKey:@"path"];
		stringIndex++;
		[node setValue:[NSNumber numberWithBool:NO] forKey:@"isLeaf"];
		
		folderIndexPath = [[NSIndexPath alloc] initWithIndex:folderIndex];
		[treeController insertObject:node atArrangedObjectIndexPath:folderIndexPath];
		folderIndex++;
		
		
		NSInteger fileIndex = 0;
		for (id plist in plists) {
			NSString *path = [directory stringByAppendingPathComponent:plist];
			
			NSMutableDictionary *subNode = [NSMutableDictionary dictionary];
			[subNode setValue:[NSNumber numberWithBool:YES] forKey:@"isLeaf"];
			[subNode setValue:path forKey:@"path"];
			
			[subNode setValue:[plist stringByDeletingPathExtension] forKey:@"name"];
			NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
			
			NSData *data = [NSPropertyListSerialization dataFromPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
			NSString *plistString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			[subNode setValue:plistString forKey:@"plistString"];
			
			NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
			[icon setSize:NSMakeSize(16.0, 16.0)];
			[subNode setValue:icon forKey:@"icon"];
			
			[subNode setValue:directory forKey:@"parentDirectory"];
			
			[subNode setValue:[NSNumber numberWithBool:NO] forKey:@"isNewFile"];
			
			if (dictionary != nil) {
				[subNode setValue:dictionary forKey:@"plist"];
				[subNode setValue:[self temporaryDictionaryFromOriginal:dictionary] forKey:@"temporaryPlist"];
				[treeController insertObject:subNode atArrangedObjectIndexPath:[folderIndexPath indexPathByAddingIndex:fileIndex]];
				fileIndex++;
			}
			
				
		}
	}
	
	[outlineView scrollRowToVisible:0];
	[outlineView setDelegate:[LINOutlineViewDelegate sharedInstance]];
	[treeController setSelectsInsertedObjects:YES];
	
	[treeController addObserver:self forKeyPath:@"content.plist.Disabled" options:NSKeyValueObservingOptionNew context:@"PlistChanged"];
	[treeController addObserver:self forKeyPath:@"content.plist.Label" options:NSKeyValueObservingOptionNew context:@"PlistChanged"];
	[treeController addObserver:self forKeyPath:@"content.plist.RunAtLoad" options:NSKeyValueObservingOptionNew context:@"PlistChanged"];
	[treeController addObserver:self forKeyPath:@"content.plist.StartOnMount" options:NSKeyValueObservingOptionNew context:@"PlistChanged"];
	
	[treeController addObserver:self forKeyPath:@"content.temporaryPlist.What" options:NSKeyValueObservingOptionNew context:@"WhatInTemporaryPlistChanged"];
	[treeController addObserver:self forKeyPath:@"content.temporaryPlist.KeepAlive" options:NSKeyValueObservingOptionNew context:@"KeepAliveInTemporaryPlistChanged"];
	
	[treeController addObserver:self forKeyPath:@"content.temporaryPlist.WatchPath" options:NSKeyValueObservingOptionNew context:@"WatchPathInTemporaryPlistChanged"];
	[treeController addObserver:self forKeyPath:@"content.temporaryPlist.QueueDirectory" options:NSKeyValueObservingOptionNew context:@"QueueDirectoryInTemporaryPlistChanged"];
	
	[treeController addObserver:self forKeyPath:@"content.temporaryPlist.StartIntervalTextField" options:NSKeyValueObservingOptionNew context:@"StartIntervalTextFieldInTemporaryPlistChanged"];
	[treeController addObserver:self forKeyPath:@"content.temporaryPlist.StartIntervalPopUp" options:NSKeyValueObservingOptionNew context:@"StartIntervalPopUpInTemporaryPlistChanged"];
	

	[treeController addObserver:self forKeyPath:@"content.temporaryPlist.SpecificDate" options:NSKeyValueObservingOptionNew context:@"SpecificDateInTemporaryPlistChanged"];
	[treeController addObserver:self forKeyPath:@"content.temporaryPlist.SpecificTime" options:NSKeyValueObservingOptionNew context:@"SpecificTimeInTemporaryPlistChanged"];
	[treeController addObserver:self forKeyPath:@"content.temporaryPlist.SpecificDay" options:NSKeyValueObservingOptionNew context:@"SpecificDayInTemporaryPlistChanged"];
	
	[self expandDirectoriesThatShouldBeExpanded];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([(NSString *)context isEqualToString:@"PlistChanged"]) {
		[LINMain currentPlistChanged];
	} else if ([(NSString *)context isEqualToString:@"WhatInTemporaryPlistChanged"]) {
		[LINMain currentPlistChanged];
		[[LINMain plistChangesDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"What"];
		
	} else if ([(NSString *)context isEqualToString:@"KeepAliveInTemporaryPlistChanged"]) {
		[LINMain currentPlistChanged];
		[[LINMain plistChangesDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"KeepAlive"];
		
	} else if ([(NSString *)context isEqualToString:@"WatchPathInTemporaryPlistChanged"]) {
		[LINMain currentPlistChanged];
		[[LINMain plistChangesDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"WatchPath"];
		
	} else if ([(NSString *)context isEqualToString:@"QueueDirectoryInTemporaryPlistChanged"]) {
		[LINMain currentPlistChanged];
		[[LINMain plistChangesDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"QueueDirectory"];
		
	} else if ([(NSString *)context isEqualToString:@"StartIntervalTextFieldInTemporaryPlistChanged"]) {
		[LINMain currentPlistChanged];
		[[LINMain plistChangesDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"StartIntervalTextField"];
		
	} else if ([(NSString *)context isEqualToString:@"StartIntervalPopUpInTemporaryPlistChanged"]) {
		[LINMain currentPlistChanged];
		[[LINMain plistChangesDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"StartIntervalPopUp"];
		
	} else if ([(NSString *)context isEqualToString:@"SpecificDateInTemporaryPlistChanged"]) {
		[LINMain currentPlistChanged];
		[[LINMain plistChangesDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"SpecificTime"];
	
	} else if ([(NSString *)context isEqualToString:@"SpecificTimeInTemporaryPlistChanged"]) {
		[LINMain currentPlistChanged];
		[[LINMain plistChangesDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"SpecificTime"];
		
	} else if ([(NSString *)context isEqualToString:@"SpecificDayInTemporaryPlistChanged"]) {
		[LINMain currentPlistChanged];
		[[LINMain plistChangesDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"SpecificDay"];
		
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}

}


- (NSMutableDictionary *)temporaryDictionaryFromOriginal:(NSDictionary *)dictionary
{
	NSMutableDictionary *temporaryDictionary = [NSMutableDictionary dictionary];
	
	NSMutableString *what = [NSMutableString string];
	if ([dictionary valueForKey:@"Program"]) {
		[what appendString:[dictionary valueForKey:@"Program"]];
	}
	if ([dictionary valueForKey:@"ProgramArguments"]) {
		NSArray *array = [dictionary valueForKey:@"ProgramArguments"];
		for (id item in array) {
			if ([what length] > 0) {
				[what appendString:@" "];
			}
			NSMutableString *temporaryItem = [NSMutableString stringWithString:item];
			[temporaryItem replaceOccurrencesOfString:@"\\ " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [item length])];
			if ([temporaryItem rangeOfString:@" "].location != NSNotFound && [item characterAtIndex:0] != '"') { // If there are spaces in one argument put quotes around it
				[what appendFormat:@"\"%@\"", item];
			} else {
				[what appendString:item];
			}
		}		
	}
	
	if ([what length] > 0 ) {
		[temporaryDictionary setValue:what forKey:@"What"];
	}
	
	if ([dictionary valueForKey:@"OnDemand"] && [[dictionary valueForKey:@"OnDemand"] boolValue] == NO) {
		[temporaryDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"KeepAlive"];
	}
	
	if ([dictionary valueForKey:@"KeepAlive"]) {
		if ([[dictionary valueForKey:@"KeepAlive"] isKindOfClass:[NSDictionary class]]) {
			[temporaryDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"KeepAliveEnabled"];
		} else {
			[temporaryDictionary setValue:[dictionary valueForKey:@"KeepAlive"] forKey:@"KeepAlive"];
			[temporaryDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"KeepAliveEnabled"];
		}
	} else {
		[temporaryDictionary setValue:[dictionary valueForKey:@"KeepAlive"] forKey:@"KeepAlive"];
		[temporaryDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"KeepAliveEnabled"];
	}
	
	if ([dictionary valueForKey:@"WatchPaths"]) {
		if ([[dictionary valueForKey:@"WatchPaths"] isKindOfClass:[NSArray class]] && [[dictionary valueForKey:@"WatchPaths"] count] > 0) {
			[temporaryDictionary setValue:[[dictionary valueForKey:@"WatchPaths"] objectAtIndex:0] forKey:@"WatchPath"];
		}
	}
	
	if ([dictionary valueForKey:@"QueueDirectories"]) {
		if ([[dictionary valueForKey:@"QueueDirectories"] isKindOfClass:[NSArray class]] && [[dictionary valueForKey:@"QueueDirectories"] count] > 0) {
			[temporaryDictionary setValue:[[dictionary valueForKey:@"QueueDirectories"] objectAtIndex:0] forKey:@"QueueDirectory"];
		}
	}
	
	if ([dictionary valueForKey:@"StartInterval"]) {
		NSInteger seconds = [[dictionary valueForKey:@"StartInterval"] integerValue];
		
		if (seconds < 60) {
			[temporaryDictionary setValue:[NSNumber numberWithInteger:seconds] forKey:@"StartIntervalTextField"];
			[temporaryDictionary setValue:[NSNumber numberWithInteger:LINPeriodSeconds] forKey:@"StartIntervalPopUp"];
		} else if (seconds < 3600) {
			[temporaryDictionary setValue:[NSNumber numberWithInteger:round(seconds / 60)] forKey:@"StartIntervalTextField"];
			[temporaryDictionary setValue:[NSNumber numberWithInteger:LINPeriodMinutes] forKey:@"StartIntervalPopUp"];
		} else {
			[temporaryDictionary setValue:[NSNumber numberWithInteger:round(seconds / 60 / 60)] forKey:@"StartIntervalTextField"];
			[temporaryDictionary setValue:[NSNumber numberWithInteger:LINPeriodHours] forKey:@"StartIntervalPopUp"];
		}

	}
	
	if ([dictionary valueForKey:@"StartCalendarInterval"]) {
		[temporaryDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"SpecificDate"];
		
		NSDictionary *specificDateDictionary;
		if ([[dictionary valueForKey:@"StartCalendarInterval"] isKindOfClass:[NSDictionary class]]) {
			specificDateDictionary = [NSDictionary dictionaryWithDictionary:[dictionary valueForKey:@"StartCalendarInterval"]];
			[temporaryDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"SpecificDateFromArray"];
		} else if ([[dictionary valueForKey:@"StartCalendarInterval"] isKindOfClass:[NSArray class]]) {
			if ([[dictionary valueForKey:@"StartCalendarInterval"] count] > 0) {
				specificDateDictionary = [NSDictionary dictionaryWithDictionary:[[dictionary valueForKey:@"StartCalendarInterval"] objectAtIndex:0]];
			}
			[temporaryDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"SpecificDateFromArray"];
		}
		
		NSInteger minute = 0;
		NSInteger hour = 0;
		
		if ([specificDateDictionary valueForKey:@"Minute"]) {
			minute = [[specificDateDictionary valueForKey:@"Minute"] integerValue];
		}
		if ([specificDateDictionary valueForKey:@"Hour"]) {
			hour = [[specificDateDictionary valueForKey:@"Hour"] integerValue];
		}
		
		[temporaryDictionary setValue:[NSCalendarDate dateWithYear:2000 month:1 day:1 hour:hour minute:minute second:0 timeZone:nil] forKey:@"SpecificTime"];
		
		if ([specificDateDictionary valueForKey:@"Day"]) {
			NSInteger day = [[specificDateDictionary valueForKey:@"Day"] integerValue];
			[temporaryDictionary setValue:[NSNumber numberWithInteger:(day + 100)] forKey:@"SpecificDay"];
		} else if ([specificDateDictionary valueForKey:@"Weekday"]) {
			NSInteger weekday = [[specificDateDictionary valueForKey:@"Weekday"] integerValue];
			if (weekday == 7) {
				weekday = 0;
			}
			[temporaryDictionary setValue:[NSNumber numberWithInteger:(weekday + 10)] forKey:@"SpecificDay"];
		} else {
			[temporaryDictionary setValue:[NSNumber numberWithInteger:0] forKey:@"SpecificDay"];
		}
	}
	
	[temporaryDictionary setValue:[self stringFromDictionary:dictionary] forKey:@"PlistString"];
	
	return temporaryDictionary;
	
}


- (NSMutableDictionary *)finalDictionaryFromOriginal:(NSDictionary *)originalDictionary temporary:(NSDictionary *)temporaryDictionary
{
	NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:originalDictionary];
	NSMutableDictionary *changesDictionary = [LINMain plistChangesDictionary];
	
	if ([changesDictionary valueForKey:@"What"]) {
		[returnDictionary removeObjectForKey:@"StartCalendarInterval"];
		[returnDictionary setValue:[self divideCommandIntoArray:[temporaryDictionary valueForKey:@"What"]] forKey:@"ProgramArguments"];
	}
	
	if ([changesDictionary valueForKey:@"KeepAlive"]) {
		[returnDictionary setValue:[temporaryDictionary valueForKey:@"KeepAlive"] forKey:@"KeepAlive"];
	}
	
	if ([changesDictionary valueForKey:@"WatchPath"]) {
		NSMutableArray *array = [NSMutableArray arrayWithArray:[returnDictionary valueForKey:@"WatchPaths"]];
		if ([array count] > 0) {
			[array removeObjectAtIndex:0];
		}
		if ([[temporaryDictionary valueForKey:@"WatchPath"] length] > 0) {
			[array insertObject:[temporaryDictionary valueForKey:@"WatchPath"] atIndex:0];
		}
		[returnDictionary setValue:array forKey:@"WatchPaths"];
	}
	
	if ([changesDictionary valueForKey:@"QueueDirectory"]) {
		NSMutableArray *array = [NSMutableArray arrayWithArray:[returnDictionary valueForKey:@"QueueDirectories"]];
		if ([array count] > 0) {
			[array removeObjectAtIndex:0];
		}
		if ([[temporaryDictionary valueForKey:@"QueueDirectory"] length] > 0) {
			[array insertObject:[temporaryDictionary valueForKey:@"QueueDirectory"] atIndex:0];
		}
		[returnDictionary setValue:array forKey:@"QueueDirectories"];
	}
	
	if ([changesDictionary valueForKey:@"StartIntervalTextField"] || [changesDictionary valueForKey:@"StartIntervalPopUp"]) {
		if ([[temporaryDictionary valueForKey:@"StartIntervalTextField"] length] > 0) {
			NSInteger startInterval = [[temporaryDictionary valueForKey:@"StartIntervalTextField"] integerValue];
			if ([[temporaryDictionary valueForKey:@"StartIntervalPopUp"] integerValue] == LINPeriodMinutes) {
				startInterval = startInterval * 60;
			} else if ([[temporaryDictionary valueForKey:@"StartIntervalPopUp"] integerValue] == LINPeriodHours) {
				startInterval = startInterval * 60 * 60;
			}
			[returnDictionary setValue:[NSNumber numberWithInteger:startInterval] forKey:@"StartInterval"];
		} else {
			[returnDictionary removeObjectForKey:@"StartInterval"];
		}
	}
	
	if ([changesDictionary valueForKey:@"SpecificDate"] || [changesDictionary valueForKey:@"SpecificTime"] || [changesDictionary valueForKey:@"SpecificDay"]) {
		NSMutableDictionary *calendarDictionary = [NSMutableDictionary dictionary];

		NSCalendarDate *calendarDate = [[temporaryDictionary valueForKey:@"SpecificTime"] dateWithCalendarFormat:nil timeZone:nil];
		
		[calendarDictionary setValue:[NSNumber numberWithInteger:[calendarDate minuteOfHour]] forKey:@"Minute"];
		[calendarDictionary setValue:[NSNumber numberWithInteger:[calendarDate hourOfDay]] forKey:@"Hour"];
		NSInteger day = [[temporaryDictionary valueForKey:@"SpecificDay"] integerValue];
		if (day > 9 && day < 17) {
			[calendarDictionary setValue:[NSNumber numberWithInteger:(day - 10)] forKey:@"Weekday"];
		} else if (day > 100 && day < 132) {
			[calendarDictionary setValue:[NSNumber numberWithInteger:(day - 100)] forKey:@"Day"];
		}
			
		if ([[temporaryDictionary valueForKey:@"SpecificDateFromArray"] boolValue] == NO) {
			[returnDictionary setValue:calendarDictionary forKey:@"StartCalendarInterval"];
		} else {
			NSMutableArray *array = [NSMutableArray arrayWithArray:[originalDictionary valueForKey:@"StartCalendarInterval"]];
			[array removeObjectAtIndex:0];
			[array insertObject:calendarDictionary atIndex:0];
			[returnDictionary setValue:array forKey:@"StartCalendarInterval"];
		}
			
	}
	
	if ([[temporaryDictionary valueForKey:@"SpecificDate"] boolValue] == NO) {
		[returnDictionary removeObjectForKey:@"StartCalendarInterval"];
	}
	
	return returnDictionary;
	
}



- (NSInteger)alertWithMessage:(NSString *)message informativeText:(NSString *)informativeText defaultButton:(NSString *)defaultButton alternateButton:(NSString *)alternateButton otherButton:(NSString *)otherButton
{	
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:message];
	[alert setInformativeText:informativeText];
	if (defaultButton) {
		[alert addButtonWithTitle:defaultButton];
	}
	if (alternateButton) {
		[alert addButtonWithTitle:alternateButton];
	}
	if (otherButton) {
		[alert addButtonWithTitle:otherButton];
	}
	
	return [alert runModal];
	// NSAlertFirstButtonReturn
	// NSAlertSecondButtonReturn
	// NSAlertThirdButtonReturn
}



- (void)standardAlertSheetWithMessage:(NSString *)message informativeText:(NSString *)informativeText suppressionString:(NSString *)suppressionString
{
	NSWindow *window = [LINInterface mainWindow];
	
	// These lines cause a bug when changing selection and the plist in the expert mode is not valid
//	if ([window attachedSheet]) {
//		[[window attachedSheet] close];
//	}
	
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:message];
	[alert setInformativeText:informativeText];
	[alert addButtonWithTitle:OK_BUTTON];
	
	NSMutableArray *array = [NSMutableArray array];
	
	if (suppressionString != nil) {
		[alert setShowsSuppressionButton:YES];
		[[alert suppressionButton] setTitle:NSLocalizedString(@"Do not show this message again", @"Do not show this message again")];
		[array addObject:suppressionString];
	}
	
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:(void *)array];
}


- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
	if ([[alert suppressionButton] state] == NSOnState) {
		[LINDefaults setValue:[NSNumber numberWithBool:NO] forKey:[(NSArray *)contextInfo objectAtIndex:0]];
	}
}



- (NSArray *)divideCommandIntoArray:(NSString *)command
{
	if ([command rangeOfString:@"\""].location == NSNotFound && [command rangeOfString:@"'"].location == NSNotFound && [command rangeOfString:@"\\"].location == NSNotFound) {
		return [command componentsSeparatedByString:@" "];
	} else {
		NSMutableArray *returnArray = [[NSMutableArray alloc] init];
		NSScanner *scanner = [NSScanner scannerWithString:command];
		NSInteger location = 0;
		NSInteger commandLength = [command length];
		NSInteger beginning;
		NSInteger savedBeginning = -1;
		NSString *characterToScanFor;
		
		while (location < commandLength) {
			if (savedBeginning == -1) {
				beginning = location;
			} else {
				beginning = savedBeginning;
				savedBeginning = -1;
			}
			if ([command characterAtIndex:location] == '"') {
				characterToScanFor = @"\"";
				beginning++;
				location++;
			} else if ([command characterAtIndex:location] == '\'') {
				characterToScanFor = @"'";
				beginning++;
				location++;
			} else {
				characterToScanFor = @" ";
			}
			
			[scanner setScanLocation:location];
			if ([scanner scanUpToString:characterToScanFor intoString:nil]) {
				if ([characterToScanFor isEqualToString:@" "] && [command characterAtIndex:([scanner scanLocation] - 1)] == '\\') {
					location = [scanner scanLocation];
					savedBeginning = beginning;
					continue;
				}
				location = [scanner scanLocation];
			} else {
				location = commandLength - 1;
			}
			
			[returnArray addObject:[command substringWithRange:NSMakeRange(beginning, location - beginning)]];
			location++;
		}
		
		
		// Sometimes a leading space creaps in so remove it...
		NSMutableArray *cleanedUpReturnArray = [NSMutableArray array];
		
		for (id item in returnArray) {
			if ([item length] > 0 && [item characterAtIndex:0] == ' ') {
				NSMutableString *cleanedUpItem = [NSMutableString stringWithString:item];
				[cleanedUpItem replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
				[cleanedUpReturnArray addObject:cleanedUpItem]; 
			} else {
				[cleanedUpReturnArray addObject:item];
			}
		}
		
		return (NSArray *)cleanedUpReturnArray;
	}
}


- (BOOL)shouldWeCloseTheCurrentPlist
{
	if ([LINMain currentPlistHasUnsavedChanges] == YES) {
		NSInteger answer = [self alertWithMessage:NSLocalizedString(@"You have unsaved changes", @"You have unsaved changes") informativeText:NSLocalizedString(@"Your changes will be lost if you do not save", @"Your changes will be lost if you do not save") defaultButton:NSLocalizedString(@"Save", @"Save") alternateButton:CANCEL_BUTTON otherButton:NSLocalizedString(@"Don't Save", @"Don't Save")];
		if (answer == NSAlertFirstButtonReturn) {
			return [[LINFileMenuController sharedInstance] performSave];
		} else if (answer == NSAlertSecondButtonReturn) {
			return NO;
		} else {
			id object = [[[LINInterface plistsTreeController] selectedObjects] objectAtIndex:0];
			if (object != nil) {
				NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[object valueForKey:@"path"]];
				[object setValue:dictionary forKey:@"plist"];
				[object setValue:[self temporaryDictionaryFromOriginal:dictionary] forKey:@"temporaryPlist"];
			}
			[LINMain resetCurrentPlistChanged]; // So that we don't get the dialogue twice
			return YES;
		}
	} else {
		return YES;
	}
	
	
}


- (void)refreshObject:(id)object path:(NSString *)path
{
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	[icon setSize:NSMakeSize(16.0, 16.0)];
	[object setValue:icon forKey:@"icon"];
	
	[LINMain resetCurrentPlistChanged];
	[[LINInterface plistsOutlineView] reloadData];
}


- (void)expandDirectoriesThatShouldBeExpanded
{
	NSArray *nodes = [[[LINInterface plistsTreeController] arrangedObjects] childNodes];
	id node;
	for (node in nodes) {
		if ([[[node representedObject] valueForKey:@"path"] isEqualToString:MYAGENTS] || [[[node representedObject] valueForKey:@"path"] isEqualToString:USERSAGENTS] || [[[node representedObject] valueForKey:@"path"] isEqualToString:USERSDAEMONS]) {
			[[LINInterface plistsOutlineView] expandItem:node];
		}
	}
}


- (NSString *)stringFromDictionary:(NSDictionary *)dictionary
{
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
	NSString *plistString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	return plistString;
}


- (void)checkIfValidPlist:(NSString *)string
{
	BOOL valid = [self validateStringAsPlist:string];
	
	if (valid == TRUE) {
		[[LINInterface expertTextField] setStringValue:NSLocalizedString(@"A valid plist", @"A valid plist")];
		[[LINInterface expertValidPlistIcon] setImage:[LINInterface validIcon]];
	} else {
		[[LINInterface expertTextField] setStringValue:NSLocalizedString(@"This is not a valid plist", @"This is not a valid plist")];
		[[LINInterface expertValidPlistIcon] setImage:[LINInterface notValidIcon]];
	}
}


- (BOOL)validateStringAsPlist:(NSString *)string
{
	BOOL validates = YES;
	
	@try {
		[string propertyList];
	}
	@catch (NSException *exception) {
		if ([[exception name] isEqualToString:NSParseErrorException]) {
			validates = NO;
		} else {
			[exception raise];
		}
	}
	@finally {
		
	}
	
	return validates;
}


- (void)changeToBasicMode
{
	[[LINInterface modeButton] setTitle:EXPERT_MODE_TITLE];
	
}


- (void)changeToExpertMode
{
	
	[[LINInterface plistsTreeController] commitEditing];
	
	id object = [[[LINInterface plistsTreeController] selectedObjects] objectAtIndex:0];

	NSDictionary *dictionary = [LINVarious finalDictionaryFromOriginal:[object valueForKey:@"plist"] temporary:[object valueForKey:@"temporaryPlist"]];
	
	NSString *string = [self stringFromDictionary:dictionary];
	
	[[LINInterface expertTextView] setString:string];
	
	[object setValue:string forKeyPath:@"temporaryPlist.ExpertPlistString"];
	
	[self checkIfValidPlist:string];
	
	//[[LINInterface plistsTreeController] rearrangeObjects];
	
	[[LINSyntaxColouring sharedInstance] recolourCompleteDocument];
	
	[[LINInterface modeButton] setTitle:BASIC_MODE_TITLE];
}


- (BOOL)shouldUpdateDictionaryFromExpertString
{
	NSString *string = [[LINInterface expertTextView] string];
	
	if ([self validateStringAsPlist:string] == NO) {
		
		[self standardAlertSheetWithMessage:NSLocalizedString(@"It does not validate as a plist", @"It does not validate as a plist") informativeText:NSLocalizedString(@"You cannot do anything else until it validates. Remember that you can undo any changes you have made if you can't get it to validate.", @"You cannot do anything else until it validates. Remember that you can undo any changes you have made if you can't get it to validate.") suppressionString:nil];
		
		return NO;
	}
	
	return YES;	
}


- (void)updateDictionaryFromExpertString
{
	NSString *string = [[LINInterface expertTextView] string];
	
	BOOL thereArePreviousChanges = [LINMain currentPlistHasUnsavedChanges]; 

	NSData *plistData = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSPropertyListFormat format;
	id dictionary = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:nil];
	
	id object = [[[LINInterface plistsTreeController] selectedObjects] objectAtIndex:0];
	
	[object setValue:string forKey:@"plistString"];
	[object setValue:dictionary forKey:@"plist"];
	[object setValue:[self temporaryDictionaryFromOriginal:dictionary] forKey:@"temporaryPlist"];

	if (thereArePreviousChanges) {
		[LINMain currentPlistChanged];
	} else {
		[LINMain resetCurrentPlistChanged];
	}
}


- (void)insertParameter:(id)sender
{
	NSInteger tag = [sender tag];
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[[LINInterface insertParametersArray] objectAtIndex:tag]];
	NSTextView *textView = [LINInterface expertTextView];
	NSString *string = [textView string];
	NSString *key = [NSString stringWithFormat:@"<key>%@</key>", [dictionary valueForKey:@"key"]];
	NSRange range = [string rangeOfString:key];
	
	if (range.location == NSNotFound) {
		range = [string rangeOfString:@"</dict>\n</plist>"];
		if (range.location != NSNotFound) {
			range.length = 0;
		} else {
			range = NSMakeRange([string length], 0);
		}
		[textView setSelectedRange:range];
		NSString *insertString = [NSString stringWithFormat:@"\t%@\n\t%@\n", key, [dictionary valueForKey:@"value"]];
		[textView insertText:insertString];
		range.length = [insertString length];
	}
	
	[textView scrollRangeToVisible:range];
	[textView setSelectedRange:range];
	[textView showFindIndicatorForRange:range];
	
	[[LINInterface insertParameterPopUp] selectItemAtIndex:0];
	
	[[LINInterface mainWindow] makeFirstResponder:[LINInterface expertTextView]];
}


@end
