
$lastsaved = "YaBB Administrator";
$lastdate  = "1192104799";

my $rd  = "/var/www/vhosts/linux.org.ua";
my $drd = "/var/yabb-2.1";
my $srd = "/lib/yabb-2.1";
my $crd = "/cgi-bin/yabb";
my $hrd = "/htdocs/yabbfiles";
#my $hrd = "/htdocs/yabbfiles";

my $surl  = "http://linux.org.ua";
my $crurl = "/cgi-bin/yabb";
my $hrurl = "/yabbfiles";
#my $hrurl = "/yabbfiles";

$boardurl = "$surl$crurl";	# URL of your board's folder (without trailing '/')
$boarddir = "$rd$crd";	# The server path to the board's folder (usually can be left as '.')

$boardsdir = "$rd$drd/Boards";	# Directory with board data files
$datadir   = "$rd$drd/Messages";	# Directory with messages
$memberdir = "$rd$drd/Members";	# Directory with member files
$vardir    = "$rd$drd/Variables";	# Directory with variable files

$modulesdir   = "$rd$srd/Modules";      # Directory with third-party modules, used by YaBB
$sourcedir    = "$rd$srd/Sources";	# Directory with YaBB source files
$admindir     = "$rd$srd/Admin";	# Directory with YaBB admin source files
$langdir      = "$rd$srd/Languages";	# Directory with Language files and folders
$helpfile     = "$rd$srd/Help";	# Directory with Help files and folders
$templatesdir = "$rd$srd/Templates";	# Directory with template files and folders

$forumstylesdir = "$rd$hrd/Templates/Forum";	# Directory with forum style files and folders
$adminstylesdir = "$rd$hrd/Templates/Admin";	# Directory with admin style files and folders
$htmldir        = "$rd$hrd";	# Base Path for all html/css files and folders
$facesdir       = "$rd$hrd/Avatars";	# Base Path for all avatar files
$smiliesdir     = "$rd$hrd/Smilies";	# Base Path for all smilie files
$modimgdir      = "$rd$hrd/ModImages";	# Base Path for all mod images
$uploaddir      = "$rd$hrd/Attachments";	# Base Path for all attachment files

$forumstylesurl = "$surl$hrurl/Templates/Forum";	# Default Forum Style Directory
$adminstylesurl = "$surl$hrurl/Templates/Admin";	# Default Admin Style Directory
$ubbcjspath     = "$surl$hrurl/ubbc.js";	# Default Location for the ubbc.js file
$faderpath      = "$surl$hrurl/fader.js";	# Default Location for the fader.js file
$yabbcjspath    = "$surl$hrurl/yabbc.js";	# Default Location for the yabbc.js file
$postjspath     = "$surl$hrurl/post.js";	# Default Location for the post.js file
$html_root      = "$surl$hrurl";	# Base URL for all html/css files and folders
$facesurl       = "$surl$hrurl/Avatars";	# Base URL for all avatar files
$smiliesurl     = "$surl$hrurl/Smilies";	# Base URL for all smilie files
$modimgurl      = "$surl$hrurl/ModImages";	# Base URL for all mod images
$uploadurl      = "$surl$hrurl/Attachments";	# Base URL for all attachment files

our $membertrashdir = "$rd$drd/Trash";
our $uploadtrashdir = "$rd$drd/Trash";
our $datatrashdir = "$rd$drd/Trash";

1;

