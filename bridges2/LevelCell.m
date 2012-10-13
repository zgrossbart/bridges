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

#import "LevelCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation LevelCell

@synthesize titleLabel = _titleLabel;
@synthesize screenshot = _screenshot;
@synthesize checkMark = _checkMark;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"LevelCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [[arrayOfViews objectAtIndex:0] retain];
    }
    
    return self;
}

-(void)setBorderVisible:(bool) visible {
    if (visible) {
        [self.screenshot.layer setCornerRadius:8.0f];
        [self.screenshot.layer setMasksToBounds:YES];
        self.screenshot.layer.borderColor = [UIColor colorWithRed:(1.0 * 170) / 255 green:(1.0 * 170) / 255 blue:(1.0 * 170) / 255 alpha:0.5].CGColor;
        self.screenshot.layer.borderWidth = 2.0f;
    } else {
        self.screenshot.layer.borderColor = [[UIColor clearColor] CGColor];
    }
}

-(void)dealloc {
    [super dealloc];
}
@end
