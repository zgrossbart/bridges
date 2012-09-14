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
#import "Level.h"

/** 
 * The LevelMgr manages the list of levels, generates the level 
 * screenshots and handles the Cocos2d framework initialization.
 */
@interface LevelMgr : NSObject {
    @private
    CCDirectorIOS	*director_;							// weak ref
    CCGLView *glView_;
    
    bool _hasInit;
}

/** 
 * Gets the singleton of the LevelMgr
 */
+(LevelMgr *)getLevelMgr;

/** 
 * Generate a set of images of each level in the documents directory.
 *
 * @param bounds the size to draw the level image.
 */
-(void)drawLevels:(CGRect) bounds;

/** 
 * The loaded levels for this game.
 */
@property (readonly, retain) NSMutableDictionary *levels;

/** 
 * The array of sorted level IDs.
 */
@property (readonly,copy) NSArray *levelIds;

/** 
 * The graphics view used to add the Cocos2d view into the UIKit stack
 */
@property (readonly) CCGLView *glView;


@end