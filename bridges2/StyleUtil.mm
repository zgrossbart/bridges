/*******************************************************************************
 *
 * Copyright 2012 Zack Grossbart
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "StyleUtil.h"

@implementation StyleUtil

+(void)styleButton:(UIButton*) button {
    button.titleLabel.opaque = NO;
    button.titleLabel.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [button.layer setCornerRadius:8.0f];
    [button.layer setMasksToBounds:YES];
    button.backgroundColor = [UIColor colorWithRed:(1.0 * 45) / 255 green:(1.0 * 43) / 255 blue:(1.0 * 40) / 255 alpha:0.9];
    button.titleEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor:[[UIColor blackColor] CGColor]];
    
    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width + 6, button.frame.size.height + 3);
}

@end
