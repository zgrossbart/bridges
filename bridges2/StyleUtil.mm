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
    
    if (button == nil) {
        return;
    }
    
    button.titleLabel.opaque = NO;
    button.titleLabel.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    button.titleLabel.textColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    button.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [button.layer setCornerRadius:8.0f];
    [button.layer setMasksToBounds:YES];
    button.backgroundColor = [UIColor colorWithRed:(1.0 * 45) / 255 green:(1.0 * 43) / 255 blue:(1.0 * 40) / 255 alpha:0.9];
    button.titleEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor:[[UIColor blackColor] CGColor]];
    button.titleLabel.font = [UIFont fontWithName:@"Avenir Book" size:16];
    
    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width + 6, button.frame.size.height + 3);
}

+(void)styleMenuButton:(UIButton*) button {
    
    if (button == nil) {
        return;
    }
    
    [StyleUtil styleButton:button];
    [button setTitleColor:[UIColor colorWithRed:(1.0 * 255) / 255 green:(1.0 * 241) / 255 blue:(1.0 * 70) / 255 alpha:0.9] forState: UIControlStateHighlighted];
}

+(void)styleNodeLabel:(UILabel*) label {
    label.textColor = [UIColor blackColor];
    
    label.backgroundColor = [UIColor colorWithRed:(1.0 * 170) / 255 green:(1.0 * 170) / 255 blue:(1.0 * 170) / 255 alpha:0.5];
    label.layer.cornerRadius = 6;
    label.font = [UIFont fontWithName:@"Avenir" size: 11.0];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    
    label.frame = CGRectMake(0, 0, label.frame.size.width + 6, label.frame.size.height + 3);
}

@end
