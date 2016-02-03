#!/usr/bin/perl
use Date::Calc qw(:all);

#($sec,$min,$hour,$day,$month,$year) = localtime();
#$sec = sprintf("%02d",$sec);
#$min = sprintf("%02d",$min);
#$hour = sprintf("%02d",$hour);
#$day = sprintf("%02d",$day);
#$month = sprintf("%02d",++$month);
#$year+=1900;
#----------------------------------------------
$year = 2006;
$month = 01;
$day = 01;

#print <<END_OF_TIME;
#$year$month$day$hour$min$sec
#END_OF_TIME

($m_year,$m_month,$m_day) = Add_Delta_Days($year,$month,$day, +33);
print "Setting is:$year"."$month"."$day\n";
print "\$m_year : $m_year\n";
print "\$m_month : $m_month\n";
print "\$m_day : $m_day\n";
