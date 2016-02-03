#!/usr/bin/perl

use CGI;
use DBI;

$datasource='mysql';
$db1="spam";
$un1="root";
$pw1="";
$host1 = "localhost";

$cgi = new CGI;

$fixline = $cgi->param('fixline');

$chk_ip = $cgi->param('chk_ip');
$b_name = $cgi->param('b_name');
$h_name = $cgi->param('h_name');
$pop = $cgi->param('pop');
$chk_datetime = $cgi->param('chk_datetime');
$name = $cgi->param('name');
$custid = $cgi->param('custid');
$level = $cgi->param('level');

$username = $cgi->param('username');
$service = $cgi->param('service');
$logout = $cgi->param('logout');
$used = $cgi->param('used');

$account = $cgi->param('account');
$iptype = $cgi->param('iptype');

$spam_userid = $cgi->param('spam_userid');
$spam_userpwd = $cgi->param('spam_userpwd');

$stop_or_restart = $cgi->param('stop_or_restart');

$dbh1=DBI->connect("DBI:$datasource:$db1:$host1", "$un1", "$pw1") or die "Can'tConnectTercel!!\n";

$sql = "select * from users where username='$spam_userid' and password='$spam_userpwd'";
$sth = $dbh1->prepare($sql);
$sth->execute;
$findit=$sth->rows;
$row = $sth->fetchrow_hashref;

$sth->finish;
$dbh1->disconnect;

if (not $findit) {
	if ($stop_or_restart eq 'S') {
	print "Location: spam_detail_new.pl?fixline=$fixline&chk_ip=$chk_ip&b_name=$b_name&h_name=$h_name&pop=$pop&chk_datetime=$chk_datetime&name=$name&custid=$custid&level=$level&username=$username&service=$service&logout=$logout&used=$used\n\n";
	exit; 
	}
	if ($stop_or_restart eq 'R') {
	print "Location: spam_reset.pl?account=$account&iptype=$iptype\n\n";
	exit; 
	}
}else{
	$spam_userid = $row->{username};
	$id_cookies = $cgi->cookie(-name=>'spam_userid', -value=>$spam_userid);
	print "Set-cookie: $id_cookies","\n";

	if ($stop_or_restart eq 'S') {
	print "Location: spam_detail_new.pl?fixline=$fixline&chk_ip=$chk_ip&b_name=$b_name&h_name=$h_name&pop=$pop&chk_datetime=$chk_datetime&name=$name&custid=$custid&level=$level&username=$username&service=$service&logout=$logout&used=$used\n\n";
	}
	if ($stop_or_restart eq 'R') {
	print "Location: spam_reset.pl?account=$account&iptype=$iptype\n\n";
	exit; 
	}
}
