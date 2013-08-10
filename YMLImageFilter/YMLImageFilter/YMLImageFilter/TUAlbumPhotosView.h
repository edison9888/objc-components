//
//  TUAlbumPhotosView.h
//  Tourean
//
//  Created by கார்த்திக் கேயன் on 4/30/13.
//  Copyright (c) 2013 vivekrajanna@gmail.com. All rights reserved.
//

@class ALAssetsGroup;

@interface TUAlbumPhotosView : UIView

- (id) initWithFrame:(CGRect)frame target:(id)target selector:(SEL)selector;
- (void) setAlbum:(ALAssetsGroup *)album;

@end
