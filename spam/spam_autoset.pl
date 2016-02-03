#!/usr/bin/perl

use CGI;
use DBI;

#use Date::Calc qw(Add_Delta_Days);
#use Date::Calc qw(Delta_Days);

#$cgi = new CGI;

$datasource='mysql';
$db1="spam";
$un1="root";
$pw1="";
$host1 = "localhost";

$dbname='tacacs';
$hostname='db1';
$port = '4949';
$username='ericchen';
$passwd='eric5901';

$Thedate = `date +%Y-%m-%d`;
($yy,$mm,$dd)=split(/-/,$Thedate);
$Thedate=$yy.'-'.$mm.'-'.$dd;
chop($Thedate);

$dbh1=DBI->connect("DBI:$datasource:$db1:$host1", "$un1", "$pw1") or die "Can'tConnectTercel!!\n";
$dbh2=DBI->connect("DBI:$datasource:$dbname:$hostname:$port","$username","$passwd") || die print "can't connect database : TACACS";

$sql = "select account,iptype,settime,duetime,level,valid,admin,lastupdate from spam where valid='Y' and left(duetime,10)<='$Thedate'";
$sth=$dbh1->prepare($sql);
$sth->execute();

while ($row = $sth->fetchrow_hashref) {
$sql_up="update spam set valid='N',lastupdate=now() where account='$row->{account}'";
$sth_up=$dbh1->prepare($sql_up);
$sth_up->execute();
$sth_up->finish();
if ($row->{iptype} eq '1') {
	$sql_tac="update userprofile set lcp='register' where name='$row->{account}'";
	$sth_tac=$dbh2->prepare($sql_tac);
	$sth_tac->execute();
	$sth_tac->finish();
}else{
}

$HTML_STR="$sql_up\n";
$HTML_STR.="$sql_tac\n";
$HTML_STR.="$row->{account},$row->{iptype},$row->{settime},$row->{duetime},$row->{level},$row->{valid} 已完成復權動作!\n";
print $HTML_STR;

if ($iptype eq '2') {
open(MAIL, "|/usr/lib/sendmail -oi -t") or die "Can't fork for sendmail: $!\n";
print MAIL <<"EOF";
Content-Type: text/html;charset=big-5
Content-Transfer-Encoding: 8bit
From: jimi\@apol.com.tw
To: jimi\@apol.com.tw
Subject: $fyy年$fmm月$fdd日 停復權管理查詢系統

EOF

print MAIL <<"__HTML__";
<html>
<title>停復權管理查詢系統報表</title>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<meta http-equiv="Content-Language" content="zh-tw">
</head>
<body bgcolor=#E6E6FA  background="bg.jpg">
$HTML_STR
__HTML__
close(MAIL);
}else{
}

}

$sth->finish();

if ($dbh1) {$dbh1->disconnect();}
if ($dbh2) {$dbh2->disconnect();}
