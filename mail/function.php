<?
function iil_C_FetchHeader($fp){
	  fseek($fp,0);
	  $c =0;
		do{
			$line = chop(iil_ReadLine($fp, 300));
			if (strlen($line)>2){
				if (ord($line[0]) <= 32) $lines[$c] .= (empty($lines[$c])?"":"\n").trim($line);
				else{
					$c++;
					$lines[$c]=$line;
				}
			}
		}while($line[0]!=".");
		
		//process header, fill iilBasicHeader obj.
		$numlines = count($lines);
		for ($i=0;$i<$numlines;$i++){
            //echo $lines[$i]."<br>\n";
			list($field, $string) = iil_SplitHeaderLine($lines[$i]);
			
			if (strcasecmp($field, "date")==0){
				$result->date = $string;
				$result->timestamp = iil_StrToTime($string);
			}
			else if (strcasecmp($field, "from")==0) $result->from = str_replace("\n", " ", $string);
			else if (strcasecmp($field, "to")==0) $result->to = $string;
			else if (strcasecmp($field, "subject")==0) $result->subject = str_replace("\n", "", $string);
			else if (strcasecmp($field, "reply-to")==0) $result->replyto=$string;
			else if (strcasecmp($field, "cc")==0) $result->cc = str_replace("\n", " ", $string);
			else if (strcasecmp($field, "Content-Transfer-Encoding")==0) $result->encoding=$string;
			else if (strcasecmp($field, "message-id")==0)
				$result->messageID = substr(substr($string, 1), 0, strlen($string)-2);
		}
		return $result;
}
function iil_ReadLine($fp, $size){
	$line="";
	if (($fp)&&(!feof($fp))){
		do{
			$buffer = fgets($fp, 1024);
			$endID = strlen($buffer) - 1;
			$end = (($buffer[$endID] == "\n")||(feof($fp)));
			$line.=$buffer;
		}while(!$end);
	}
	if (!empty($line)) $line.="\n";
	return $line;
}
function iil_C_FetchStructureString($fp){
	fseek($fp,0);
	if ($fp){
		$str =  iil_C_ReadNParse($fp, "", $line);
	}
	return $str;
}
function iil_C_ReadLine($fp){
		return iil_ReadLine($fp, 300);
}
function iil_ReadHeader($fp){
	$lines = array();
	$c = 0;
	//echo "++++<br>\n";
	do{
		$line = chop(iil_ReadLine($fp, 300));
		//$line = iil_ReadLine($fp, 300);
		if (!empty($line)){
			//echo "Read: ".$line."<br>\n";
			if (ord($line[0]) <= 32) $lines[$c].=" ".trim($line);
			else{
				$c++;
				$lines[$c] = $line;
			}
		}
	}while(!empty($line));
	//echo "++++<br>\n";
	
	return $lines;
}
function iil_ContentHeaderArray($lines){
	//echo "---<br>\n";
	$num_lines = count($lines);
	//initialize header variables with default (fall back) values
	$header["content-type"]["major"] = "text";
	$header["content-type"]["minor"] = "plain";
	$header["content-transfer-encoding"]["data"] = "8bit";
	while ( list($key, $line) = each($lines) ){
		//echo $line."<br>\n";
		list($field, $data) = iil_SplitHeaderLine($line);
		// is this a content header?
		if (iil_StartsWith($field, "Content")){
			$field = strtolower($field);
			// parse line, add "data" and "parameters" to header[]
			$header[$field] = iil_ParseContentHeader($data);
			// need some special care for "content-type" header line
			if (strcasecmp($field, "content-type")==0){
				$typeStr = $header["content-type"]["data"];
				//split major and minor content types
				$slashPos = strpos($typeStr,"/");
				$major_type = substr($typeStr, 0, $slashPos);
				$minor_type = substr($typeStr, $slashPos+1);
				$header["content-type"]["major"] = strtolower($major_type);
				$header["content-type"]["minor"] = strtolower($minor_type);
			}
		}
	}
	return $header;
}
function iil_StartsWith($string, $match){
	if ((empty($string)) || (empty($match))) return false;
	
	if ($string[0]==$match[0]){
		$pos=strpos($string, $match);
		if ( $pos === false) return false;
		else if ( $pos == 0) return true;
		else return false;
	}else{
		return false;
	}
}
function iil_C_ReadNParse($fp, $boundary, &$last_line){

	$original_boundary = $boundary; 
	// read headers from file
	$lines = iil_ReadHeader($fp);
	if (count($lines) == 0) return "";
	// parse header into associative array
	$header = iil_ContentHeaderArray($lines);
	
	// generate bodystructure string(s)
	if (strcasecmp($header["content-type"]["major"], "multipart")==0){
		$params = $header["content-type"]["parameters"];
		while ( list($k, $v) = each($params) ) if (strcasecmp($v, "\"boundary\"")==0) $boundary = "--".str_replace("\"","",$params[$k+1]);
		do{
			$line = iil_C_ReadLine($fp);
		}while(!iil_StartsWith($line, $boundary));
		$str = "(";
		//parse body parts
		do{
			$str .= iil_C_ReadNParse($fp, $boundary, $last_line);
			$end = (((strlen($last_line) - strlen($boundary)) > 0) || (chop($last_line)=="."));
		}while((!$end) && (!feof($fp))&&($line!="."));
		
		$str .=" \"".$header["content-type"]["minor"]."\" (".implode(" ", $params).") NIL NIL)";

		//if next boundary encountered
		if ((chop($line)!=".") && (chop($last_line)!=".")){
			//read up to next message boundary
			do{
				$line = iil_C_ReadLine($fp);
				$end = ((iil_StartsWith($line, $original_boundary)) || (chop($last_line)=="."));
			}while((!$end)&&(!feof($fp))&&(chop($line)!=".")) ;
			$last_line = chop($line);
		}
	}else if (strcasecmp($header["content-type"]["major"], "message")==0){
		//read blank lines (up to and including first line, which hopefully isn't important)
		do{
			$line = iil_C_ReadLine($fp);
		}while(iil_StartsWith($line, "\n"));
		
		//format structure string
		$str = '("'.$header["content-type"]["major"].'" "'.$header["content-type"]["minor"].'"';
		$str.= ' NIL NIL NIL';
		$str.= ' "'.$header["content-transfer-encoding"]["data"].'"';
		$byte_count = 'NIL';
		$str.= " $byte_count NIL ";
		
		//recursively parse content
		$str.= iil_C_ReadNParse($fp, $boundary, $last_line);
		
		//more structure stuff
		$line_count = 'NIL';
		$str.= " $line_count NIL ";
		if (!empty($header["content-disposition"]["data"])){
			$param_a = $header["content-disposition"]["parameters"];
			$str .= "(\"".$header["content-disposition"]["data"]."\" ";
			if ((is_array($param_a)) && (count($param_a) > 0))
				$str .="(".implode(" ", $param_a).")";
			else $str .="NIL";
			$str .= ") ";
		}else $str .= "NIL ";
		$str.= ' NIL)';
	}else{
		// read actual data
		$content_size = 0;
		$num_lines = 0;
		do{
			$line = iil_C_ReadLine($fp);
			$content_size += strlen($line);
			$num_lines++;
			$line = chop($line);
		}while((!iil_StartsWith($line, $boundary)) && ((!feof($fp))&&($line!=".")));
		$last_line = $line;
				
		// generate bodystructure string
		$str = "(";
		$str .= "\"".$header["content-type"]["major"]."\" ";
		$str .= "\"".$header["content-type"]["minor"]."\" ";
		if ((is_array($header["content-type"]["parameters"]))&&(count($header["content-type"]["parameters"]) > 0))
			$str .="(".implode(" ", $header["content-type"]["parameters"]).") ";
		else
			$str .= "NIL ";
		if ($header["content-id"]["data"])
			$str .= "\"".$header["content-id"]["data"]."\" ";
		else
			$str .= "NIL ";
		$str .= "NIL ";
		$str .= "\"".$header["content-transfer-encoding"]["data"]."\" ";
		$str .= $content_size." ";
		if (strcasecmp($header["content-type"]["major"], "text")==0)
			$str .= $num_lines." ";
		$str .= "NIL ";
		if (!empty($header["content-disposition"]["data"])){
			$param_a = $header["content-disposition"]["parameters"];
			$str .= "(\"".$header["content-disposition"]["data"]."\" ";
			if ((is_array($param_a)) && (count($param_a) > 0))
				$str .="(".implode(" ", $param_a).")";
			else $str .="NIL";
			$str .= ") ";
		}else $str .= "NIL ";
		$str .= "NIL ";
		$str = substr($str, 0, strlen($str)-1);
		$str .= ")";
	}
	
	return $str;
}
function iml_ClosingParenPos($str, $start){
    $level=0;
    $len = strlen($str);
    $in_quote = 0;
    for ($i=$start;$i<$len;$i++){
    	if ($str[$i]=="\"") $in_quote = ($in_quote + 1) % 2;
    	if (!$in_quote){
        	if ($str[$i]=="(") $level++;
        	else if (($level > 0) && ($str[$i]==")")) $level--;
        	else if (($level == 0) && ($str[$i]==")")) return $i;
    	}
    }
}
function iil_ParseContentHeader($data){
	$parameters = array();

	$pos = strpos($data, ";");
	if ($pos === false){
		//no';'? then no parameters, all we have is main data
		$major_data = $data;
	}else{
		//every thing before first ';' is main data
		$major_data = substr($data, 0, $pos);
		$data = substr($data, $pos+1);
		
		//go through parameter list (delimited by ';')
		$parameters_a = explode(";", $data);
		while ( list($key, $val) = each($parameters_a) ){
			// split param name from param data
			$val = trim(chop($val));
			$eqpos = strpos($val, "=");
			$p_field = substr($val, 0, $eqpos);
			$p_data = substr($val, $eqpos+1);
			$field = trim(chop($p_field));
			$p_data = trim(chop($p_data));
			// add quotes
			if ($p_data[0]!="\"") $p_data = "\"".$p_data."\"";
			$p_field = "\"".$p_field."\"";
			// add to array
			array_push($parameters, $p_field);
			array_push($parameters, $p_data);
		}
	}
	$result["data"] = trim(chop($major_data));
	if (count($parameters) > 0) $result["parameters"] = $parameters;
	else $result["parameters"] = "NIL";
	
	return $result;
}
function iml_GetRawStructureArray($str){
    $line=substr($str, 1, strlen($str) - 2);
    $line = str_replace(")(", ") (", $line);
	
	$struct = iml_ParseBSString($line);
	if ((strcasecmp($struct[0], "message")==0) && (strcasecmp($struct[1], "rfc822")==0)){
		$struct = array($struct);
	}
    return $struct;
}
function iml_GetNumParts($a, $part){
	if (is_array($a)){
		$parent=iml_GetPartArray($a, $part);
		
		if ((strcasecmp($parent[0], "message")==0) && (strcasecmp($parent[1], "rfc822")==0)){
			$parent = $parent[8];
		}

		$is_array=true;
		$c=0;
		while (( list ($key, $val) = each ($parent) )&&($is_array)){
			$is_array=is_array($parent[$key]);
			if ($is_array) $c++;
		}
		return $c;
	}
	
	return false;
}
function iml_GetPartTypeCode($a, $part){
	$types=array(0=>"text",1=>"multipart",2=>"message",3=>"application",4=>"audio",5=>"image",6=>"video",7=>"other");

	$part_a=iml_GetPartArray($a, $part);
	if ($part_a){
		if (is_array($part_a[0])) $str="multipart";
		else $str=$part_a[0];

		$code=7;
		while ( list($key, $val) = each($types)) if (strcasecmp($val, $str)==0) $code=$key;
		return $code;
	}else return -1;
}
function LangDecodeSubject($input, $charset){
	$out = "";
	//echo "Received: $input <br>\n";
	$pos = strpos($input, "=?");
	if ($pos !== false){
		$out = substr($input, 0, $pos);

		$end_cs_pos = strpos($input, "?", $pos+2);
		$end_en_pos = strpos($input, "?", $end_cs_pos+1);
		$end_pos = strpos($input, "?=", $end_en_pos+1);

		$encstr = substr($input, $pos+2, ($end_pos-$pos-2));
		//echo "encstr: $encstr <br>\n";
		$rest = substr($input, $end_pos+2);
		//echo "rest: $rest <br>\n";
		$out.=LangDecodeMimeString($encstr, $charset);
		$out.=LangDecodeSubject($rest, $charset);
		//echo "returning: $out <br>\n";
		return $out;
	}else{
		return LangConvert($input, $charset, $charset);
	}
}
function encodeUTFSafeHTML($str){
	$result = $str;
	$result = str_replace("\"", "&quot;", $result);
	$result = str_replace("<", "&lt;", $result);
	$result = str_replace(">", "&gt;", $result);
	
	return $result;
}
function LangDecodeAddressList($str, $charset, $user){
	$a=LangParseAddressList($str);
	if (is_array($a)){
		$c=count($a);
        $j=0;
		reset($a);
		while( list($i, $val) = each($a) ){
            $j++;
			$address=$a[$i]["address"];
			$name=str_replace("\"", "", $a[$i]["name"]);
			$res.=LangFormAddressHTML($user, $name, $address, $charset);
			if ((($j % 3)==0) && (($c-$j)>1)) $res.=",<br>&nbsp;&nbsp;&nbsp;";
			else if ($c>$j) $res.=",&nbsp;";
			//$res.=(($c>1)&&($j<$c)?",<br>&nbsp;&nbsp;&nbsp;":"");
		}
	}
	
	return $res;
}
function ShowBytes($numbytes){
	if ($numbytes > 1024){
		$kb=(int)($numbytes/1024);
		return $kb." KB";
	}else{
		return $numbytes." B";
	}
}
function iml_GetPartName($a, $part){
	$part_a=iml_GetPartArray($a, $part);
	if ($part_a){
		if (is_array($part_a[0])) return -1;
		else{
            $name = "";
			if (is_array($part_a[2])){
                //first look in content type
				$name="";
				while ( list($key, $val) = each ($part_a[2])){
                    if ((strcasecmp($val, "NAME")==0)||(strcasecmp($val, "FILENAME")==0)) 
                        $name=$part_a[2][$key+1];
                }
			}
            if (empty($name)){
                //check in content disposition
                //$id = count($part_a) - 2;
                $id = 8;
				if ((is_array($part_a[$id])) && (is_array($part_a[$id][1]))){
                    $array = $part_a[$id][1];
                    while ( list($key, $val) = each($array)){
                        if ((strcasecmp($val, "NAME")==0)||(strcasecmp($val, "FILENAME")==0)) 
                            $name=$array[$key+1];
                    }
                }
            }
			return $name;
		}
	}else return "";
}
function iml_GetPartTypeString($a, $part){
	$part_a=iml_GetPartArray($a, $part);
	if ($part_a){
		if (is_array($part_a[0])){
			$type_str = "MULTIPART/";
			reset($part_a);
			while(list($n,$element)=each($part_a)){
				if (!is_array($part_a[$n])){
					$type_str.=$part_a[$n];
					break;
				}
			}
			return $type_str;
		}else return $part_a[0]."/".$part_a[1];
	}else return false;
}
function iml_GetPartSize($a, $part){
	$part_a=iml_GetPartArray($a, $part);
	if ($part_a){
		if (is_array($part_a[0])) return -1;
		else return $part_a[6];
	}else return -1;
}
function iml_GetPartEncodingCode($a, $part){
	$encodings=array("7BIT", "8BIT", "BINARY", "BASE64", "QUOTED-PRINTABLE", "OTHER");

	$part_a=iml_GetPartArray($a, $part);
	if ($part_a){
		if (is_array($part_a[0])) return -1;
		else $str=$part_a[5];

		$code=5;
		while ( list($key, $val) = each($encodings)) if (strcasecmp($val, $str)==0) $code=$key;

		return $code;

	}else return -1;
}
function iml_GetPartDisposition($a, $part){
	$part_a=iml_GetPartArray($a, $part);
	if ($part_a){
		if (is_array($part_a[0])) return -1;
		else{
            $id = count($part_a) - 2;
			if (is_array($part_a[$id])) return $part_a[$id][0];
			else return "";
		}
	}else return "";
}
function iil_C_FetchBodyPart(&$fp, $boundary, &$last_line, $the_part, &$part, $action, $bytes_total, &$bytes_read){
	if ($the_part==0) $the_part="";
	$original_boundary = $boundary; 
	$raw_header = "";
	$raw_text = "";
	// read headers from file
	$lines = array();
	$count = 0;
	do{
		$line = iil_C_ReadLine($fp);
		$bytes_read+=strlen($line);
		$raw_header .= $line;
		$line = chop($line);
		if (!empty($line)){
			//echo "Read: ".$line."<br>\n";
			$c = 0;
			if (ord($line[0]) <= 32) $lines[$count].=" ".trim($line);
			else{
				$count++;
				$lines[$count] = $line;
				//echo "\t".$count.":".$line."\n";
			}
		}
	}while(!empty($line));
	if ((strcmp($part, $the_part)==0)&&(strcmp($action, "FetchHeader")==0)) $str=$raw_header;
	
	//echo "Read header: ".count($lines)." lines\n"; flush();
	
	// parse header into associative array
	$header = iil_ContentHeaderArray($lines);
	
	//echo "Parsed headers\n"; flush();
	//echo implode("\n", $lines)."\n\n";
	
	//echo $header["content-type"]["major"]." vs multipart";
	
	// generate bodystructure string(s)
	if (strcasecmp($header["content-type"]["major"], "multipart")==0){
		//echo "Parsing multipart\n"; flush();
		
		$params = $header["content-type"]["parameters"];
		while ( list($k, $v) = each($params) ) if (strcasecmp($v, "\"boundary\"")==0) $boundary = "--".str_replace("\"","",$params[$k+1]);
		//echo "Boundary: ".$boundary."<br>\n";
		do{
			$line = iil_C_ReadLine($fp);
			$bytes_read+=strlen($line);
		}while(!iil_StartsWith($line, $boundary));

		//parse body parts
		$part_num = 0;
		do{
			$part_num++;
			$next_part = $part.(!empty($part)?".":"").$part_num;
			$str .= iil_C_FetchBodyPart($fp, $boundary, $last_line, $the_part, $next_part, $action, $bytes_total, $bytes_read);
			$end = (((strlen($last_line) - strlen($boundary)) > 0) || (chop($last_line)=="."));
		}while((!$end) && (!feof($fp))&&(chop($last_line)!="."));

		//read up to next message boundary
		if (chop($last_line)!="."){
			do{
				$line = iil_C_ReadLine($fp);
				$bytes_read += strlen($line);
				$end = ((iil_StartsWith($line, $original_boundary)) || (chop($last_line)=="."));
			}while((!$end)&&(!feof($fp))&&(chop($line)!="."));
			$last_line = chop($line);
		}
	}else if (strcasecmp($header["content-type"]["major"], "message")==0){
		//read blank lines (up to and including first line, which hopefully isn't important)
		do{
			$line = iil_C_ReadLine($fp);
		}while(iil_StartsWith($line, "\n"));
		
		$str .= iil_C_FetchBodyPart($fp, $boundary, $last_line, $the_part, $part, $action, $bytes_total, $bytes_read);
	}else{
		// read actual data
		//echo "Will do action: $action <br>\n"; flush();
		if (strcmp($part, $the_part)==0){
			$this_is_it=ture;
			$handler = "iil_Action".$action;
		}else $this_is_it = false;
		do{
			$line = iil_C_ReadLine($fp);
			$bytes_read += strlen($line);
			if (($this_is_it)&&(!iil_StartsWith($line, $boundary))&&(chop($line)!=".")) $str.=$handler($line);
			$line = chop($line);
			//echo "Read $bytes_read of $bytes_total bytes<br>\n"; flush();
		}while((!iil_StartsWith($line, $boundary)) && ((!feof($fp))&&($line!=".")));
		$last_line = $line;
	}
	
	//echo "Read $bytes_read out of $bytes_total <br>\n"; flush();

	return $str;
}
function iil_C_HandlePartBody(&$fp, $part, $action){	
/*	global $messageID;
	$messageID = iil_C_OpenMessage($fp);
*/	
	//echo "Message opened\n"; flush();

	//echo "FP opened\n";

	if ($fp){
		//echo "Going ingot iil_C_FetchBodyPart\n";
		$result =  iil_C_FetchBodyPart($fp, "", $line, $part, $part_blah, $action, $total_size, $bytes);
	}else{
		echo "Bad fp";
	}
	return $result;
}
function iil_ActionFetchBody($line){
	return chop($line)."\n";
}
function iil_ActionFetchHeader($line){
	return "";
}
function iil_C_FetchPartBody(&$fp, $part){
	return iil_C_HandlePartBody($fp, $part, "FetchBody");
}
function gpg_decrypt($gpg_passphrase, &$body){
	global $GPG_HOME_STR, $GPG_PATH;
	global $loginID, $host, $user;

	//$oldhome = getEnv("HOME");
	//$blah = nl2br($body);
	$original = $body;
	$gpg_home = str_replace("%h", $host, str_replace("%u", $loginID, $GPG_HOME_STR));
	$temp_file = $gpg_home."/$user-gpg.tmp";
	$fp = fopen($temp_file,'w');
	//$fp = fopen("/home/$loginID/.gnupg/blah",'w');
	if ($fp){
		fwrite($fp, $body, strlen($body));
		fclose($fp);
		
		$temp = 'echo "'.escapeshellcmd($gpg_passphrase).'" | '.$GPG_PATH.' --home='.$gpg_home.' -v --batch --passphrase-fd 0 --decrypt '.escapeshellcmd($temp_file);
		$blah = exec($temp, $body, $errorcode);
		
		if ($errorcode==0){
			$body = implode("\n", $body);
			$body = stripslashes($body);
		}else{
			$body = "gpg_decrypt: Decryption failed... (errorno: $errorcode)\n\n".$original;
		}
		unlink($temp_file);
		//unlink("/home/$loginID/.gnupg/$fp");
	}else{
		$body =  "gpg_decrypt: Couldn't open temp file: $temp_file\n\n".$original;
	}
}
function iml_GetPartCharset($a, $part){
	$part_a=iml_GetPartArray($a, $part);
	if ($part_a){
		if (is_array($part_a[0])) return -1;
		else{
			if (is_array($part_a[2])){
				$name="";
				while ( list($key, $val) = each ($part_a[2])) if (strcasecmp($val, "charset")==0) $name=$part_a[2][$key+1];
				return $name;
			}
			else return "";
		}
	}else return "";
}

function iil_C_FetchPartHeader(&$fp, $part){
	return iil_C_HandlePartBody($fp, $part, "FetchHeader");
}

function LangConvert($string, $charset, $from_charset){
	$CS_CAN_CONVERT["ISO-2022-JP"]=1;
	$CS_CAN_CONVERT["EUC-JP"]=1;
	$CS_CAN_CONVERT["X-EUC-JP"]=1;
	$CS_CAN_CONVERT["Shift-JIS"]=1;
	$CS_CAN_CONVERT["JIS"]=1;
	$CS_CAN_CONVERT["ISO-8859-1"]=1;

	$from_charset = strtoupper($from_charset);

	if (!$CS_CAN_CONVERT[$from_charset]){
		return $string;
	}else if ($from_charset=="ISO-8859-1"){
		return LangEncode8bitLatin($string);
	}else if (strcasecmp($charset, "x-euc-jp")==0){
		return JcodeConvert($string, 0, 1);
	}else{
		return $string;
	}
}
function LangEncode8bitLatin($str){
	//following code inspired by SquirrelMail's
	//charset_decode_utf8 in utf-8.php
	
    /* Only do the slow convert if there are 8-bit characters */
    /* avoid using 0xA0 (\240) in ereg ranges. RH73 does not like that */
    if (! ereg("[\200-\237]", $str) and ! ereg("[\241-\377]", $str))
        return $str;

    // encode 8-bit ISO-8859-1 into HTML entities 
	// works because Unicode uses ISO-8859-1 for those ranges
    $str = preg_replace("/([\200-\377])/e", "'&#'.(ord('\\1')).';'",$str);

    return $str;
}
function encodeHTML($str){
	$result = $str;
	$result = str_replace("&", "&amp;", $result);
	$result = str_replace("<", "&lt;", $result);
	$result = str_replace(">", "&gt;", $result);
	
	return $result;
}
function iil_SplitHeaderLine($string){
	$pos=strpos($string, ":");
	if ($pos>0){
		$res[0]=substr($string, 0, $pos);
		$res[1]=substr($string, $pos+2);
		return $res;
	}else{
		return $string;
	}
}
function iil_StrToTime($str){
	//replace double spaces with single space
	$str = trim($str);
	$str = str_replace("  ", " ", $str);
	
	//strip off day of week
	$pos=strpos($str, " ");
	$word = substr($str, 0, $pos);
	if (!is_numeric($word)) $str = substr($str, $pos+1);

	//explode, take good parts
	$a=explode(" ",$str);
	$month_a=array("Jan"=>1,"Feb"=>2,"Mar"=>3,"Apr"=>4,"May"=>5,"Jun"=>6,"Jul"=>7,"Aug"=>8,"Sep"=>9,"Oct"=>10,"Nov"=>11,"Dec"=>12);
	$month_str=$a[1];
	$month=$month_a[$month_str];
	$day=$a[0];
	$year=$a[2];
	$time=$a[3];
	$tz_str = $a[4];
	$tz = substr($tz_str, 0, 3);
	$ta=explode(":",$time);
	$hour=(int)$ta[0]-(int)$tz;
	$minute=$ta[1];
	$second=$ta[2];

	//make UNIX timestamp
	return mktime($hour, $minute, $second, $month, $day, $year);
}
function iil_C_OpenMessage(&$fp){
	return iil_F_GetMessageID($fp);
}
function iil_F_GetMessageID($fp){
	$messageID = "";
		do{
			//go through headers...
			$line = chop(iil_ReadLine($fp, 300));
			$a = iil_SplitHeaderLine($line);
			if (strcasecmp($a[0], "message-id")==0){
				$messageID = trim(chop($a[1]));
				$messageID = substr(substr($messageID, 1), 0, strlen($messageID)-2);
			}
		}while($line[0]!=".");
	return $messageID;
}
function iil_C_CloseMessage(&$conn){
	if (($conn->cacheMode=="r") || ($conn->cacheMode=="w")) fclose($conn->cacheFP);
	$conn->cacheMode = "x";
	$conn->messageID = "";
}
function iml_ParseBSString($str){	
    
    $id = 0;
    $a = array();
    $len = strlen($str);
    
    $in_quote = 0;
    for ($i=0; $i<$len; $i++){
        if ($str[$i] == "\"") $in_quote = ($in_quote + 1) % 2;
        else if (!$in_quote){
            if ($str[$i] == " ") $id++; //space means new element
            else if ($str[$i]=="("){ //new part
                $i++;
                $endPos = iml_ClosingParenPos($str, $i);
                $partLen = $endPos - $i;
                $part = substr($str, $i, $partLen);
                $a[$id] = iml_ParseBSString($part); //send part string
                if ($verbose){
					echo "{>".$endPos."}";
					flush();
				}
                $i = $endPos;
            }else $a[$id].=$str[$i]; //add to current element in array
        }else if ($in_quote){
            if ($str[$i]=="\\") $i++; //escape backslashes
            else $a[$id].=$str[$i]; //add to current element in array
        }
    }
        
    reset($a);
    return $a;
}
function iml_GetPartArray($a, $part){
	if (!is_array($a)) return false;
	if (strpos($part, ".") > 0){
		$original_part = $part;
		$pos = strpos($part, ".");
		$rest = substr($original_part, $pos+1);
		$part = substr($original_part, 0, $pos);
		if ((strcasecmp($a[0], "message")==0) && (strcasecmp($a[1], "rfc822")==0)){
			$a = $a[8];
		}
		//echo "m - part: $original_part current: $part rest: $rest array: ".implode(" ", $a)."<br>\n";
		return iml_GetPartArray($a[$part-1], $rest);
	}else if ($part>0){
		if ((strcasecmp($a[0], "message")==0) && (strcasecmp($a[1], "rfc822")==0)){
			$a = $a[8];
		}
		//echo "s - part: $part rest: $rest array: ".implode(" ", $a)."<br>\n";
		if (is_array($a[$part-1])) return $a[$part-1];
		else return false;
	}else if (($part==0) || (empty($part))){
		return $a;
	}
}
function LangDecodeMimeString($str, $charset){
	$a=explode("?", $str);
	$count = count($a);
	if ($count >= 3){			//should be in format "charset?encoding?base64_string"
		for ($i=2; $i<$count; $i++) $rest.=$a[$i];
		
		if (($a[1]=="B")||($a[1]=="b")) $rest = base64_decode($rest);
		else if (($a[1]=="Q")||($a[1]=="q")){
			$rest = str_replace("_", " ", $rest);
			$rest = quoted_printable_decode($rest);
		}
		if (strcasecmp($a[0], "utf-8")==0){
			include_once("../include/utf8.inc");
			return utf8ToUnicodeEntities($rest);
		}else{
			return LangConvert($rest, $charset, $a[0]);
		}
	}else{
		return $str;		//we dont' know what to do with this
	}
}
function LangParseAddressList($str){
	$a=LangExplodeQuotedString(",", $str);
	$result=array();
	reset($a);
	while( list($key, $val) = each($a) ){
		$val = str_replace("\"<", "\" <", $val);
		$sub_a = LangExplodeQuotedString(" ", $val);
		reset($sub_a);
		while ( list($k, $v) = each($sub_a) ){
			if ((strpos($v, "@") > 0) && (strpos($v, ".") > 0)) 
				$result[$key]["address"] = str_replace("<", "", str_replace(">", "", $v));
			else $result[$key]["name"] .= (empty($result[$key]["name"])?"":" ").str_replace("\"","",stripslashes($v));
		}
		if (empty($result[$key]["name"])) $result[$key]["name"] = $result[$key]["address"];
	}
	
	return $result;
}
function LangExplodeQuotedString($delimiter, $string){
	$quotes=explode("\"", $string);
	while ( list($key, $val) = each($quotes))
		if (($key % 2) == 1) 
			$quotes[$key] = str_replace($delimiter, "_!@!_", $quotes[$key]);
	$string=implode("\"", $quotes);
	
	$result=explode($delimiter, $string);
	while ( list($key, $val) = each($result) )
		$result[$key] = str_replace("_!@!_", $delimiter, $result[$key]);
	
	return $result;
}
function LangFormAddressHTML($user, $name, $address, $charset){
	global $my_prefs;
	
	if ($my_prefs["compose_inside"]) $target="list2";
	else $target="_blank";
	
	if (empty($name)) $name=$address;
	$decoded_name = LangDecodeSubject($name, $charset);
	if (strpos($decoded_name, " ")!==false) $q_decoded_name = "\"".$decoded_name."\"";
	else $q_decoded_name = $decoded_name;
	
//	$url = "compose2.php?user=".$user."&to=".urlencode($q_decoded_name." <".$address.">");
$url = "#";	
	$res="";
	$res.="<span>".LangDisableHTML($decoded_name)." < ".$address." ></span>";
//	$res.="[<a href=\"edit_contact.php?user=$user&name=".urlencode($decoded_name)."&email=".urlencode($address)."&edit=-1\">+</a>]";
	return $res;
}
function LangDisableHTML($str){
	$result = $str;
	$result = str_replace("<", "&lt;", $result);
	$result = str_replace(">", "&gt;", $result);
	
	return $result;
}
/*function RemoveDoubleAddresses($to) {
	$to_adr = iil_ExplodeQuotedString(",", $to);
	$adresses = array();
	$contacts = array();
	foreach($to_adr as $addr) {
		$addr = trim($addr);
		if (preg_match("/(.*<)?.*?([^\s\"\']+@[^\s>\"\']+)/", $addr, $email)) {
			$email = strtolower($email[2]);
			if (!in_array($email, $adresses)) {						//New adres
				array_push($adresses, $email);
				$contacts[$email] = $addr;
			} elseif (strlen($contacts[$email])<strlen($addr)) {				//Adres already in list and name is longer
				$contacts[$email] = trim($addr);
			}
		}
	}
	return implode(", ",$contacts);
}
function iil_ExplodeQuotedString($delimiter, $string){
	$quotes=explode("\"", $string);
	while ( list($key, $val) = each($quotes))
		if (($key % 2) == 1) 
			$quotes[$key] = str_replace($delimiter, "_!@!_", $quotes[$key]);
	$string=implode("\"", $quotes);
	
	$result=explode($delimiter, $string);
	while ( list($key, $val) = each($result) )
		$result[$key] = str_replace("_!@!_", $delimiter, $result[$key]);
	
	return $result;
}*/
?>
