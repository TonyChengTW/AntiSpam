sub getfile
  { undef $/ ;
    local(*FILE); open(FILE,"<$_[0]") ; $_ = <FILE> ; close(FILE);
    $/ = "\n" ;
    return $_ ;
  };

sub gethtml { return "print <<END;\n".getfile($_[0])."\nEND" }

sub modify
  { $_[0] =~ s/\\/\\\\/g;
    $_[0] =~ s/'/\\'/g;
    return $_[0];
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

sub send_data
  {
   $server = "203.79.224.92";
   $port = "9998";
   $proto = getprotobyname('tcp');

   $hisiaddr = inet_aton($server) or die "unknow host";
   $hispaddr = sockaddr_in($port,$hisiaddr);

   socket(SOCKET, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";

   connect(SOCKET, $hispaddr) or die "connect: $!";

   $sql = $_[0];
   send(SOCKET, $sql, 0);
   read(SOCKET, $line, 4096, 0);

   close(SOCKET);
   return $line;
  }
1;

