#!/usr/bin/perl

require "service.pl";
use CGI;
use DBI;

$datasource='mysql';
$db1="dialup";
$un1="root";
$pw1="";
$host1 = "localhost";

if ($userid eq '') {

}

$Select_Default_y="<select name='Theyy' size=1>";
$Select_Default_y.="<option value='2006'>2006</option>";
$Select_Default_y.="<option value='2005'>2005</option>";
$Select_Default_y.="<option value='2004'>2004</option>";
$Select_Default_y.="<option value='2003'>2003</option>";
$Select_Default_y.="<option value='2002'>2002</option>";
$Select_Default_y.="</select>";

$Select_Default_m="<select name='Themm' size=1>";
for ($i=1;$i<=12 ;$i++)
{ 
	$the_ii = padstr_left($i,'0',2);
	$Select_Default_m.="<option value='$the_ii'>$the_ii</option>";
}
$Select_Default_m.="</select>";

$Select_Default_d="<select name='Thedd' size=1>";
for ($i=1;$i<=31 ;$i++)
{ 
	$the_ii = padstr_left($i,'0',2);
	$Select_Default_d.="<option value='$the_ii'>$the_ii</option>";
}
$Select_Default_d.="</select>";

$Select_Default_hr="<select name='Thehr' size=1>";
$Select_Default_hr.="<option value='-'>-</option>";
for ($i=0;$i<=23 ;$i++)
{ 
	$the_ii = padstr_left($i,'0',2);
	$Select_Default_hr.="<option value='$the_ii'>$the_ii</option>";
}
$Select_Default_hr.="</select>";

$Select_Default_mi="<select name='Themi' size=1>";
$Select_Default_mi.="<option value='-'>-</option>";
for ($i=0;$i<=59 ;$i++)
{ 
	$the_ii = padstr_left($i,'0',2);
	$Select_Default_mi.="<option value='$the_ii'>$the_ii</option>";
}
$Select_Default_mi.="</select>";

$Select_Default_se="<select name='These' size=1>";
$Select_Default_se.="<option value='-'>-</option>";
for ($i=0;$i<=59 ;$i++)
{ 
	$the_ii = padstr_left($i,'0',2);
	$Select_Default_se.="<option value='$the_ii'>$the_ii</option>";
}
$Select_Default_se.="</select>";

#<< Set Cookie ###############################
#$cookie = $query->cookie(-name=>'userid',
#                           -value=>$userid,
#                           -path=>'/',
#                           -expires=>$expire);
#print $query->header(-Cookie=>$cookie);
################################ Set Cookie >>

print "Content-type: text/html\n\n";

print '<html>'.$n;
print '<head>'.$n;
print '<title>���_�v�޲z�d�ߨt��</title>'.$n;
print '</head>'.$n;

print '<script language="JavaScript" src="/Utility.js"></script>'.$n;
print '<script language="JavaScript">'.$n;
print '<!--'.$n;
print '  function Check(theForm) {'.$n;
print '    var errmsg="";'.$n.$n;
print '    if (isNaN(theForm.cust_id.value)) {'.$n;
print '      errmsg="�Ȥ�N�����~\n(�N�����ƭȸ��)\n";'.$n;
print '    }'.$n.$n;    
print '    if (errmsg != "") {'.$n;
print '      alert(errmsg);'.$n;
print '      return false;'.$n;
print '    } else {'.$n;
print '      Date(theForm,"send");'.$n;
print '      Date(theForm,"do");'.$n;
print '      Date(theForm,"finish");'.$n;
print '      return true;'.$n;
print '    }'.$n;
print '  }'.$n.$n;
print '//-->'.$n;
print '</script>'.$n;

print '<body bgcolor="#FFFFFF" background="bg.jpg">'.$n;
print '  <table border="0" cellspacing="8" cellpadding="0" width="600">'.$n;
print '    <tr align="center"> '.$n;
print '      <td width="600"> '.$n;
print '        <table border="1" width="420" align="center" cellspacing="0" bgcolor="#E1F0FF" bordercolor="#002244" cellpadding="2">'.$n;
print '          <tr align="center"> '.$n;
print '            <td width="590"> '.$n;
print '              <table border="0" width="590" align="center" cellpadding="5" bgcolor="#E1F0FF" bordercolor="#CCCCCC" cellspacing="3">'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><font size="3" color="#2244DD"><b>���_�v�޲z�d�ߨt��</b>'.$n;
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '<form name="form1" method="post" action="spam_checkip_new.pl" onSubmit="return Check(form1)">'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="100%" colspan=3><hr size=-1 width="95%"></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1">IP�G '.$n;
print '                    </font></td>'.$n;
print '                  <td width="360" align="left" bgcolor="#E1F0FF"><font size="-1">DateTime�G</font></td>'.$n;
print '                  <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">�@</font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1"> '.$n;
print '                    <input type="text" name="ip" maxlength="40" size="15" value="">'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="360"> <font size="-1"> '.$n;
print '					   '.$Select_Default_y.'�~'.$Select_Default_m.'��'.$Select_Default_d.'��'.$Select_Default_hr.'��'.$Select_Default_mi.'��'.$Select_Default_se.'��';
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
print '						<input type="submit" name="Submit" value=" ���� ">'.$n;
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '</form>'.$n;
print '<form name="form1" method="post" action="spam_showcust_new.pl" onSubmit="return Check(form1)">'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="510" bgcolor="#E1F0FF" colspan=2><font size="-1">�b���ΫȤ�s���G'.$n;
print '                    </font></td>'.$n;
print '                  <td width="90" align="left" bgcolor="#E1F0FF"><font size="-1">�@</font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1"> '.$n;
print '                    <input type="text" name="account" maxlength="40" size="15" value="">'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="360"> <font size="-1"> '.$n;
print '                    <input type="radio" name="iptype" value=1 checked>���� <input type="radio" name="iptype" value=2>�T��'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
print '						<input type="submit" name="Submit" value=" �d�� ">'.$n;
print '                    </font></td>'.$n;
print '                </tr>'.$n;
print '</form>'.$n;
print '<form name="form1" method="post" action="spam_showlist.pl" onSubmit="return Check(form1)">'.$n;
print '                <tr> '.$n;
print '                  <td align="left" width="150" bgcolor="#E1F0FF"><font size="-1">�d�ߪ��A�C��G'.$n;
print '                    </font></td>'.$n;
print '                  <td width="360" align="left" bgcolor="#E1F0FF"><font size="-1">��/�T���G</font></td>'.$n;
print '                  <td valign="middle" width="90"> <font size="-1">�@</font></td>'.$n;
print '                </tr>'.$n;

print '                <tr> '.$n;
print '                  <td valign="middle" width="150"> <font size="-1"> '.$n;
print '                    <select name="thestatus" size=1><option value=0>��ܥ����@</option><option value=1>���v�����@</option><option value=2>�����v���@</option><option value=3>���ѳQ���v���@</option><option value=4>���Ѹӽ��v���@</option><option value=5>�̪�3�Ѥ����v���@</option><option value=6>�̪�3�Ѹӽ��v���@</option></font></td>	'.$n;
print '                    </font></td>'.$n;
print '                  <td valign="middle" width="360"> <font size="-1"> '.$n;
print '                    <select name="iptype" size=1><option value=0>�����@</option><option value=1>�����@</option><option value=2>�T���@</option></font></td>	'.$n;
print '                  <td valign="middle" width="90"> <font size="-1"> '.$n;
print '						<input type="submit" name="Submit" value=" �C�� ">'.$n;
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
print '  <center> '.$n;
print '  </center> '.$n;
print '</body>'.$n;
print '</html>'.$n;

sub padstr_left
  { while ( length($_[0]) < $_[2] ) { $_[0]=$_[1].$_[0] };
    return $_[0];
  }

sub chyy
  { if (length($_[0])==2)
     { $_[0] = ($_[0]=='99' ? '19'.$_[0] : '20'.$_[0]) }
    return $_[0];
  }
