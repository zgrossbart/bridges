//
//  MainPageViewController.h
//  bridges2
//
//  Created by Zack Grossbart on 10/21/12.
//
//

#import <UIKit/UIKit.h>

@interface MainPageViewController : UIViewController <UIScrollViewDelegate> {
    
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UIPageControl *_pageControl;
}
- (IBAction)pageChanged:(id)sender;

@end
