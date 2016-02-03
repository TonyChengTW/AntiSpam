#!/usr/bin/perl

require "service.pl";
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

$spam_userid = $cgi->cookie('spam_userid');

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

$fix_show_check='';
$du_show_check='';
if ($fixline eq 'Y') {
$account=$custid;
$fix_show_check='checked';
}else{
$account=$username;
$du_show_check='checked';
}

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
<input type='hidden' name='fixline' value='$fixline'>
<input type='hidden' name='chk_ip' value='$chk_ip'>
<input type='hidden' name='b_name' value='$b_name'>
<input type='hidden' name='h_name' value='$h_name'>
<input type='hidden' name='pop' value='$pop'>
<input type='hidden' name='chk_datetime' value='$chk_datetime'>
<input type='hidden' name='name' value='$name'>
<input type='hidden' name='custid' value='$custid'>
<input type='hidden' name='level' value='$level'>
<input type='hidden' name='username' value='$username'>
<input type='hidden' name='service' value='$service'>
<input type='hidden' name='logout' value='$logout'>
<input type='hidden' name='used' value='$used'>

<input type='hidden' name='stop_or_restart' value='S'>
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

$duedate=0;
if ($level==0) {
$duedate=14;
}elsif($level==1){
$duedate=90;
}else{
$duedate=180;
}
$level++;

if ($fixline eq 'Y') {$fixmemo = '固定IP,請通知相關部門';}else{$fixmemo = '撥接用戶,可直接停權';}

$date = `date +%Y/%m/%d`;
$time = `date +%H:%M:%S`;
chop($date);
chop($time);

($fyy,$fmm,$fdd)=split('/',$date);
($tyy,$tmm,$tdd)=Add_Delta_Days($fyy,$fmm,$fdd,$duedate);

$fmm = padstr_left($fmm,'0',2);
$fdd = padstr_left($fdd,'0',2);
$tmm = padstr_left($tmm,'0',2);
$tdd = padstr_left($tdd,'0',2);

$the_from_date="$fyy-$fmm-$fdd";
$the_to_date="$tyy-$tmm-$tdd";

print "Content-type: text/html\n\n";
print '<html>'.$n;
print '<head>'.$n;
print '<title>停復權管理查詢系統</title>'.$n;
print '</head>'.$n;

print '<body bgcolor="#FFFFFF" background="bg.jpg">'.$n;
print '  <table border="0" cellspacing="8" cellpadding="0" width="600">'.$n;
print '    <tr align="center"> '.$n;
print '      <td width="450"> '.$n;
print '        <table border="1" width="440" align="center" cellspacing="0" bgcolor="#E1F0FF" bordercolor="#002244" cellpadding="2">'.$n;
print '          <tr align="center"> '.$n;
print '            <td width="420"> '.$n;
print '              <table border="0" width="440" align="center" cellpadding="5" bgcolor="#E1F0FF" bordercolor="#CCCCCC" cellspacing="3">'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1" color=blue><b>帳號：'.$account.'</b></font></td>'.$n;
print '                  <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1" color=blue><b>IP：'.$chk_ip.'</b></font></td>'.$n;
print '                  <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">　</font></td>'.$n;
print '                </tr>'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1" color=blue><b>停權時間：'.$fyy.'/'.$fmm.'/'.$fdd.'</b></font></td>'.$n;
print '                  <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1" color=blue><b>預計復權時間：'.$tyy.'/'.$tmm.'/'.$tdd.'</b></font></td>'.$n;
print '                  <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">　</font></td>'.$n;
print '                </tr>'.$n;
print '<form name="form1" method="post" action="spam_send.pl" onSubmit="return Check(form1)">'.$n;
print '<input type="hidden" name="custid" value="'.$custid.'">'.$n;
print '<input type="hidden" name="chk_ip" value="'.$chk_ip.'">'.$n;
print '<input type="hidden" name="fixline" value="'.$fixline.'">'.$n;
print '<input type="hidden" name="b_name" value="'.$b_name.'">'.$n;
print '<input type="hidden" name="h_name" value="'.$h_name.'">'.$n;
print '<input type="hidden" name="pop" value="'.$pop.'">'.$n;
print '<input type="hidden" name="username" value="'.$username.'">'.$n;
print '<input type="hidden" name="service" value="'.$service.'">'.$n;
print '<input type="hidden" name="logout" value="'.$logout.'">'.$n;
print '<input type="hidden" name="used" value="'.$used.'">'.$n;
print '<input type="hidden" name="chk_datetime" value="'.$chk_datetime.'">'.$n;
print '<input type="hidden" name="the_from_date" value="'.$the_from_date.'">'.$n;
print '<input type="hidden" name="the_to_date" value="'.$the_to_date.'">'.$n;
print '<input type="hidden" name="level" value="'.$level.'">'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><hr size=-1 width="95%"></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><font size=2 color=red>此客戶將被第 '.$level.' 次停權</font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><font size="2">標題：<input type="text" name="title" maxlength="40" size="30" value=""></font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1">停權原因</font></td>'.$n;
print '                  <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1">IP  種類</font></td>'.$n;
print '                  <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">　</font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1"> '.$n;
print '                    <input type="radio" name="reason" value=1 checked>spam'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="180"> <font size="-1">'.$n;
print '                    <input type="radio" name="iptype" value=1 '.$du_show_check.'>動態'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1">　'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1"> '.$n;
print '                    <input type="radio" name="reason" value=2>virus'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="180"> <font size="-1">'.$n;
print '                    <input type="radio" name="iptype" value=2 '.$fix_show_check.'>固定'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1">　'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1"> '.$n;
print '                    <input type="radio" name="reason" value=3>open-relay'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="180"> <font size="-1">　'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1">　'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1">　'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="180"> <font size="-1">　'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
print '                    </font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1">檢舉信件內容'.$n;
print '                    </font></td>'.$n;
print '                  <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1">　</font></td>'.$n;
print '                  <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">　</font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><textarea cols=40 rows=6 name="content"></textarea></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1"> '.$n;
print '					<input type="button" name="B1" value=" 回上一頁 " onclick="javascript:history.go( -1 );"> '.$n;
if ($fixline eq 'Y') {
print '						<input type="submit" name="Submit" value=" 送出 ">'.$n;
}else{
print '						<input type="Submit" name="Submit" value=" 確定 ">'.$n;
}
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="180"> <font size="-1">　'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1">　'.$n;
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '</form>'.$n;

print '              </table>'.$n;
print '            </td>'.$n;
print '          </tr>'.$n;
print '        </table>'.$n;
print '      </td>'.$n;
print '    </tr>'.$n;
print '  </table>'.$n;
print '  <br> '.$n;
print '<a href="javascript:history.go( -1 );">上一頁</a>'.$n;
print '  <center> '.$n;
print '  </center> '.$n;
print '</body>'.$n;
print '</html>'.$n;

if ($db1) {$db1->disconnect;}
