//
//  CRMemoTextView.m
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/01.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRMemoTextView.h"

@implementation CRMemoTextView
{
    UILabel *_placeHolderLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textValueDidChange:) name:UITextViewTextDidChangeNotification object:nil];
        _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 6 , self.frame.size.width - 16, 20)];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self addSubview:_placeHolderLabel];
    _placeHolderLabel.textColor = self.placeHolderColor;
    _placeHolderLabel.text = self.placeHolder;
    _placeHolderLabel.font = self.font;
}

- (void)textValueDidChange:(NSNotification *)notification
{
    if(self.text.length == 0) {
        _placeHolderLabel.hidden = NO;
    } else {
        _placeHolderLabel.hidden = YES;
    }
}

@end
