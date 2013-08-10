
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SpinnerHandler : UIView {
    UIView *backgroundView;
    UIImageView *contentView, *spinnerView;
    UILabel *messageLabel;
}

@property (nonatomic, readonly) UIView *backgroundView;
@property (nonatomic, readonly) UIImageView *contentView, *spinnerView;
@property (nonatomic, readonly) UILabel *messageLabel;

+ (void) startSpinnerOnView:(UIView *)viewParent;
+ (void) startSpinnerOnView:(UIView *)viewParent withMessage:(NSString*)message;
+ (void) startPullDownSpinnerOnView:(UIView *)viewParent;
+ (void) stopSpinnerOnView:(UIView *)viewParent;
+ (void) stopAllSpinnerOnView:(UIView *)viewParent;

- (id) initWithParentView:(UIView *)viewParent andMessage:(NSString*)message;
- (id) initWithParentView:(UIView *)viewParent;
- (id) initPullDownWithParentView:(UIView *)viewParent;

- (void) startAnimation;
- (void) stopAnimation;
- (void) stopAnimationAndKeepView;

@end
