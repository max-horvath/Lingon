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



@implementation LINAuthenticationController

static id sharedInstance = nil;

+ (LINAuthenticationController *)sharedInstance
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




- (BOOL)performAuthenticatedSaveOfData:(NSData *)data path:(NSString *)path
{
	NSString *convertedPath = [NSString stringWithUTF8String:[path UTF8String]];
	NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [[NSPipe alloc] init];
    NSFileHandle *writeHandle = [pipe fileHandleForWriting];
	
    [task setLaunchPath:@"/usr/libexec/authopen"];
	[task setArguments:[NSArray arrayWithObjects:@"-c", @"-w", convertedPath, nil]];
    [task setStandardInput:pipe];
	
	[task launch];
	[writeHandle writeData:data];
	
	close([writeHandle fileDescriptor]); // Close it manually
	[writeHandle setValue:[NSNumber numberWithUnsignedShort:1] forKey:@"_flags"];
	
	[task waitUntilExit];
	
	NSInteger status = [task terminationStatus];
	
	if (status != 0) {
		[LINVarious standardAlertSheetWithMessage:[NSString stringWithFormat:UKNOWN_ERROR_WHEN_SAVING, path] informativeText:PLEASE_TRY_AGAIN suppressionString:nil];
		return NO;
	} else {
		[LINMain resetCurrentPlistChanged];
		return YES;
	}
}



@end
