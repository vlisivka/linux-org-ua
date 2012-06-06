###############################################################################
# Settings.pl                                                                 #
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

########## Board Info ##########
# Note: these settings must be properly changed for YaBB to work

$maintenance = 0;                                                     # Set to 1 to enable Maintenance mode
$guestaccess = 1;                                                     # Set to 0 to disallow guests from doing anything but login or register

$mbname = q^Linux.org.ua^;                                            # The name of your YaBB forum
$forumstart = "01/01/01 о 01:01:01";                                 # The start date of your YaBB Forum
$Cookie_Length = 1;                                                   # Default minutes to set login cookies to stay for
$cookieusername = "Y2User-50066";                                     # Name of the username cookie
$cookiepassword = "Y2Pass-50066";                                     # Name of the password cookie
$cookiesession_name = "Y2Sess-50066";                                 # Name of the Session cookie

$regdisable = 0;                                                      # Set to 1 to disable user registration (only admin can register)
$RegAgree = 1;                                                        # Set to 1 to display the registration agreement when registering
$preregister = 0;                                                     # Set to 1 to use pre-registration and account activation
$preregspan = 24;                                                     # Time span in hours for users to account activation before cleanup.
$emailpassword = 1;                                                   # 0 - instant registration. 1 - password emailed to new members
$emailnewpass = 0;                                                    # Set to 1 to email a new password to members if they change their email address
$emailwelcome = 1;                                                    # Set to 1 to email a welcome message to users even when you have mail password turned off

$lang = "Ukrainian";                                                  # Default Forum Language
$default_template = "default";                                        # Default Forum Template

$mailprog = "/usr/sbin/sendmail";                                     # Location of your sendmail program
$smtp_server = "127.0.0.1";                                           # Address of your SMTP-Server
$smtp_auth_required = 1;                                              # Set to 1 if the SMTP server requires Authorisation
$authuser = q^^;                                                      # Username for SMTP authorisation
$authpass = q^^;                                                      # Password for SMTP authorisation
$webmaster_email = q^vlisivka@gmail.com^;                             # Your email address. (eg: $webmaster_email = q^admin@host.com^;)
$mailtype = 0;                                                        # Mail program to use: 0 = sendmail, 1 = SMTP, 2 = Net::SMTP

########## Layout ##########

$maintenancetext = "";                                                # User-defined text for Maintenance mode (leave blank for default text)
$MenuType = 1;                                                        # 1 for text menu or anything else for images menu
$profilebutton = 0;                                                   # 1 to show view profile button under post, or 0 for blank
$allow_hide_email = 1;                                                # Allow users to hide their email from public. Set 0 to disable
$showlatestmember = 0;                                                # Set to 1 to display "Welcome Newest Member" on the Board Index
$shownewsfader = 0;                                                   # 1 to allow or 0 to disallow NewsFader javascript on the Board Index
                                                                      # If 0, you'll have no news at all unless you put <yabb news> tag
                                                                      # back into template.html!!!
$Show_RecentBar = 1;                                                  # Set to 1 to display the Recent Post on Board Index
$showmodify = 1;                                                      # Set to 1 to display "Last modified: Realname - Date" under each message
$ShowBDescrip = 1;                                                    # Set to 1 to display board descriptions on the topic (message) index for each board
$showuserpic = 1;                                                     # Set to 1 to display each member's picture in the message view (by the ICQ.. etc.)
$showusertext = 1;                                                    # Set to 1 to display each member's personal text in the message view (by the ICQ.. etc.)
$showtopicviewers = 1;                                                # Set to 1 to display members viewing a topic
$showtopicrepliers = 1;                                               # Set to 1 to display members replying to a topic
$showgenderimage = 1;                                                 # Set to 1 to display each member's gender in the message view (by the ICQ.. etc.)
$showyabbcbutt = 1;                                                   # Set to 1 to display the yabbc buttons on Posting and IM Send Pages
$nestedquotes = 1  ;                                                  # Set to 1 to allow quotes within quotes (0 will filter out quotes within a quoted message)
$parseflash = 1;                                                      # Set to 1 to parse the flash tag
$enableclicklog = 0;                                                  # Set to 1 to track stats in Clicklog (this may slow your board down)


########## Feature Settings ##########

$enable_ubbc = 1;                                                     # Set to 1 if you want to enable UBBC (Uniform Bulletin Board Code)
$enable_news = 0;                                                     # Set to 1 to turn news on, or 0 to set news off
$allowpics = 1;                                                       # set to 1 to allow members to choose avatars in their profile
$enable_guestposting = 1;                                             # Set to 0 if do not allow 1 is allow.
$enable_notification = 1;                                             # Allow e-mail notification
$autolinkurls = 1;                                                    # Set to 1 to turn URLs into links, or 0 for no auto-linking.

$timeselected = 3;                                                    # Select your preferred output Format of Time and Date
$timecorrection = 0;                                                  # Set time correction for server time in seconds
$timeoffset = 2;                                                      # Time Offset to GMT/UTC (0 for GMT/UTC)
$dstoffset = 1;                                                       # Time Offset (for daylight savings time, 0 to disable DST)
$TopAmmount = 15;                                                     # No. of top posters to display on the top members list
$maxdisplay = 20;                                                     # Maximum of topics to display
$maxfavs = 20;                                                        # Maximum of favorite topics to save in a profile
$maxrecentdisplay = 30;                                               # Maximum of topics to display on recent posts by a user (-1 to disable)
$maxsearchdisplay = 50;                                               # Maximum of messages to display in a search query  (-1 to disable search)
$maxmessagedisplay = 15;                                              # Maximum of messages to display
$MaxMessLen = 64000;                                                  # Maximum Allowed Characters in a Posts
$fontsizemin = 6;                                                     # Minimum Allowed Font height in pixels
$fontsizemax = 32;                                                    # Maximum Allowed Font height in pixels
$MaxSigLen = 400;                                                     # Maximum Allowed Characters in Signatures
$ClickLogTime = 100;                                                  # Time in minutes to log every click to your forum (longer time means larger log file size)
$max_log_days_old = 30;                                               # If an entry in the user's log is older than ... days remove it
                                                                      # Set to 0 if you want it disabled

$maxsteps = 30;                                                       # Number of steps to take to change from start color to endcolor
$stepdelay = 40;                                                      # Time in miliseconds of a single step
$fadelinks = 0;                                                       # Fade links as well as text?


$color{'fadertext'}  = "#000000";                                     # Color of text in the NewsFader (news color)
$color{'faderbg'}  = "#ffffff";                                       # Color of background in the NewsFader (news color)
$defaultusertxt = qq~~;                                               # The dafault usertext visible in users posts
$timeout = 5;                                                         # Minimum time between 2 postings from the same IP
$HotTopic = 10;                                                       # Number of posts needed in a topic for it to be classed as "Hot"
$VeryHotTopic = 25;                                                   # Number of posts needed in a topic for it to be classed as "Very Hot"

$barmaxdepend = 0;                                                    # Set to 1 to let bar-max-length depend on top poster or 0 to depend on a number of your choise
$barmaxnumb = 5000;                                                   # Select number of post for max. bar-length in memberlist
$defaultml = regdate;                                                 ########## MemberPic Settings ##########

$userpic_width = 65;                                                  # Set pixel size to which the selfselected userpics are resized, 0 disables this limit
$userpic_height = 65;                                                 # Set pixel size to which the selfselected userpics are resized, 0 disables this limit


########## File Locking ##########

$gzcomp = 0;                                                          # GZip compression: 0 = No Compression, 1 = External gzip, 2 = Zlib::Compress
$gzforce = 0;                                                         # Don't try to check whether browser supports GZip
$cachebehaviour = 1;                                                  # Browser Cache Control: 0 = No Cache must revalidate, 1 = Allow Caching
$use_flock = 1;                                                       # Set to 0 if your server doesn't support file locking,
                                                                      # 1 for Unix/Linux and WinNT, and 2 for Windows 95/98/ME

$faketruncation = 0;                                                  # Enable this option only if YaBB fails with the error:
                                                                      # "truncate() function not supported on this platform."
                                                                      # 0 to disable, 1 to enable.

$debug = 0;                                                           # If set to 1 debug info is added to the template
                                                                      # tags are <yabb fileactions> and <yabb filenames>
1;
