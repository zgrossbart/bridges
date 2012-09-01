//
//  RootMenuViewController.h
//  bridges2
//
//  Created by Zack Grossbart on 8/26/12.
//
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "Level.h"

@interface RootMenuViewController : UIViewController<CCDirectorDelegate> {
    UIWindow *window_;
	UINavigationController *navController_;
	
	CCDirectorIOS	*director_;							// weak ref
    CCGLView *glView_;
    
    bool _hasInit;

}

@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic, retain) IBOutlet UIWindow *window;

-(void)showLevel:(Level*) level;

- (IBAction)goHomeTapped:(id)sender;

@end
