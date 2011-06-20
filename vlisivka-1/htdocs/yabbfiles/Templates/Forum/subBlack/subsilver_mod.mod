<edit file>
Sources/Subs.pl
</edit file>

<search for>
	$yyuname = $iamguest ? qq~$maintxt{'248'} $maintxt{'28'}. $maintxt{'249'} <a href="$scripturl?action=login">$maintxt{'34'}</a> $maintxt{'377'} <a href="$scripturl?action=register">$maintxt{'97'}</a>.~ : qq~$maintxt{'247'} $realname, ~ ;
</search for>

<add after>
## Begin Reformat Username for use with phpBB-type templates
	$yyuname2 = $iamguest ? qq~$maintxt{'248'} $maintxt{'28'}. $maintxt{'249'} <a href="$scripturl?action=login">$maintxt{'34'}</a> $maintxt{'377'} <a href="$scripturl?action=register">$maintxt{'97'}</a>.~ : qq~$realname~ ;
## End reformat of username for use with phpBB-type templates
</add after>

<search for>
	$yymenu = qq~<a href="$scripturl">$img{'home'}</a>$menusep<a href="$scripturl?action=help" style="cursor:help;">$img{'help'}</a>~;
	if ($maxsearchdisplay >= 0){
		$yymenu .= qq~$menusep<a href="$scripturl?action=search">$img{'search'}</a>~;
	}
	if(!$iamguest){
		$yymenu .=qq~$menusep<a href="$scripturl?action=ml">$img{'memberlist'}</a>~;
		if (${$uid.$username}{'favorites'} ne ""){
			$yymenu .=qq~$menusep<a href="$scripturl?action=favorites">$img{'favorites'}</a>~;
		}
	}

	if($iamadmin) { $yymenu .= qq~$menusep<a href="$boardurl/AdminIndex.$yyaext">$img{'admin'}</a>~; }
	if($iamgmod) {
		if(-e ("$vardir/gmodsettings.txt")) {
			require "$vardir/gmodsettings.txt";
		}
	if($allow_gmod_admin) { $yymenu .= qq~$menusep<a href="$boardurl/AdminIndex.$yyaext">$img{'admin'}</a>~; }
	}
	if($sessionvalid == 0 && !$iamguest) { $yymenu .= qq~$menusep<a href="$scripturl?action=revalidatesession">$img{'sessreval'}</a>~; }
	if($iamguest) { $yymenu .= qq~$menusep<a href="$scripturl?action=login">$img{'login'}</a>$menusep<a href="$scripturl?action=register">$img{'register'}</a>~;
	} else {
		$yymenu .= qq~$menusep<a href="$scripturl?action=viewprofile;username=$username">$img{'profile'}</a>~;
		if($enable_notification) { $yymenu .= qq~$menusep<a href="$scripturl?action=shownotify">$img{'notification'}</a>~; }
		$yymenu .= qq~$menusep<a href="$scripturl?action=logout">$img{'logout'}</a>~;
	}
</search for>

<add after>
## Begin Second YaBB Menu added for phpBB-type templates
	$yymenu2 = qq~<a href="$scripturl?action=help" style="cursor:help;">$img{'help'}</a>~;
	if ($maxsearchdisplay >= 0){
		$yymenu2 .= qq~$menusep<a href="$scripturl?action=search">$img{'search'}</a>~;
	}
	if(!$iamguest){
		$yymenu2 .=qq~$menusep<a href="$scripturl?action=ml">$img{'memberlist'}</a><br />~;
		if (${$uid.$username}{'favorites'} ne ""){
			$yymenu2 .=qq~$menusep<a href="$scripturl?action=favorites">$img{'favorites'}</a>~;
		}
	}

	if($iamadmin) { $yymenu2 .= qq~$menusep<a href="$boardurl/AdminIndex.$yyaext">$img{'admin'}</a>~; }
	if($iamgmod) {
		if(-e ("$vardir/gmodsettings.txt")) {
			require "$vardir/gmodsettings.txt";
		}
	if($allow_gmod_admin) { $yymenu2 .= qq~$menusep<a href="$boardurl/AdminIndex.$yyaext">$img{'admin'}</a>~; }
	}
	if($sessionvalid == 0 && !$iamguest) { $yymenu2 .= qq~$menusep<a href="$scripturl?action=revalidatesession">$img{'sessreval'}</a>~; }
	if($iamguest) { $yymenu2 .= qq~$menusep<a href="$scripturl?action=login">$img{'login'}</a>$menusep<a href="$scripturl?action=register">$img{'register'}</a>~;
	} else {
		$yymenu2 .= qq~$menusep<a href="$scripturl?action=viewprofile;username=$username">$img{'profile'}</a>~;
		if($enable_notification) { $yymenu2 .= qq~$menusep<a href="$scripturl?action=shownotify">$img{'notification'}</a>~; }
		$yymenu2 .= qq~$menusep<a href="$scripturl?action=logout">$img{'logout'}</a>~;
	}
## End Second YaBB Menu added for phpBB-type templates
</add after>