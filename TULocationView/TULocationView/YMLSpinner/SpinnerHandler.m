#import "SpinnerHandler.h"
#import <QuartzCore/QuartzCore.h>

@interface SpinnerHandler () {
    BOOL isStopped;
}

@end

@implementation SpinnerHandler

@synthesize backgroundView;
@synthesize contentView, spinnerView;
@synthesize messageLabel;

#pragma mark - Class Methods

+ (void) startSpinnerOnView:(UIView *)viewParent {
    SpinnerHandler *handler = [[SpinnerHandler alloc] initWithParentView:viewParent];
    [viewParent addSubview:handler];
    [handler startAnimation];
}

+ (void) startSpinnerOnView:(UIView *)viewParent withMessage:(NSString*)message {
    SpinnerHandler *handler = [[SpinnerHandler alloc] initWithParentView:viewParent andMessage:message];
    [viewParent addSubview:handler];
    [handler startAnimation];
}

+ (void) startPullDownSpinnerOnView:(UIView *)viewParent {
    SpinnerHandler *handler = [[SpinnerHandler alloc] initPullDownWithParentView:viewParent];
    [viewParent addSubview:handler];
    [handler startAnimation];
}

+ (void) stopSpinnerOnView:(UIView *)viewParent {
    for (UIView *subView in [viewParent subviews]) {
        if ([subView isKindOfClass:[SpinnerHandler class]]) {
            [(SpinnerHandler *)subView stopAnimation];
            break;
        }
    }
}

+ (void) stopAllSpinnerOnView:(UIView *)viewParent {
    for (UIView *subView in [viewParent subviews]) {
        if ([subView isKindOfClass:[SpinnerHandler class]]) {
            [(SpinnerHandler *)subView stopAnimation];
        }
    }
}


#pragma mark - Init Methods

- (id) initWithParentView:(UIView *)viewParent andMessage:(NSString*)message {
    self = [super initWithFrame:[viewParent bounds]];
    if (self) {
        [self setAlpha:0.0];
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewParent.frame.size.width, viewParent.frame.size.height)];
        backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        backgroundView.tag = 2028;
        [self addSubview:backgroundView];
        
        //  message = nil;//[SpinnerHandler makeRandomMessage];
        
        CGSize imgvActivitySize = CGSizeMake(50, 50);
        CGSize viewActivitySize = CGSizeZero;
        CGSize lblActivitySize = CGSizeZero;
        CGSize viewForLoadingSize = CGSizeMake(viewParent.frame.size.width, viewParent.frame.size.height);
        if(message == nil || message.length == 0)
        {
            viewActivitySize = CGSizeMake(imgvActivitySize.width, imgvActivitySize.width);
            lblActivitySize = CGSizeZero;
        }
        else
        {
            viewActivitySize = CGSizeMake(150, 120);
            lblActivitySize = CGSizeMake((viewActivitySize.width-10), (viewActivitySize.height-imgvActivitySize.height));
        }
        
        
        contentView = [[UIImageView alloc] initWithFrame:CGRectMake((viewForLoadingSize.width - viewActivitySize.width)/2,
                                                                        (viewForLoadingSize.height - viewActivitySize.height)/2,
                                                                        viewActivitySize.width,
                                                                        viewActivitySize.height)];
        [contentView setImage:[UIImage stretchableImageWithName:@"bg_alertview" extension:@"png" topCap:12 leftCap:12 bottomCap:11 andRightCap:11]];
        contentView.tag = 2029;
        [backgroundView addSubview:contentView];
        
        
        
        spinnerView = [[UIImageView alloc] initWithFrame:CGRectMake((viewActivitySize.width - imgvActivitySize.width)/2,
                                                                                  ((message == nil || message.length == 0) ? (viewActivitySize.height - imgvActivitySize.height)/2 : 20.0),
                                                                                  imgvActivitySize.width,
                                                                                  imgvActivitySize.height)];
        spinnerView.backgroundColor = [UIColor clearColor];
        spinnerView.tag = 2030;
        [contentView addSubview:spinnerView];
        spinnerView.image = [UIImage imageNameInBundle:@"img_loading" withExtension:@"png"];
        
        
        
        messageLabel = [[UILabel alloc]initWithFrame:CGRectMake((viewActivitySize.width - lblActivitySize.width)/2,
                                                                        imgvActivitySize.height + 6,
                                                                        lblActivitySize.width,
                                                                        (viewActivitySize.height - imgvActivitySize.height))];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textColor = [UIColor colorWith255Red:142.0 green:144.0 blue:146.0 alpha:1.0];
        messageLabel.text = message;//@"Running to fetch view for you !!!";
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        messageLabel.numberOfLines = 0;
        messageLabel.tag = 2031;
        [contentView addSubview:messageLabel];
    }
    
    return self;
}

- (id) initWithParentView:(UIView *)viewParent {
    self = [super initWithFrame:[viewParent bounds]];
    if (self) {
        [self setAlpha:0.0];
        
        CGSize viewForLoadingSize = CGSizeMake(viewParent.frame.size.width, viewParent.frame.size.height);
        CGSize imgvActivitySize = CGSizeMake(50, 50);
        CGSize viewActivitySize = CGSizeMake(80, 80);
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewForLoadingSize.width, viewForLoadingSize.height)];
        backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        backgroundView.tag = 2028;
        [self addSubview:backgroundView];
        
        
        
        contentView = [[UIImageView alloc] initWithFrame:CGRectMake((viewForLoadingSize.width - viewActivitySize.width)/2,
                                                                        (viewForLoadingSize.height - viewActivitySize.height)/2,
                                                                        viewActivitySize.width,
                                                                        viewActivitySize.height)];
        [contentView setImage:[UIImage stretchableImageWithName:@"bg_alertview" extension:@"png" topCap:12 leftCap:12 bottomCap:11 andRightCap:11]];
        contentView.tag = 2029;
        [backgroundView addSubview:contentView];
        
        
        
        spinnerView = [[UIImageView alloc] initWithFrame:CGRectMake((viewActivitySize.width - imgvActivitySize.width)/2,
                                                                                  (viewActivitySize.height - imgvActivitySize.height)/2,
                                                                                  imgvActivitySize.width,
                                                                                  imgvActivitySize.height)];
        spinnerView.backgroundColor = [UIColor clearColor];
        spinnerView.tag = 2030;
        [contentView addSubview:spinnerView];
        spinnerView.image = [UIImage imageNameInBundle:@"img_loading" withExtension:@"png"];
    }
    
    return self;
}

- (id) initPullDownWithParentView:(UIView *)viewParent {
    self = [super initWithFrame:[viewParent bounds]];
    if (self) {
        CGSize viewForLoadingSize = CGSizeMake(viewParent.frame.size.width, viewParent.frame.size.height);
        CGSize imgvActivitySize = CGSizeMake(30, 30);
//        CGSize viewActivitySize = CGSizeMake(50, 50);
        
//        viewForLoading = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewForLoadingSize.width, viewForLoadingSize.height)];
//        viewForLoading.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
//        viewForLoading.tag = 2028;
//        [self addSubview:viewForLoading];       
//        
//        
//        viewActivity = [[UIImageView alloc] initWithFrame:CGRectMake((viewForLoadingSize.width - viewActivitySize.width)/2,
//                                                                     (viewForLoadingSize.height - viewActivitySize.height)/2,
//                                                                     viewActivitySize.width,
//                                                                     viewActivitySize.height)];
//        [viewActivity setImage:[self stretchableImageWithName:@"bg_alertview" extension:@"png" topCap:12 leftCap:12 bottomCap:11 andRightCap:11]];
//        viewActivity.tag = 2029;
//        [viewForLoading addSubview:viewActivity];
        
        
        
//        imgvActivity = [[UIImageView alloc] initWithFrame:CGRectMake((viewActivitySize.width - imgvActivitySize.width)/2,
//                                                                     (viewActivitySize.height - imgvActivitySize.height)/2,
//                                                                     imgvActivitySize.width,
//                                                                     imgvActivitySize.height)];
        spinnerView = [[UIImageView alloc] initWithFrame:CGRectMake((viewForLoadingSize.width - imgvActivitySize.width)/2,
                                                                     (viewForLoadingSize.height - imgvActivitySize.height)/2,
                                                                     imgvActivitySize.width,
                                                                     imgvActivitySize.height)];
        spinnerView.backgroundColor = [UIColor clearColor];
        spinnerView.tag = 2030;
//        [viewActivity addSubview:imgvActivity];
        [self addSubview:spinnerView];
        spinnerView.image = [UIImage imageNameInBundle:@"img_loading" withExtension:@"png"];
    }
    
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAlpha:0.0];
        
        CGSize viewForLoadingSize = frame.size;
        CGSize imgvActivitySize = CGSizeMake(50, 50);
        CGSize viewActivitySize = CGSizeMake(80, 80);
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewForLoadingSize.width, viewForLoadingSize.height)];
        backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        backgroundView.tag = 2028;
        [self addSubview:backgroundView];
        
        
        
        contentView = [[UIImageView alloc] initWithFrame:CGRectMake((viewForLoadingSize.width - viewActivitySize.width)/2,
                                                                     (viewForLoadingSize.height - viewActivitySize.height)/2,
                                                                     viewActivitySize.width,
                                                                     viewActivitySize.height)];
        [contentView setImage:[UIImage stretchableImageWithName:@"bg_alertview" extension:@"png" topCap:12 leftCap:12 bottomCap:11 andRightCap:11]];
        contentView.tag = 2029;
        [backgroundView addSubview:contentView];
        
        
        
        spinnerView = [[UIImageView alloc] initWithFrame:CGRectMake((viewActivitySize.width - imgvActivitySize.width)/2,
                                                                    (viewActivitySize.height - imgvActivitySize.height)/2,
                                                                    imgvActivitySize.width,
                                                                    imgvActivitySize.height)];
        spinnerView.backgroundColor = [UIColor clearColor];
        spinnerView.tag = 2030;
        [contentView addSubview:spinnerView];
        spinnerView.image = [UIImage imageNameInBundle:@"img_loading" withExtension:@"png"];
    }
    
    return self;
}


#pragma mark - Public Methods

- (void) startAnimation {
    isStopped = NO;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [animation setFromValue:[NSNumber numberWithFloat:0]];
    [animation setToValue:[NSNumber numberWithFloat:M_PI * 2]];
    [animation setDuration:1.0];
    [animation setDelegate:self];
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    [[spinnerView layer] addAnimation:animation forKey:nil];
    
    if ([self alpha] == 0.0) {
        __weak SpinnerHandler *weakSelf = self;
        [UIView animateWithDuration:0.3
                         animations:^{
                             [weakSelf setAlpha:1.0];
                         }
                         completion:nil];
    }
}

- (void) stopAnimation {
    isStopped = YES;
    [[spinnerView layer] removeAllAnimations];
    
    __weak SpinnerHandler *weakSelf = self;
    [UIView animateWithDuration:0.3
                     animations:^{
                         [weakSelf setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         [weakSelf removeFromSuperview];
                     }];
}

- (void) stopAnimationAndKeepView {
    isStopped = YES;
    [[spinnerView layer] removeAllAnimations];
    
    __weak SpinnerHandler *weakSelf = self;
    [UIView animateWithDuration:0.3
                     animations:^{
                         [weakSelf setAlpha:0.0];
                     }
                     completion:nil];
}


#pragma mark - Animation Delegate

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!isStopped) {
        [self startAnimation];
    }
}


#pragma mark - Dealloc

- (void) dealloc {
    backgroundView = nil;
    contentView = nil;
    spinnerView = nil;
    messageLabel = nil;
}


@end
