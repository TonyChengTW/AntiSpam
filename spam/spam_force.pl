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

$datasource='mysql';
$db2="dialup";
$un1="root";
$pw1="";
$host1 = "localhost";

$ip = $cgi->param('ip');
$Theyy = $cgi->param('Theyy');
$Themm = $cgi->param('Themm');
$Thedd = $cgi->param('Thedd');
$Thehr = $cgi->param('Thehr');
$Themi = $cgi->param('Themi');
$These = $cgi->param('These');

if ($userid eq '') {

}

#<< Set Cookie ###############################
#$cookie = $query->cookie(-name=>'userid',
#                           -value=>$userid,
#                           -path=>'/',
#                           -expires=>$expire);
#print $query->header(-Cookie=>$cookie);
################################ Set Cookie >>

=mark
$chk_ip = (defined $ip) ? $ip : '';
($CA,$CB,$CC,$CD)=split(/\./,$chk_ip);
$CA = (defined $CA) ? $CA : '';
$CB = (defined $CB) ? $CB : '';
$CC = (defined $CC) ? $CC : '';
$CD = (defined $CD) ? $CD : '';

$chk_class="$CA.$CB.$CC";

if (($CA eq '') or ($CB eq '') or ($CC eq '') or ($CD eq '')){
print "Content-type: text/html\n\n";
print "�п�J���㪺ip�Ϭq......����";
exit;
}
if (($CA>=255) or ($CB>=255) or ($CC>=255) or ($CD>=255)){
print "Content-type: text/html\n\n";
print "�п�J�X�z��ip�Ϭq......����";
exit;
}

$cp_date = `date '+%Y-%m-%d'`;
($cp_yy,$cp_mm,$cp_dd)=split(/-/,$cp_date);
($cp_y1, $cp_m1, $cp_d1) = Add_Delta_Days($cp_yy, $cp_mm, $cp_dd, -6);
$the_days=Delta_Days($cp_y1,$cp_m1,$cp_d1,$Theyy,$Themm,$Thedd);

$the_sqldb='log';
if ($the_days<0) {
}else{
$the_sqldb='log_trans';
}

$the_log_sql='';
$chk_datetime = "$Theyy-$Themm-$Thedd";
if ($Thehr eq '-') {
	$chk_datetime = $chk_datetime.'%';
    $the_log_sql=" and logout like '$chk_datetime'";
}else{
	if ($Themi eq '-') {
		$chk_datetime = $chk_datetime.' '.$Thehr.':00:00';
	}else{
		if ($These eq '-') {
			$chk_datetime = $chk_datetime.' '.$Thehr.':'.$Themi.':00';
		}else{
			$chk_datetime = $chk_datetime.' '.$Thehr.':'.$Themi.':'.$These;
		}
	}
	$the_log_sql=" and unix_timestamp('$chk_datetime')>=(unix_timestamp(logout)-used) and unix_timestamp('$chk_datetime')<=unix_timestamp(logout)";
}

$fixline='N';
=cut

$dbh1=DBI->connect("DBI:$datasource:$db1:$host1", "$un1", "$pw1") or die "Can'tConnectTercel!!\n";
$dbh2=DBI->connect("DBI:$datasource:$db2:$host1", "$un1", "$pw1") or die "Can'tConnectTercel!!\n";

=mark
$sql_chkip="select * from iptable where ipclass='$chk_class' and houseid<>'X' and busid<>'X'";
$sth=$dbh1->prepare($sql_chkip);
$sth->execute();
$findit=$sth->rows;
$row_ipclass=$sth->fetchrow_hashref;
$sth->finish();

$show_the_desc='';
if (not $findit) {
$fixline='N';
$sql_cus="select * from $the_sqldb where host='$chk_ip' $the_log_sql limit 1";
$sth=$dbh2->prepare($sql_cus);
$sth->execute();
$findit=$sth->rows;
if (not $findit) {
	$sql_cus="select * from log where host='$chk_ip' $the_log_sql limit 1";
	$sth=$dbh2->prepare($sql_cus);
	$sth->execute();
}
$row_cust=$sth->fetchrow_hashref;
$username = (defined $row_cust->{name}) ? $row_cust->{name} : '';
$service = (defined $row_cust->{service}) ? $row_cust->{service} : '';
$logout = (defined $row_cust->{logout}) ? $row_cust->{logout} : '';
$used = (defined $row_cust->{used}) ? $row_cust->{used} : '';
if (not $findit) {
$show_the_desc="����즹����IP�ݩ��������Ȥ�,�Ь��߬����u�{�H��!";
}else{
$show_the_desc="���Ȥ��k��: $service $logout $used!";
}
}else{
$fixline='Y';
$sql_cus="select * from ipassign where ipclass='$chk_class' and ipfrom<=$CD and ipto>=$CD";
$sth=$dbh1->prepare($sql_cus);
$sth->execute();
$findit=$sth->rows;
$row_cust=$sth->fetchrow_hashref;
$name = (defined $row_cust->{c_chinese_name}) ? $row_cust->{c_chinese_name} : '';
$custid = (defined $row_cust->{cust_id}) ? $row_cust->{cust_id} : '';
$b_name = (defined $row_cust->{b_name}) ? $row_cust->{b_name} : '';
$h_name = (defined $row_cust->{h_name}) ? $row_cust->{h_name} : '';
$pop = (defined $row_cust->{pop}) ? $row_cust->{pop} : '';
$sth->finish();
if (not $findit) {
$show_the_desc="����즹�T�wIP�ݩ��������Ȥ�,�Ь��߬����u�{�H��!";
}else{
$show_the_desc="���Ȥ��k��: $b_name $h_name $pop !";
}
}
=cut


$fixline='N';

$username = $cgi->param('username');

if ($fixline eq 'Y') {
	$sql_sel="select * from spam where account='$custid'";
}else{	
	$sql_sel="select * from spam where account='$username'";
}

$sth=$dbh1->prepare($sql_sel);
$sth->execute();
$findit=$sth->rows;
$row_acc=$sth->fetchrow_hashref;
$sth->finish();
$level = (defined $row_acc->{level}) ? $row_acc->{level} : 0;
$valid = (defined $row_acc->{valid}) ? $row_acc->{valid} : 'N';
if (not $findit) {
$show_the_desc.="<font color=brown> �������v�O��</font>";
}else{
$show_the_desc.="<font color=brown> �w�Q��$level �����v,�ثe���v��: $valid</font>";
}

if ($fixline eq 'Y') {$fixmemo = '�T�wIP,�гq����������';}else{$fixmemo = '�����Τ�,�i�������v';}

print "Content-type: text/html\n\n";
#print $sql_chkip."-".$sql_cus."-".$username."-".$service."-".$logout."\n";
print '<html>'.$n;
print '<head>'.$n;
print '<title>���_�v�޲z�d�ߨt��</title>'.$n;
print '</head>'.$n;

print '<body bgcolor="#FFFFFF" background="bg.jpg">'.$n;
print '  <table border="0" cellspacing="8" cellpadding="0" width="600">'.$n;
print '    <tr align="center"> '.$n;
print '      <td width="450"> '.$n;
print '        <table border="1" width="420" align="center" cellspacing="0" bgcolor="#E1F0FF" bordercolor="#002244" cellpadding="2">'.$n;
print '          <tr align="center"> '.$n;
print '            <td width="420"> '.$n;
print '              <table border="0" width="420" align="center" cellpadding="5" bgcolor="#E1F0FF" bordercolor="#CCCCCC" cellspacing="3">'.$n;

print '                <tr> '.$n;
print '                </tr>'.$n;
print '<form name="form1" method="post" action="spam_detail.pl" onSubmit="return Check(form1)">'.$n;
print 'IP:<input type="text" name="chk_ip" value="'.$chk_ip.'">'.$n;
print '<input type="hidden" name="fixline" value="'.$fixline.'">'.$n;
print '�d�߮ɬq:<input type="text" name="chk_datetime" value="2005-10-10 10:10:10">'.$n;
#print '<br>����:<input type="text" name="service" value="'.$service.'">'.$n;
print '<br>����:<select size=1 name=service><option value=adsl selected>adsl</option><option value=d>56k</option><option value=cm>cable</option></select>'.$n;

print '�n�X�ɶ�:<input type="text" name="logout" value="2005-10-10 10:10:10">'.$n;
print '<br>�W�u�ϥήɶ�:<input type="text" name="used" value="100">'.$n;
print '<input type="hidden" name="level" value="'.$level.'">'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><hr size=-1 width="95%"></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><font size="2" color="red">- '.$fixmemo.' -</font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><font size=2 color=blue>- '.$show_the_desc.' -</font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1">�b���G '.$n;
print '                    </font></td>'.$n;
print '                  <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1">�@</font></td>'.$n;
print '                  <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">�@</font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1"> '.$n;
print '                    <input type="text" name="username" maxlength="40" size="15" value="'.$username.'">'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="180"> <font size="-1">�@'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
if ($fixline eq 'N') {
print '						<input type="submit" name="Submit" value=" ���� ">'.$n;
}else{
print '						<input type="button" name="B1" value=" �L�k�������v ">'.$n;
}
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '</form>'.$n;

print '<form name="form1" method="post" action="http://203.79.224.102/ht/customer.cgi" onSubmit="return Check(form1)">'.$n;
print '<input type="hidden" name="search" value="'.$username.'">'.$n;
print '<input type="hidden" name="type" value="2">'.$n;
print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1">�@'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="180"> <font size="-1">�@'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
if ($fixline eq 'N') {
print '						<input type="submit" name="Submit" value=" �Ȥ�ԲӸ�� ">'.$n;
}else{
print '						<input type="button" name="B1" value=" �Ȥ�ԲӸ�� ">'.$n;
}
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '</form>'.$n;

print '<form name="form1" method="post" action="spam_detail.pl" onSubmit="return Check(form1)">'.$n;
print '<input type="hidden" name="chk_ip" value="'.$chk_ip.'">'.$n;
print '<input type="hidden" name="fixline" value="'.$fixline.'">'.$n;
print '<input type="hidden" name="b_name" value="'.$b_name.'">'.$n;
print '<input type="hidden" name="h_name" value="'.$h_name.'">'.$n;
print '<input type="hidden" name="pop" value="'.$pop.'">'.$n;
print '<input type="hidden" name="chk_datetime" value="'.$chk_datetime.'">'.$n;
print '<input type="hidden" name="level" value="'.$level.'">'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1">�Ȥ�W�١G '.$n;
print '                    </font></td>'.$n;
print '                  <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1">�Ȥ�s���G </font></td>'.$n;
print '                  <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">�@</font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1"> '.$n;
print '                    <input type="text" name="name" maxlength="40" size="15" value="'.$name.'">'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="180"> <font size="-1">�@'.$n;
print '                    <input type="text" name="custid" maxlength="40" size="15" value="'.$custid.'">'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
if ($fixline eq 'Y') {
print '						<input type="submit" name="Submit" value=" �q��IPD�B�z ">'.$n;
}else{
print '						<input type="button" name="B1" value=" �q�� IPD�B�z ">'.$n;
}
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '</form>'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><font size=-1>�@</font></td>'.$n;
print '                </tr>'.$n;

print '              </table>'.$n;
print '            </td>'.$n;
print '          </tr>'.$n;
print '        </table>'.$n;
print '      </td>'.$n;
print '    </tr>'.$n;
print '  </table>'.$n;
print '  <br> '.$n;
print '<a href="javascript:history.go( -1 );">�W�@��</a>'.$n;
print '  <center> '.$n;
print '  </center> '.$n;
print '</body>'.$n;
print '</html>'.$n;

if ($db2) {$db2->disconnect;}
if ($db1) {$db1->disconnect;}
