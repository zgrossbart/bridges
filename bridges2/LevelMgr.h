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
#import "LevelSet.h"

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
 * Get the set of the levels for the specified level set index.
 */
+(LevelSet*)getLevelSet: (int) index;

/**
 * This is a helper method to get a specific level.
 *
 * @param set the index of the set containing this level
 * @param levelId the ID of the level to find
 */
+(Level*)getLevel: (int) set: (NSString*) levelId;

/** 
 * Generate a set of images of each level in the documents directory.
 *
 * @param bounds the size to draw the level image.
 */
-(void)drawLevels:(CGRect) bounds;

/** 
 * The loaded levels for this game.
 */
//@property (readonly, retain) NSMutableDictionary *levels;

/** 
 * The array of sorted level IDs.
 */
//@property (readonly,copy) NSArray *levelIds;

/**
 * The array of sorted level sets.
 */
@property (readonly,copy) NSArray *levelSets;

/** 
 * The graphics view used to add the Cocos2d view into the UIKit stack
 */
@property (readonly) CCGLView *glView;


@end