#!/usr/bin/perl

require "service.pl";
use CGI;
use DBI;

$cgi = new CGI;

$datasource='mysql';
$db1="spam";
$un1="root";
$pw1="";
$host1 = "localhost";

$account = $cgi->param('account');
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

$dbh1=DBI->connect("DBI:$datasource:$db1:$host1", "$un1", "$pw1") or die "Can'tConnectTercel!!\n";

$sql_sel="select * from spam where account='$account'";
$sth=$dbh1->prepare($sql_sel);
$sth->execute();
$findit=$sth->rows;
$row_acc=$sth->fetchrow_hashref;
$sth->finish();
if (not $findit) {
$show_the_desc.="<font color=brown> ���Ȥ᥼�����v�O��</font>";
}else{
if ($row_acc->{valid} eq 'Y') {
$show_the_desc.="<font color=brown> ���Ȥ�ثe�Q��$row_acc->{level} �����v,�ثe���v��</font>";
}else{
$show_the_desc.="<font color=brown> ���Ȥᴿ�Q��$row_acc->{level} �����v,�ثe�����v</font>";
}
}

if ($row_acc->{iptype} eq '1') {$show_iptype='�ʺA';}else{$show_iptype='�T�w';}
if ($row_acc->{reason} eq '1') {$show_reason='SPAM';}elsif($row_acc->{reason} eq '2'){$show_reason='Virus';}else{$show_reason='Open-Relay';}
print "Content-type: text/html\n\n";
print '<html>'.$n;
print '<head>'.$n;
print '<title>���_�v�޲z�d�ߨt��</title>'.$n;
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
print '                  <td align="left" width="180" bgcolor="#E1F0FF"><font size="-1" color=blue><b>�b���G'.$account.'</b></font></td>'.$n;
print '                  <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1" color=blue><b>IP�G'.$row_acc->{ip}.'</b></font></td>'.$n;
print '                  <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">�@</font></td>'.$n;
print '                </tr>'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="180" bgcolor="#E1F0FF"><font size="-1" color=blue><b>���v�ɶ��G'.$row_acc->{settime}.'</b></font></td>'.$n;
print '                  <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1" color=blue><b>�w�p�_�v�ɶ��G'.$row_acc->{duetime}.'</b></font></td>'.$n;
print '                  <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">�@</font></td>'.$n;
print '                </tr>'.$n;
print '<form name="form1" method="post" action="spam_showfile.pl" onSubmit="return Check(form1)" target="new">'.$n;
print '<input type="hidden" name="account" value="'.$account.'">'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><hr size=-1 width="95%"></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><font size=2 color=red> '.$show_the_desc.' </font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=2><font size="2">���D�G<input type="text" name="title" maxlength="40" size="30" value="'.$row_acc->{title}.'"></font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
print '						<input type="submit" name="Submit" value=" �d�߫H��s�� ">'.$n;
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '</form>'.$n;

print '<form name="form1" method="post" action="http://203.79.224.102/ht/customer.cgi" onSubmit="return Check(form1)">'.$n;
print '<input type="hidden" name="search" value="'.$account.'">'.$n;
print '<input type="hidden" name="type" value="2">'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="180" bgcolor="#E1F0FF"><font size="-1">���v��]</font></td>'.$n;
print '                  <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1">IP  ����</font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
if ($row_acc->{iptype} eq '1') {
print '						<input type="submit" name="Submit" value=" �Ȥ�ԲӸ�� ">'.$n;
}else{
print '						<input type="button" name="B1" value=" �Ȥ�ԲӸ�� ">'.$n;
}
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '</form>'.$n;



#=mark
print '<form name="form1" method="post" action="/cgi-bin/spam/spam_force.pl">'.$n;
print '<input type="hidden" name="username" value="'.$account.'">'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="180" bgcolor="#E1F0FF"><font size="-1">�u���b�䤣��Τ�s�u�����ɨϥ�</font></td>'.$n;
print '                  <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1"></font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
print '                                         <input type="submit" name="Submit" value="�j�����v">'.$n;
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '</form>'.$n;
#=cut

print '<form name="form1" method="post" action="/cgi-bin/spam/spam_reset.pl">'.$n;
print '<input type="hidden" name="account" value="'.$account.'">'.$n;
print '<input type="hidden" name="iptype" value="1">'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="180" bgcolor="#E1F0FF"><font size="-1">�u���b�䤣��Τᰱ�v�����ɤ~�i�ϥ�</font></td>'.$n;
print '                  <td width="180" align="left" bgcolor="#E1F0FF"><font size="-1"></font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
print '                                         <input type="submit" name="Submit" value="�j�����v">'.$n;
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '</form>'.$n;


print '<form name="form1" method="post" action="spam_reset.pl" onSubmit="return Check(form1)">'.$n;
print '<input type="hidden" name="account" value="'.$account.'">'.$n;
print '<input type="hidden" name="iptype" value="'.$row_acc->{iptype}.'">'.$n;
print '                <tr> '.$n;
print '                  <td valign="middle" width="180"> <font size="-1"> '.$n;
print '                    <input type="radio" name="reason" checked>'.$show_reason.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="180"> <font size="-1">'.$n;
print '                    <input type="radio" name="iptype" checked>'.$show_iptype.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1">�@'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="180"> <font size="-1">�@'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="180"> <font size="-1">�@'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
print '                    </font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="180"> <font size="-1"> '.$n;
if (($row_acc->{iptype} eq '1') and ($row_acc->{valid} eq 'Y')){
print '						<input type="submit" name="Submit" value=" �_�v ">'.$n;
}elsif (($row_acc->{iptype} eq '2') and ($row_acc->{valid} eq 'Y')){
print '						<input type="Submit" name="Submit" value=" �T�w ">'.$n;
}else{
print '						<input type="button" name="B1" value=" ���ݴ_�v ">'.$n;
}
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="180"> <font size="-1">�@'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1">�@'.$n;
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
print '<a href="javascript:history.go( -1 );">�W�@��</a>'.$n;
print '  <center> '.$n;
print '  </center> '.$n;
print '</body>'.$n;
print '</html>'.$n;

if ($db1) {$db1->disconnect;}
