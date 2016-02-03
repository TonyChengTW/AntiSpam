#!/usr/bin/perl

use CGI; 
$upfilecount = 1;
$maxuploadcount = 1; #限制上傳文件的最大數
$basedir = "/home/httpd/htdocs/spammail"; #上傳的文件存放地址
$allowall = "yes"; #是否不限制文件副檔名上傳
@theext =(".zip",".exe",".gif"); #要限制的文件後綴名

print "Content-type: text/html\n\n";

while ($upfilecount <= $maxuploadcount) {
    my $req = new CGI; 
	$ppp = $req->param('good');

    my $file = $req->param("FILE$upfilecount"); 
    if ($file ne "") {
        my $fileName = $file;
        $fileName =~ s/^.*(\\|\/)//; #用正則表達式去除無用的路徑名，得到文件名
        my $newmain = $fileName;
        my $filenotgood;
            $extname = lc(substr($newmain,length($newmain) - 4,4)); #取副檔名 
        if ($allowall ne "yes") {
            $extname = lc(substr($newmain,length($newmain) - 4,4)); #取副檔名
            for(my $i = 0; $i < @theext; $i++){ #這段進行後綴名檢測
                if ($extname eq $theext[$i]){
                    $filenotgood = "yes";
                    last;
                }
            }
        }
        if ($filenotgood ne "yes") { #這段開始上傳
	#根據時間產生檔名
	$newfileName = "spam_".time().$extname;
            open (OUTFILE, ">$basedir/$newfileName");
            binmode(OUTFILE); #務必全用二進制方式，這樣就可以放心上傳二進制文件了。而且文本文件也不會受干擾
            while (my $bytesread = read($file, my $buffer, 1024)) { 
                print OUTFILE $buffer;
            }
            close (OUTFILE);
            $message.=$file . " 已上傳!<br>\n";
        }
        else{
            $message.=$file . " 文件副檔名不符合要求，上傳失敗!<br>\n";
        }
    }
    $upfilecount++;
}


print "$message , [$ppp]"; #最後輸出上傳信息 
