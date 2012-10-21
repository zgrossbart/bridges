//
//  MainPageViewController.h
//  bridges2
//
//  Created by Zack Grossbart on 10/21/12.
//
//

#import <UIKit/UIKit.h>
#import "MainMenuViewController.h"

@interface MainPageViewController : UIViewController <UIScrollViewDelegate> {
    
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UIPageControl *_pageControl;
}

- (id)initWithNibNameAndMenuView:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menu:(MainMenuViewController*) menuView;

@property (retain, nonatomic) IBOutlet UIButton *backBtn;
- (IBAction)pageChanged:(id)sender;
- (IBAction)backToMainTapped:(id)sender;

@end
