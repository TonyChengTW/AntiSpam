#!/usr/bin/perl

require "service.pl";
use CGI;
use DBI;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval );
use Date::Calc qw(Today Add_Delta_Days Date_to_Days Day_of_Week);
use Date::Calc qw(Delta_Days);

$cgi = new CGI;

$datasource='mysql';
$db1="spam";
$un1="root";
$pw1="";
$host1 = "localhost";

$thestatus = $cgi->param('thestatus');
$iptype = $cgi->param('iptype');

if ($userid eq '') {

}

#<< Set Cookie ###############################
#$cookie = $query->cookie(-name=>'userid',
#                           -value=>$userid,
#                           -path=>'/',
#                           -expires=>$expire);
#print $query->header(-Cookie=>$cookie);
################################ Set Cookie >>

$cp_date = `date '+%Y-%m-%d'`;
($cp_yy,$cp_mm,$cp_dd)=split(/-/,$cp_date);
($cp_y1, $cp_m1, $cp_d1) = Add_Delta_Days($cp_yy, $cp_mm, $cp_dd, -3);
$cp_m1 = padstr_left($cp_m1,'0',2);
$cp_d1 = padstr_left($cp_d1,'0',2);

$to_day="$cp_yy-$cp_mm-$cp_dd";
$three_day="$cp_y1-$cp_m1-$cp_d1";

$sql = "select * from spam where account<>''";
if($thestatus==1){
$sql = $sql." and valid='Y'";
}elsif($thestatus==2){
$sql = $sql." and valid='N'";
}elsif($thestatus==3){
$sql = $sql." and valid='Y' and settime='$to_day'";
}elsif($thestatus==4){
$sql = $sql." and valid='N' and duetime='$to_day'";
}elsif($thestatus==5){
$sql = $sql." and valid='Y' and left(settime,10)>='$three_day' and left(settime,10)<='$to_day'";
}elsif($thestatus==6){
$sql = $sql." and valid='N' and left(duetime,10)>='$three_day' and left(duetime,10)<='$to_day'";
}else{
}
if($iptype==1){
$sql.= " and iptype='1'";
}elsif($iptype==2){
$sql.= " and iptype='2'";
}else{
}

$dbh1=DBI->connect("DBI:$datasource:$db1:$host1", "$un1", "$pw1") or die "Can'tConnectTercel!!\n";

$sql_sel=$sql." order by lastupdate desc";
$sth=$dbh1->prepare($sql_sel);
$sth->execute();
$findit=$sth->rows;
if (not $findit) {
$show_the_desc.="<font color=brown> 查尋無資料</font>";
}else{
}

print "Content-type: text/html\n\n";
print '<html>'.$n;
print '<head>'.$n;
print '<title>停復權管理查詢系統</title>'.$n;
print '</head>'.$n;

print '<body bgcolor="#FFFFFF" background="bg.jpg">'.$n;
print '<a href="javascript:history.go( -1 );">上一頁</a><br>'.$n;

print '  <table border="0" cellspacing="8" cellpadding="0">'.$n;
print '<form name="form1" method="post" action="spam_showlist.pl" onSubmit="return Check(form1)">'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1">查詢狀態列表：'.$n;
print '                    </font></td>'.$n;
print '                  <td width="360" align="left" bgcolor="#E1F0FF"><font size="-1">撥/固接：</font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1">　</font></td>'.$n;
print '                </tr>'.$n;
print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1"> '.$n;
print '                    <select name="thestatus" size=1><option value=0>顯示全部　</option><option value=1>停權中的　</option><option value=2>未停權的　</option><option value=3>今天被停權的　</option><option value=4>今天該複權的　</option><option value=5>最近3天內停權的　</option><option value=6>最近3天該複權的　</option></font></td>	'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="360"> <font size="-1"> '.$n;
print '                    <select name="iptype" size=1><option value=0>全部　</option><option value=1>撥接　</option><option value=2>固接　</option></font></td>	'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
print '						<input type="submit" name="Submit" value=" 列表 ">'.$n;
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '</form>'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><font size=-1>　</font></td>'.$n;
print '                </tr>'.$n;

print '              </table>'.$n;

print '  <table border="1" cellspacing="1" cellpadding="3">'.$n;
print '    <tr align="center"> '.$n;
print "    
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>帳戶(客編)</b></font></td>
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>客戶名稱</b></font></td>
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>POP</b></font></td>
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>服務</b></font></td>
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>機房</b></font></td>
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>IP</b></font></td>
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>IP種類</b></font></td>
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>停權原因</b></font></td>
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>停權者</b></font></td>
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>狀態</b></font></td>
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>停權日</b></font></td>
			<td bgcolor='#E1F0FF'><font size=-1 color='blue'><b>複權日</b></font></td></tr>";
while($row_acc=$sth->fetchrow_hashref){
$sql_cus="select * from ipassign where cust_id='$row_acc->{account}'";
$sth_cus=$dbh1->prepare($sql_cus);
$sth_cus->execute();
$row_cus=$sth_cus->fetchrow_hashref;

if ($row_acc->{iptype} eq '1') {$show_iptype='動態';}else{$show_iptype='固定';}
if ($row_acc->{reason} eq '1') {$show_reason='SPAM';}elsif($row_acc->{reason} eq '2'){$show_reason='Virus';}else{$show_reason='Open-Relay';}
if ($row_acc->{valid} eq 'Y') {$show_valid='<font color=red>停權中</font>';}else{$show_valid='<font color=green>未停權</font>';}
print "<tr>
		<td bgcolor='#E1F0FF'><a href=\"javascript:goshow('$row_acc->{account}');\"><font size=-1>$row_acc->{account}</font></a></td>
		<td bgcolor='#E1F0FF'><font size=-1>$row_cus->{c_chinese_name}</font></td>
		<td bgcolor='#E1F0FF'><font size=-1>$row_cus->{pop}</font></td>
		<td bgcolor='#E1F0FF'><font size=-1>$row_cus->{b_name}</font></td>
		<td bgcolor='#E1F0FF'><font size=-1>$row_cus->{h_name}</font></td>
		<td bgcolor='#E1F0FF'><font size=-1>$row_acc->{ip}</font></td>
		<td bgcolor='#E1F0FF'><font size=-1>$show_iptype</font></td>
		<td bgcolor='#E1F0FF'><font size=-1>$show_reason</font></td>
		<td bgcolor='#E1F0FF'><font size=-1 color='blue'>$row_acc->{admin}</font></td>
		<td bgcolor='#E1F0FF'><font size=-1>$show_valid</font></td>
		<td bgcolor='#E1F0FF'><font size=-1>$row_acc->{settime}</font></td>
		<td bgcolor='#E1F0FF'><font size=-1>$row_acc->{duetime}</font></td>
		</tr>";
}
print '    </tr>'.$n;
print '  </table>'.$n;
print '<script>function goshow(x){document.all["account"].value=x;document.form2.submit();}</script>';
print '<form name="form2" method="post" action="http://203.79.224.104/cgi-bin/spam/spam_showcust.pl"><input type="hidden" id="account" name="account" value=""></form>';
print '  <br> '.$n;
print '</body>'.$n;
print '</html>'.$n;
$sth->finish();
if ($db1) {$db1->disconnect;}

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
