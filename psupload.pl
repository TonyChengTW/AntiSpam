#!/usr/bin/perl

use CGI; 
$upfilecount = 1;
$maxuploadcount = 1; #����W�Ǥ�󪺳̤j��
$basedir = "/home/httpd/htdocs/spammail"; #�W�Ǫ����s��a�}
$allowall = "yes"; #�O�_����������ɦW�W��
@theext =(".zip",".exe",".gif"); #�n��������W

print "Content-type: text/html\n\n";

while ($upfilecount <= $maxuploadcount) {
    my $req = new CGI; 
	$ppp = $req->param('good');

    my $file = $req->param("FILE$upfilecount"); 
    if ($file ne "") {
        my $fileName = $file;
        $fileName =~ s/^.*(\\|\/)//; #�Υ��h��F���h���L�Ϊ����|�W�A�o����W
        my $newmain = $fileName;
        my $filenotgood;
            $extname = lc(substr($newmain,length($newmain) - 4,4)); #�����ɦW 
        if ($allowall ne "yes") {
            $extname = lc(substr($newmain,length($newmain) - 4,4)); #�����ɦW
            for(my $i = 0; $i < @theext; $i++){ #�o�q�i����W�˴�
                if ($extname eq $theext[$i]){
                    $filenotgood = "yes";
                    last;
                }
            }
        }
        if ($filenotgood ne "yes") { #�o�q�}�l�W��
	#�ھڮɶ������ɦW
	$newfileName = "spam_".time().$extname;
            open (OUTFILE, ">$basedir/$newfileName");
            binmode(OUTFILE); #�ȥ����ΤG�i��覡�A�o�˴N�i�H��ߤW�ǤG�i����F�C�ӥB�奻���]���|���z�Z
            while (my $bytesread = read($file, my $buffer, 1024)) { 
                print OUTFILE $buffer;
            }
            close (OUTFILE);
            $message.=$file . " �w�W��!<br>\n";
        }
        else{
            $message.=$file . " �����ɦW���ŦX�n�D�A�W�ǥ���!<br>\n";
        }
    }
    $upfilecount++;
}


print "$message , [$ppp]"; #�̫��X�W�ǫH�� 
