/*
Lingon version 2.1.1, 2008-12-18
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://tuppis.com/lingon

Copyright 2005-2008 Peter Borg

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#ifdef DEBUG_STYLE_BUILD
	#define LogBool(bool) NSLog(@"The value of "#bool" is %@", bool ? @"YES" : @"NO")
	#define LogInt(number) NSLog(@"The value of "#number" is %d", number)
	#define LogFloat(number) NSLog(@"The value of "#number" is %f", number)
	#define Log(obj) NSLog(@"The value of "#obj" is %@", obj)
	#define LogChar(characters) NSLog(@#characters)
	#define Start NSDate *then = [NSDate date]
	#define Stop NSLog(@"Time elapsed: %f seconds", [then timeIntervalSinceNow] * -1)
	#define Pos NSLog(@"File=%s line=%d proc=%s", strrchr("/" __FILE__,'/')+1, __LINE__, __PRETTY_FUNCTION__)
#endif

#define MYAGENTS [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"LaunchAgents"]
#define USERSAGENTS @"/Library/LaunchAgents"
#define USERSDAEMONS @"/Library/LaunchDaemons"
#define SYSTEMAGENTS @"/System/Library/LaunchAgents"
#define SYSTEMDAEMONS @"/System/Library/LaunchDaemons"

#define MYAGENTSSTRING NSLocalizedString(@"My Agents", @"My Agents tab view label")
#define USERSAGENTSSTRING NSLocalizedString(@"Users Agents", @"Users Agents tab view label")
#define USERSDAEMONSSTRING NSLocalizedString(@"Users Daemons", @"Users Daemons tab view label")
#define SYSTEMAGENTSSTRING NSLocalizedString(@"System Agents", @"System Agents tab view label")
#define SYSTEMDAEMONSSTRING NSLocalizedString(@"System Daemons", @"System Daemons tab view label")


typedef enum {
	LINCheckForUpdatesNever = 0,
	LINCheckForUpdatesDaily = 1,
	LINCheckForUpdatesWeekly = 2,
	LINCheckForUpdatesMonthly = 3
} LINCheckForUpdatesInterval;

typedef enum {
	LINManPageLaunchdPlist = 1,
	LINManPageLaunchctl = 2,
	LINManPageLaunchd = 3
} LINManPage;

typedef enum {
	LINListSizeSmall = 0,
	LINListSizeLarge = 1
} LINListSize;

typedef enum {
	LINPeriodSeconds = 0,
	LINPeriodMinutes = 1,
	LINPeriodHours = 2
} LINPeriod;

typedef enum {
	LINWhichFolderMyAgents = 0,
	LINWhichFolderUsersAgents = 1,
	LINWhichFolderUsersDaemons = 2
} LINWhichFolder;

typedef enum {
	LINBasicMode = 0,
	LINExpertMode = 1
} LINMode;


#import "LINAuthenticationController.h"
#import "LINInterfaceController.h"
#import "LINMainController.h"
#import "LINPreferencesController.h"
#import "LINToolbarController.h"

#import "LINBasicPerformer.h"
#import "LINVariousPerformer.h"

#import "LINFileMenuController.h"
#import "LINViewMenuController.h"
#import "LINHelpMenuController.h"

#import "LINOutlineViewDelegate.h"
#import "LINSplitViewDelegate.h"
#import "LINWindowDelegate.h"

#import "LINApplication.h"
#import "LINDummyView.h"
#import "LINGradientBackgroundView.h"
#import "LINPlistListCell.h"
#import "LINWindow.h"

#import "NSToolbarItem+Lingon.h"

#import "LINSyntaxColouring.h"

#import "LINFontTransformer.h"


#import <Cocoa/Cocoa.h>
//#import <Carbon/Carbon.h>
#import <SystemConfiguration/SCNetwork.h>


#define OK_BUTTON NSLocalizedString(@"OK", @"OK-button")
#define CANCEL_BUTTON NSLocalizedString(@"Cancel", @"Cancel-button")

#define LINMain [LINMainController sharedInstance]
#define LINBasic [LINBasicPerformer sharedInstance]
#define LINInterface [LINInterfaceController sharedInstance]
#define LINVarious [LINVariousPerformer sharedInstance]
#define LINManagedObjectContext [[LINApplicationDelegate sharedInstance] managedObjectContext]

#define LINDefaults [[NSUserDefaultsController sharedUserDefaultsController] values]

#define UKNOWN_ERROR_WHEN_SAVING NSLocalizedString(@"An unknown error occurred when trying to save the configuration file %@", @"An unknown error occurred when trying to save the configuration file %@")
#define PLEASE_TRY_AGAIN NSLocalizedString(@"Please try again", @"Please try again")

#define NO_PLIST_SELECTED_STRING NSLocalizedString(@"Choose one on the left or create a new", @"Choose one on the left or create a new")

#define BASIC_MODE_TITLE NSLocalizedString(@"Basic Mode", @"Basic Mode")
#define EXPERT_MODE_TITLE NSLocalizedString(@"Expert Mode", @"Expert Mode")

@interface LINStandardHeader : NSObject
{
	
}

@end

