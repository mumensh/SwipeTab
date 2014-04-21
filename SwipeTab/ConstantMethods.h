//
//  ConstantMethods.h
//  Rawabi Projects
//
//  Created by ASAL on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <QuartzCore/QuartzCore.h>

//static NSString *keyEncryption = @"WrittenInTheStars";
@interface ConstantMethods : NSObject {
    
}
+ (UIColor *) colorWithHexString: (NSString *) hex;
+ (void) writeToPlist: (NSString*)fileName withData:(NSMutableArray *)data;
+ (NSMutableArray *) readFromPlist: (NSString *)fileName;
+ (NSString*)retrieveFromUserDefaults:(NSString*)key;
+ (NSString*) escapeUnicodeString:(NSString*)string;
+ (NSString*) unescapeUnicodeString:(NSString*)string;
+ (void)saveToUserDefaults:(NSString*)key value:(NSString*)valueString;
+ (UIView *)getLineIn:(float)yAxes WithWidth:(float)width;
+ (NSMutableAttributedString *)customStatusText:(NSString *)stringToColorize andIndexPathRow:(NSString *)indexOfColoredText;
+ (CAGradientLayer *)gradiantLayer:(CGRect)bounds;
+ (UIColor *)randomColor;

@end
