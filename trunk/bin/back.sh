#! /bin/bash --

# XXX:
# * --mode 640/660 --group apache owner? ?
# * set maintenance message?
# * what, if maintenance alredy set?
# * cp -l saves space, but requires permanent and runtime backups to be on one device
# * [TODO TEST KILL TODO]

shopt -s extglob

backdir='/var/www/vhosts/linux.org.ua/backups'
permanentbackdir='/var/www/vhosts/linux.org.ua/backups/permanent'
vardir='var/yabb-2.1/Variables'
rootdir='/var/www/vhosts/linux.org.ua'

#* mkback target_name targets - creates current backup of targets with prefix target_name
#% Does full backup once in a month, when that happens,
#% it creates a permanent copy, if necessary,
#% and kills anything, older than 6 months in runtime dir.
mkback () {
	local name="${1:?}" ;  shift
	local year="$( date +%Y )" \
	      month="$( date +%m )"
	local snarname="$name-$year$month.snar" \
	      tarname="$name-$( date +%Y%m%d_%H%M%S ).tar.bz2"
	local permanent first
	
	# First backup in a month
	if ! [ -e "$backdir/$snarname" ] ; then
		first=1
		if [ "$month" == '01' -o "$month" == '07' ] ; then
			permanent=1
		fi
	fi

	# Do backup
	if ! (( QUIET )) ; then
		echo "Backing up $name"
	fi
	tar	--create \
		--bzip2 \
		--file="$backdir/$tarname" \
		--listed-incremental="$backdir/$snarname" \
		"${@}"
	
	# Create permanent backup twice in a year
	if [ -n "$permanent" ] ; then
		cp -l "$backdir/$tarname" "$permanentbackdir/$tarname"
	fi

	# Remove old runtime backups
	if [ -n "$first" ] ; then
		local m0="$year$month"
		local m1="$( date -d "$year-$month-01 -1 month"  +%Y%m )"
		local m2="$( date -d "$year-$month-01 -2 months" +%Y%m )"
		local m3="$( date -d "$year-$month-01 -3 months" +%Y%m )"
		local m4="$( date -d "$year-$month-01 -4 months" +%Y%m )"
		local m5="$( date -d "$year-$month-01 -5 months" +%Y%m )"
		local m6="$( date -d "$year-$month-01 -6 months" +%Y%m )"
		rm "$backdir/$name-"!($m0|$m1|$m2|$m3|$m4|$m5|$m6)??_??????.tar.bz2
		rm "$backdir/$name-"!($m0|$m1|$m2|$m3|$m4|$m5|$m6).snar
	fi
}

if [ "$1" == '-h' -o "$1" == '--help' ] ; then
	echo
	echo "Backs up yabb forum on LOU. Uses incremental tar archives to do that."
	echo "Also creates hardlinked copies for permanent storage twice in a year."
	echo "And deletes anything, older than six months in a runtime backups dir."
	echo
	echo "Options:"
	echo "  -q  Be quiet - do not print what it does"
	echo
	echo "Permanent backups dir: $permanentbackdir"
	echo "Runtime backups dir: $backdir"
	echo
	exit 1
fi

if [ "$1" == '-q' ] ; then
	QUIET=1
else
	QUIET=0
fi

pushd "$rootdir" > /dev/null

if [ -e "$backdir/Settings.pl.back" ] ; then
	echo "Error: Settings backup exists, aborting"
	exit 1
fi
cp -p "$vardir/Settings.pl" "$backdir/Settings.pl.back"

sed -i -e 's/^\(.*\$maintenance *= *\)[10]\(;.*\)$/\11\2/' "$vardir/Settings.pl"

# Note, that in backup there will be stopped forum. And that Settings.pl will be saved every time.
mkback yabb_engine         lib cgi-bin/yabb
mkback yabb_data_mesg      var/*/Messages
mkback yabb_data_other     var/*/{Variables,Boards,Members}
mkback yabb_pubdata_attach htdocs/yabbfiles/Attachments
mkback yabb_pubdata_other  htdocs/yabbfiles/{Avatars,Smilies,Buttons,Templates,ModImages,*.js}

#sed -i -e 's/^\(.*\$maintenance *= *\)[10]\(;.*\)$/\10\2/' "$vardir/Settings.pl"
mv -f "$backdir/Settings.pl.back" "$vardir/Settings.pl" # dangerous?
popd > /dev/null

# The End
