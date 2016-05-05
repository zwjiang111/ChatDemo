//
//  UITabelView+CellRegister.m
//
//
//  Created by zhiwen jiang on 16/4/12.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import "UITableView+CellRegister.h"

#import "ChatMessageCell.h"
#import "ChatTextMessageCell.h"
#import "ChatImageMessageCell.h"
#import "ChatVoiceMessageCell.h"
#import "ChatDateTimeMessageCell.h"
#import "ChatLocationMessageCell.h"
#import "ChatCallMessageCell.h"

@implementation UITableView (CellRegister)

- (void)registerChatMessageCellClass
{
    [self registerClass:[ChatImageMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_ImageMessage_GroupCell"];
    [self registerClass:[ChatImageMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_ImageMessage_SingleCell"];
    [self registerClass:[ChatImageMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_ImageMessage_GroupCell"];
    [self registerClass:[ChatImageMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_ImageMessage_SingleCell"];
    
    [self registerClass:[ChatImageMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_VideoMessage_GroupCell"];
    [self registerClass:[ChatImageMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_VideoMessage_SingleCell"];
    [self registerClass:[ChatImageMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_VideoMessage_GroupCell"];
    [self registerClass:[ChatImageMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_VideoMessage_SingleCell"];
    
    [self registerClass:[ChatLocationMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_LocationMessage_GroupCell"];
    [self registerClass:[ChatLocationMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_LocationMessage_SingleCell"];
    [self registerClass:[ChatLocationMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_LocationMessage_GroupCell"];
    [self registerClass:[ChatLocationMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_LocationMessage_SingleCell"];
    
    [self registerClass:[ChatVoiceMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_VoiceMessage_GroupCell"];
    [self registerClass:[ChatVoiceMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_VoiceMessage_SingleCell"];
    [self registerClass:[ChatVoiceMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_VoiceMessage_GroupCell"];
    [self registerClass:[ChatVoiceMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_VoiceMessage_SingleCell"];
    
    [self registerClass:[ChatTextMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_TextMessage_GroupCell"];
    [self registerClass:[ChatTextMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_TextMessage_SingleCell"];
    [self registerClass:[ChatTextMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_TextMessage_GroupCell"];
    [self registerClass:[ChatTextMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_TextMessage_SingleCell"];
    
    [self registerClass:[ChatCallMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_CallMessage_GroupCell"];
    [self registerClass:[ChatCallMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSelf_CallMessage_SingleCell"];
    [self registerClass:[ChatCallMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_CallMessage_GroupCell"];
    [self registerClass:[ChatCallMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_CallMessage_SingleCell"];
    
    [self registerClass:[ChatDateTimeMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSystem_DateTimeMessage_SingleCell"];
    [self registerClass:[ChatDateTimeMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerSystem_DateTimeMessage_GroupCell"];
    [self registerClass:[ChatDateTimeMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_DateTimeMessage_GroupCell"];
    [self registerClass:[ChatDateTimeMessageCell class] forCellReuseIdentifier:@"ChatMessageCell_OwnerOther_DateTimeMessage_SingleCell"];
}

@end
