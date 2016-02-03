#!/usr/bin/perl

use CGI;
use DBI;

use Date::Calc qw(Add_Delta_Days);
use Date::Calc qw(Delta_Days);

$cgi = new CGI;

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

$spam_userid = $cgi->cookie('spam_userid');

$account = $cgi->param('account');
$iptype = $cgi->param('iptype');

if ($spam_userid eq '') {

print "
<html>
<head><title>spam administrator 登入</title></head>
<body background='bg.jpg'>
<br><br>
<h1><i><font color='FF0000'>spam administrator 登入</font></i></h1>
<font size='3'>具有停復權權限者必須輸入您的帳號密碼</font>
<table>
<form action='spam_login.pl' method='post'>
<tr>
<td>Username:</td><td><input type='text' name='spam_userid' size='10' value=''></td>
</tr>
<tr>
<td>Password:</td><td><input type='password' name='spam_userpwd' size='10' value=''></td>
</tr>
<tr>
<input type='hidden' name='account' value='$account'>
<input type='hidden' name='iptype' value='$iptype'>

<input type='hidden' name='stop_or_restart' value='R'>
<td colspan=2 align=center><input type='submit' value='GO'></td>
</tr>
</form>
</table>
</body>
</html>
";
exit;
#<< Set Cookie ###############################
#$cookie = $query->cookie(-name=>'userid',
#                           -value=>$userid,
#                           -path=>'/',
#                           -expires=>$expire);
#print $query->header(-Cookie=>$cookie);
################################ Set Cookie >>
}

if (TRUE) { ## HTML開關控制
	$content =~ s/</< /g;
	$content =~ s/>/ >/g;
}
$content =~ s/.\n/<br>/gs;

$dbh1=DBI->connect("DBI:$datasource:$db1:$host1", "$un1", "$pw1") or die "Can'tConnectTercel!!\n";
$dbh2=DBI->connect("DBI:$datasource:$dbname:$hostname:$port","$username","$passwd") || die print "can't connect database : TACACS";

if ($iptype eq '1') {
$sql_up="update userprofile set lcp='register' where name='$account'";
$sth=$dbh2->prepare($sql_up);
$sth->execute();
$sth->finish();
}else{
}

$sql_up="update spam set valid='N',admin='$spam_userid ',lastupdate=now() where account='$account'";
$sth=$dbh1->prepare($sql_up);
$sth->execute();
$row=$sth->fetchrow_hashref;
$sth->finish();

$HTML_STR=$sql_up;
$HTML_STR.="<br><font color=blue><b>$account 已完成復權動作...謝謝!</b><br></font>";

print "Content-type: text/html\n\n";
print '<html>
<title>停復權管理查詢系統報表</title>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<meta http-equiv="Content-Language" content="zh-tw">
</head>
<body bgcolor=#E6E6FA  background="bg.jpg">';
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

if ($dbh1) {$dbh1->disconnect();}
if ($dbh2) {$dbh2->disconnect();}
