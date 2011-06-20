###############################################################################
# SubList.pl                                                                  #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.1                                                    #
# Released:       November 8, 2005                                            #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2005 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by: The YaBB Development Team                                      #
#              with assistance from the YaBB community.                       #
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com            #
#               Your source for web hosting, web design, and domains.         #
###############################################################################

$sublistplver = 'YaBB 2.1 $Revision: 1.1 $';
if($action eq 'detailedversion') { return 1; }

%director=(

'newmesg',"Recent.pl&new_messages",
'newmarkread',"Recent.pl&nm_mark_read",

'safetylock',"BanWithGroup.pl&safety_lock",
'safetyunlock',"BanWithGroup.pl&safety_unlock",

'bwg',"BanWithGroup.pl&ban_with_group",
'ubwg',"BanWithGroup.pl&unban_with_group",
'ebwg',"BanWithGroup.pl&expire_ban_with_group",
'pbwg',"BanWithGroup.pl&ban_with_group_passthrough",

'nbwg', "BanWithGroup.pl&bwg_message_form",
'mbwg', "BanWithGroup.pl&bwg_add_message",
'bwglog',"BanWithGroup.pl&show_ban_log",

'novyny',"Novyny.pl&Novyny",

'activate',"Register.pl&user_activation",
'favorites',"Favorites.pl&Favorites",
'addfav',"Favorites.pl&AddFav",
'remfav',"Favorites.pl&RemFav",
'boardnotify',"Notify.pl&BoardNotify",
'boardnotify2',"Notify.pl&BoardNotify2",
'boardnotify3',"Notify.pl&BoardNotify2",
'checkboardpw',"MBCoptions.pl&checkboardpw",
'collapse_cat',"BoardIndex.pl&Collapse_Cat",
'collapse_all',"BoardIndex.pl&Collapse_All",
'deletemultimessages',"InstantMessage.pl&Del_Some_IM",
'display',"Display.pl&Display",
'dereferer',"Subs.pl&Dereferer",
'help',"HelpCentre.pl&GetHelpFiles",
'hide',"SetStatus.pl&SetStatus",
'im',"InstantMessage.pl&IMIndex",
'imcb',"InstantMessage.pl&CallBack",
'imgroups',"InstantMessage.pl&IMGroups",
'imoutbox',"InstantMessage.pl&IMIndex",
'imprint',"Printpage.pl&Print_IM",
'imremove',"InstantMessage.pl&IMRemove",
'imsend',"InstantMessage.pl&IMPost",
'imsend2',"InstantMessage.pl&IMPost2",
'imshow',"InstantMessage.pl&IMShow",
'imstorage',"InstantMessage.pl&IMIndex",
'imtostore',"InstantMessage.pl&IMToStore",
'lock',"SetStatus.pl&SetStatus",
'lockpoll',"Poll.pl&LockPoll",
'login',"LogInOut.pl&Login",
'login2',"LogInOut.pl&Login2",
'logout',"LogInOut.pl&Logout",
'messageindex',"MessageIndex.pl&MessageIndex",
'markasread',"MessageIndex.pl&MarkRead",
'markallasread',"BoardIndex.pl&MarkAllRead",
'markims',"InstantMessage.pl&MarkAll",
'markunread',"Display.pl&undumplog",
'mailto',"Subs.pl&MailTo",
'messagepagedrop',"MessageIndex.pl&MessagePageindex",
'messagepagetext',"MessageIndex.pl&MessagePageindex",
'threadpagedrop',"Display.pl&ThreadPageindex",
'threadpagetext',"Display.pl&ThreadPageindex",
'memberpagedrop',"Subs.pl&MemberPageindex",
'memberpagetext',"Subs.pl&MemberPageindex",
'ml',"Memberlist.pl&Ml",
'mlall',"Memberlist.pl&Ml",
'modify',"ModifyMessage.pl&ModifyMessage",
'modify2',"ModifyMessage.pl&ModifyMessage2",
'movethread',"MoveTopic.pl&MoveThread",
'movethread2',"MoveTopic.pl&MoveThread2",
'msn',"Profile.pl&MSN",
'multiadmin',"RemoveTopic.pl&Multi",
'multidel',"ModifyMessage.pl&MultiDel",
'multiremfav',"Favorites.pl&MultiRemFav",
'next',"Display.pl&NextPrev",
'notify',"Notify.pl&Notify",
'notify2',"Notify.pl&Notify2",
'notify3',"Notify.pl&Notify3",
'notify4',"Notify.pl&Notify4",
'pages',"MessageIndex.pl&ListPages",
'post',"Post.pl&Post",
'post2',"Post.pl&Post2",
'prev',"Display.pl&NextPrev",
'print',"Printpage.pl&Print",
'profile',"Profile.pl&ModifyProfile",
'profile2',"Profile.pl&ModifyProfile2",
'profileAdmin',"Profile.pl&ModifyProfileAdmin",
'profileAdmin2',"Profile.pl&ModifyProfileAdmin2",
'profileCheck',"Profile.pl&ProfileCheck",
'profileCheck2',"Profile.pl&ProfileCheck2",
'profileContacts',"Profile.pl&ModifyProfileContacts",
'profileContacts2',"Profile.pl&ModifyProfileContacts2",
'profileIM',"Profile.pl&ModifyProfileIM",
'profileIM2',"Profile.pl&ModifyProfileIM2",
'profileOptions',"Profile.pl&ModifyProfileOptions",
'profileOptions2',"Profile.pl&ModifyProfileOptions2",
'recent',"Recent.pl&RecentPosts",
'recentlist',"Recent.pl&RecentTopicsList",
'register',"Register.pl&Register",
'register2',"Register.pl&Register2",
'reminder',"LogInOut.pl&Reminder",
'reminder2',"LogInOut.pl&Reminder2",
'removethread',"RemoveTopic.pl&DeleteThread",
'resetpass',"LogInOut.pl&Reminder3",
'revalidatesession',"Sessions.pl&SessionReval",
'revalidatesession2',"Sessions.pl&SessionReval2",
'search',"Search.pl&plushSearch1",
'search2',"Search.pl&plushSearch2",
'sendtopic',"SendTopic.pl&SendTopic",
'sendtopic2',"SendTopic.pl&SendTopic2",
'setmsn',"Display.pl&SetMsn",
'setgtalk',"Display.pl&SetGtalk",
'shownotify',"Notify.pl&ShowNotifications",
'showvoters',"Poll.pl&votedetails",
'smilieput',"DoSmilies.pl&SmiliePut",
'smilieindex',"DoSmilies.pl&SmilieIndex",
'splice',"SplitSplice.pl&Splice",
'splice2',"SplitSplice.pl&Splice2",
'split',"SplitSplice.pl&Split",
'split2',"SplitSplice.pl&Split2",
'sticky', "SetStatus.pl&SetStatus",
'undovote',"Poll.pl&UndoVote",
'usersrecentposts',"Profile.pl&usersrecentposts",
'validate',"Decoder.pl&convert",
'viewprofile',"Profile.pl&ViewProfile",
'vote',"Poll.pl&DoVote",
);

1;

