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


/**
 * These are used as tags for identifying items
 * after collision detection.
 */
static int const PLAYER = 0;
static int const RIVER = 1;
static int const RIVEROVERLAY = 2;
static int const RIVERJOINT = 3;
static int const BRIDGE = 4;
static int const BRIDGE3 = 5;
static int const BRIDGE4 = 6;
static int const HOUSE = 7;
static int const SUBWAY = 8;
static int const LEVEL = 9;

/**
 * This enum defines the different colors for houses,
 * bridges, and the player in the game.
 */
typedef enum {
    cNone = -1,
    cRed = 0,
    cBlue = 1,
    cGreen = 2,
    cOrange = 3,
    cBlack = 4} BridgeColor;

/**
 * This enum defines the different directions bridges 
 * can point and the player can travel in the game.
 */
typedef enum {
    dNone = -1,
    dLeft = 1,
    dRight = 2,
    dUp = 3,
    dDown = 4} BridgeDir;

/**
 * The tile count represents the number of playable 
 * tiles in a give board.  All level object positions
 * are specified in tiles.  
 *
 * The playable level is 42 tiles wide and 28 tiles tall.
 */
static int const TILE_COUNT = 28;

/**
 * This variable controls debug drawing.  Change it to true
 * to see the tile grid and the boxes for each sprite.
 */
static bool const DEBUG_DRAW = true;

/**
 * Each river is drawn with a set of one tile sprites that we
 * repeat to fill up the length of the river.  It makes the 
 * rivers look a little repetative so we add some longer sections
 * at random intervals to give them some variety and make the 
 * rivers look a little more natural.  
 *
 * Change this constant to false to turn off the random river 
 * overlays.  This is sometimes useful for debugging.
 *
 * This variable is used in Level.mm.
 */
static bool const DRAW_RIVER_OVERLAY = false;

/**
 * The size of the screen shot icon on iPhone
 */
static int const IPHONE_LEVEL_IMAGE_W = 96;
static int const IPHONE_LEVEL_IMAGE_H = 64;

/**
 * The size of the screen shot icon on iPad
 */
static int const IPAD_LEVEL_IMAGE_W = 150;
static int const IPAD_LEVEL_IMAGE_H = 100;

/**
 * We scale up the node sprites on iPad since we have more room and the
 * larger sprites are a little easier to see.  We could just create a 
 * second sprite sheet with the iPad sprites, but this is easier and makes
 * the download size of the app smaller.
 */
static int const IPAD_SCALE_FACTOR = 2;