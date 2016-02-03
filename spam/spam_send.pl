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
$host2 = "149.49.49.194";

$the_dialupdb="dialup";

$user2="spam";
$pwd2="spamtool";


$dbname='tacacs';
$hostname='db1';
$port = '4949';
$theusername='ericchen';
$passwd='eric5901';

$spam_userid = $cgi->cookie('spam_userid');

$fixline = $cgi->param('fixline');

$chk_ip = $cgi->param('chk_ip');
$b_name = $cgi->param('b_name');
$h_name = $cgi->param('h_name');
$pop = $cgi->param('pop');
$chk_datetime = $cgi->param('chk_datetime');
$name = $cgi->param('name');
$custid = $cgi->param('custid');

$username = $cgi->param('username');
$service = $cgi->param('service');
$logout = $cgi->param('logout');
$used = $cgi->param('used');

$reason = $cgi->param('reason');
$iptype = $cgi->param('iptype');
$title = $cgi->param('title');
$content = $cgi->param('content');

$level = $cgi->param('level');

#print "Content-type: text/html\n\n";

$the_from_date = $cgi->param('the_from_date');
$the_to_date = $cgi->param('the_to_date');

$username = $cgi->param('username');

if ($userid eq '') {

}


$content =~ s/\'//g;
$content =~ s/\"//g;


if (TRUE) { ## HTML開關控制
	$content =~ s/</< /g;
	$content =~ s/>/ >/g;
}
$content =~ s/.\n/<br>/gs;

#<< Set Cookie ###############################
#$cookie = $query->cookie(-name=>'userid',
#                           -value=>$userid,
#                           -path=>'/',
#                           -expires=>$expire);
#print $query->header(-Cookie=>$cookie);
################################ Set Cookie >>

$date = `date +%Y/%m/%d`;
$time = `date +%H:%M:%S`;
chop($date);
chop($time);

($fyy,$fmm,$fdd)=split('/',$date);

$fmm = padstr_left($fmm,'0',2);
$fdd = padstr_left($fdd,'0',2);

$dbh1=DBI->connect("DBI:$datasource:$db1:$host1", "$un1", "$pw1") or die "Can'tConnectTercel!!\n";
$dbh2=DBI->connect("DBI:$datasource:$dbname:$hostname:$port","$theusername","$passwd") || die print "can't connect database : TACACS";
$dbh3=DBI->connect("DBI:$datasource:$the_dialupdb:$host1", "$un1", "$pw1") or die "Can'tConnectTercel!!\n";
$dbh4=DBI->connect("DBI:$datasource:$the_dialupdb:$host2", "$user2", "$pwd2") or die "Can'tConnectTercel!!\n";


$account='';

if ($fixline eq 'Y') {
$ip_desc="$pop-$b_name-$h_name";
$account=$custid;
}else{
$ip_desc="APOL撥接用戶-$service-$logout-$used";
$account=$username;
}

if ($level==1) {
	$sql_up="insert into spam values('','$account','$chk_ip','$iptype','$ip_desc','$reason','$title','$content','$the_from_date','$the_to_date',$level,'Y','$spam_userid',now())";

`echo "$sql_up" >> /tmp/spamlog.txt`;
}else{	
	$sql_up="update spam set ip='$chk_ip',iptype='$iptype',custdesc='$ip_desc',reason='$reason',title='$title',content='$content',settime='$the_from_date',duetime='$the_to_date',level=$level,admin='',valid='Y',admin='$spam_userid',lastupdate=now() where account='$account'";
`echo "$sql_up" >> /tmp/spamlog.txt`;
}

#print "Content-type: text/html\n\n";
#print "[$fixline][$level][$sql_up]";
#exit;


$sth=$dbh1->prepare($sql_up);
$sth->execute();
$sth->finish();

if ($fixline eq 'Y') {
}else{
$sql_up="update userprofile set lcp='spam' where name='$account'";
$sth=$dbh2->prepare($sql_up);
$sth->execute();
$sth->finish();

$sql_se="select cust_id from customer where username='$account'";
$sth=$dbh4->prepare($sql_se);
$sth->execute();
$row_up=$sth->fetchrow_hashref;
$the_cust_id=$row_up->{cust_id};

$sql_up="insert into eventlog values($the_cust_id,19,now(),'預計恢復使用權日期($the_to_date)')";
`echo "$sql_up" >> /tmp/spamlog.txt`;
$sth=$dbh4->prepare($sql_up);
$sth->execute();
$sth->finish();
}

if ($reason==1) {$show_reason='SPAM';}
elsif ($reason==2) {$show_reason='Virus';}
elsif ($reason==3) {$show_reason='open-relay';}
else{$show_reason='Other';}
if ($iptype==1) {$show_iptype='動態IP';}
else{$show_iptype='固定IP';}

$HTML_STR='';
$HTML_STR.='

<table border="0" cellspacing="8" cellpadding="0" width="600">
  <tr align="center"> 
    <td width="450"> 
      <table border="1" width="420" align="center" cellspacing="0" bgcolor="#E1F0FF" bordercolor="#002244" cellpadding="2">
        <tr align="center"> 
          <td width="420"> 
            <table border="0" width="420" align="center" cellpadding="5" bgcolor="#E1F0FF" bordercolor="#CCCCCC" cellspacing="3">

              <tr> 
                <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1">帳號：'.$custid.'</font></td>
                <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1">IP：'.$chk_ip.'</font></td>
                <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">　</font></td>
              </tr>
              <tr> 
                <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1">停權時間：'.$the_from_date.'</font></td>
                <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1">預計復權時間：'.$the_to_date.'</font></td>
                <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">　</font></td>
              </tr>
              <tr> 
                <td align="left" width="100%" colspan=3><hr size=-1 width="95%"></td>
              </tr>

              <tr> 
                <td align="left" width="100%" colspan=3><font size="2">標題：'.$title.'</font></td>
              </tr>

              <tr> 
                <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1">停權原因</font></td>
                <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1">IP  種類</font></td>
                <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">　</font></td>
              </tr>

              <tr> 
                <td valign="middle" width="150"> <font size="-1">'.$show_reason.'</font></td>
                <td valign="middle" width="180"> <font size="-1">'.$show_iptype.'</font></td>
                <td valign="middle" width="90"> <font size="-1">　
              </tr>

              <tr> 
                <td valign="middle" width="150"> <font size="-1">　
                  </font></td>
                <td valign="middle" width="180"> <font size="-1">　
                  </font></td>
                <td valign="middle" width="90"> <font size="-1"> 
                  </font></td>
              </tr>

              <tr> 
                <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1">檢舉信件內容
                  </font></td>
                <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1">　</font></td>
                <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">　</font></td>
              </tr>

              <tr> 
                <td align="left" width="100%" colspan=3><textarea cols=40 rows=6 name="content">'.$content.'</textarea></td>
              </tr>

              <tr> 
                <td align="left" width="100%" colspan=3><a href="spam_main.pl">回首頁</a></td>
              </tr>

           </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
';

$HTML_STR.="</table><br><br>";
print "Content-type: text/html\n\n";
print '<html>
<title>停復權管理查詢系統報表</title>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<meta http-equiv="Content-Language" content="zh-tw">
</head>
<body bgcolor=#E6E6FA  background="bg.jpg">';
print "<br><font color=blue><b>已完成停權或通知相關部門之動作...謝謝!</b><br></font>";
print $HTML_STR;

if ($fixline eq 'Y') {
open(MAIL, "|/usr/lib/sendmail -oi -t") or die "Can't fork for sendmail: $!\n";
print MAIL <<"EOF";
Content-Type: text/html;charset=big-5
Content-Transfer-Encoding: 8bit
From: jimi\@apol.com.tw
To: kiki\@apol.com.tw, heidihsu\@apol.com.tw, quasar\@apol.com.tw, jimi\@apol.com.tw
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

sub round{ #--$num:source number, $scale: 4捨5入位數,任意整數,代表4捨5入到10的n次方, 小數部分自動補0
my $num = $_[0]; 
my $scale = $_[1];
$num = int($num * 10**(0-$scale) + 0.5)*10**($scale);
if ($scale < 0) { 
my ($int, $decimal) = ($num =~ /\./)?split(/\./, $num):($num, '');
$num = $int.'.'.substr($decimal.'00', 0, 2);
}
return $num;
}

sub padstr_right
  { while ( length($_[0]) < $_[2] ) { $_[0].=$_[1] };
    return $_[0];
  }

sub padstr_left
  { while ( length($_[0]) < $_[2] ) { $_[0]=$_[1].$_[0] };
    return $_[0];
  }

sub chyy
  { if (length($_[0])==2)
     { $_[0] = ($_[0]=='99' ? '19'.$_[0] : '20'.$_[0]) }
    return $_[0];
  }

if ($dbh1) {$dbh1->disconnect();}
if ($dbh2) {$dbh2->disconnect();}
if ($dbh3) {$dbh2->disconnect();}
