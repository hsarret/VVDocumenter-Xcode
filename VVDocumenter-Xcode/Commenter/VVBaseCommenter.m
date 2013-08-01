//
//  VVBaseCommenter.m
//  VVDocumenter-Xcode
//
//  Created by 王 巍 on 13-7-17.
//  Copyright (c) 2013年 OneV's Den. All rights reserved.
//

#import "VVBaseCommenter.h"
#import "VVArgument.h"

@implementation VVBaseCommenter
-(id) initWithIndentString:(NSString *)indent codeString:(NSString *)code
{
    self = [super init];
    if (self) {
        self.indent = indent;
        self.code = code;
        self.arguments = [NSMutableArray array];
    }
    return self;
}

#define FORMATTING 1

-(NSString *) startComment
{
#if FORMATTING == 1
    return @"/**\t<#Description#>";
#else
	return [NSString stringWithFormat:@"%@/**\n%@ *\t<#%@#>\n",self.indent,self.indent,@"Description"];
#endif
}

-(NSString *) argumentsComment
{
#if FORMATTING == 1
	NSUInteger tabSize = 4;
	NSUInteger maxLength = 0;
	for (VVArgument *arg in self.arguments) {
		if (arg.name.length > maxLength) {
			maxLength = arg.name.length;
		}
	}
	NSUInteger offset = ((maxLength / tabSize) + 1) * tabSize;

    NSMutableString *result = [NSMutableString stringWithString:@""];
	[ self.arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		VVArgument *arg = (VVArgument *)obj;
        if (result.length == 0) {
            [result appendFormat:@"\n"];
        }
		NSUInteger argLength = arg.name.length;
		NSUInteger left = offset - argLength;
		NSUInteger tabsCountToAlign = ((left / tabSize) + ((left % tabSize) ? 1 : 0));
        [result appendFormat:@"\t@param\t%@",arg.name];
		for (int i = 0; i < tabsCountToAlign; ++i ) {
			[result appendString:@"\t"];
		}
		[result appendString:@"<#description#>"];
		if (idx != self.arguments.count-1) {
			[result appendString:@"\n"];
		}
	} ];
#else
    NSMutableString *result = [NSMutableString stringWithString:@""];
    for (VVArgument *arg in self.arguments) {
        if (result.length == 0) {
            [result appendFormat:@"%@ *\n",self.indent];
        }
        [result appendFormat:@"%@ *\t@param\t%@\t<#%@ description#>\n",self.indent,arg.name,arg.name];
    }
#endif
    return result;
}

-(NSString *) returnComment

{
    if (!self.hasReturn) {
        return @"";
    } else {
#if FORMATTING == 1
        return [NSString stringWithFormat:@"\n\t@return\t<#description#>"];
#else
        return [NSString stringWithFormat:@"%@ *\n%@ *\t@return\t<#return value description#>\n",self.indent,self.indent];
#endif
    }
}

-(NSString *) endComment
{
#if FORMATTING == 1
    return [NSString stringWithFormat:@" */"];
#else
    return [NSString stringWithFormat:@"%@ */",self.indent];
#endif
}

-(NSString *) document
{
    return [NSString stringWithFormat:@"%@%@%@%@",[self startComment],
                                                  [self argumentsComment],
                                                  [self returnComment],
                                                  [self endComment]];
}

-(void) parseArguments
{
    [self.arguments removeAllObjects];
    NSArray * braceGroups = [self.code vv_stringsByExtractingGroupsUsingRegexPattern:@"\\(([^\\(\\)]*)\\)"];
    if (braceGroups.count > 0) {
        NSString *argumentGroupString = braceGroups[0];
        NSArray *argumentStrings = [argumentGroupString componentsSeparatedByString:@","];
        for (NSString *argumentString in argumentStrings) {
            VVArgument *arg = [[VVArgument alloc] init];
            argumentString = [argumentString vv_stringByReplacingRegexPattern:@"\\s+$" withString:@""];
            argumentString = [argumentString vv_stringByReplacingRegexPattern:@"\\s+" withString:@" "];
            NSMutableArray *tempArgs = [[argumentString componentsSeparatedByString:@" "] mutableCopy];
            while ([[tempArgs lastObject] isEqualToString:@" "]) {
                [tempArgs removeLastObject];
            }
            arg.name = [tempArgs lastObject];

            [tempArgs removeLastObject];
            arg.type = [tempArgs componentsJoinedByString:@" "];
            
            VVLog(@"arg type: %@", arg.type);
            VVLog(@"arg name: %@", arg.name);
            
            [self.arguments addObject:arg];
        }
    }

}
@end
