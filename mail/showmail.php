#!/usr/bin/php
<?
//  $account = $_GET["account"];
  $account = "ag097291";
	include("sql.php");
	include("function.php");
	$showspaminfo = selectSpam();
	$content = $showspaminfo[0]["content"];
	$arrayContent = explode("<br>",$content);
	$t = time();
	$filename = "/tmp/".$t.".txt";
	$fp = fopen($filename,"w");
	foreach($arrayContent as $val){
		fwrite($fp,$val."\n");
	}
	fwrite($fp,".\n");
	fclose($fp);
  echo "<HTML><HEAD><meta http-equiv=\"Content-Type\" content=\"text/html; charset=BIG5\"><link rel=\"stylesheet\" href=\"my.css\" type=\"text/css\"><TITLE></TITLE></HEAD><BODY>";	
	$my_prefs["html_in_frame"] = true;
	$my_charset = "BIG5";
	$my_colors["main_darkbg"] = "#FAFFE5";
	$my_colors["main_hilite"] = "#E6EDB6";
	$fp = fopen($filename,"r");
	$header = iil_C_FetchHeader($fp);
	fseek($fp,0);
	$structure_str=iil_C_FetchStructureString($fp); 
	fseek($fp,0);
	echo "\n<!-- ".$structure_str."-->\n"; flush();
	$structure=iml_GetRawStructureArray($structure_str);
	$num_parts=iml_GetNumParts($structure, $part);
	$parent_type=iml_GetPartTypeCode($structure, $part);
	$uid = $header->uid;
	
	if (($parent_type==1) && ($num_parts==1)){
		$part = 1;
		$num_parts=iml_GetNumParts($structure, $part);
		$parent_type=iml_GetPartTypeCode($structure, $part);
	}

	//show subject
	echo "\n<!-- SUBJECT //-->\n";
	echo "<table width=\"100%\" border=\"0\" cellspacing=\"1\" cellpadding=\"1\" bgcolor=\"".$my_colors["main_darkbg"]."\">\n";
	echo "<tr bgcolor=\"".$my_colors["main_darkbg"]."\"><td valign=\"top\" colspan=2>\n";
		echo "\n<span><b>".encodeUTFSafeHTML(LangDecodeSubject($header->subject, $my_prefs["charset"]))."</b>";
		echo "<br>&nbsp;</span></td>\n";
	echo "</tr>\n";
	echo "</table>\n\n";

	//show header
	echo "\n<!-- HEADER //-->\n";
	echo "<table width=\"100%\" border=\"0\" cellspacing=\"1\" cellpadding=\"1\" bgcolor=\"".$my_colors["main_head_bg"]."\">\n";
	echo "<tr bgcolor=\"".$my_colors["main_hilite"]."\"><td valign=\"top\">\n";
		echo "<span><b>日期:  </b>".encodeUTFSafeHTML($header->date)."<br></span>\n"; 
	echo "</td></tr>\n";
	echo "<tr bgcolor=\"".$my_colors["main_hilite"]."\"><td valign=\"top\">\n";
		echo "<span><b>寄件人:  </b>".LangDecodeAddressList($header->from,  $my_prefs["charset"], $user)."<br></span>\n";
	echo "</td></tr>\n";
	echo "<tr bgcolor=\"".$my_colors["main_hilite"]."\"><td valign=\"top\">\n";
		echo "<span><b>收件人: </b>".LangDecodeAddressList($header->to,  $my_prefs["charset"], $user)."<br></span>\n";
	echo "</td></tr>\n";
	if (!empty($header->cc)){
		echo "<tr bgcolor=\"".$my_colors["main_hilite"]."\"><td valign=\"top\">\n";
		echo "<span><b>CC: </b>".LangDecodeAddressList($header->cc,  $my_prefs["charset"], $user)."<br></span>\n";
		echo "</td></tr>\n";
	}
	if (!empty($header->replyto)){
		echo "<tr bgcolor=\"".$my_colors["main_hilite"]."\"><td valign=\"top\">\n";
		echo "<span><b>Reply-To:  </b>".LangDecodeAddressList($header->replyto,  $my_prefs["charset"], $user)."<br></span>\n";
		echo "</td></tr>\n";
	}
	echo "<tr bgcolor=\"".$my_colors["main_hilite"]."\"><td valign=\"top\">\n";
		echo "<span><a href='#mailcode'><b>HTML原始碼</b></a><br></span>\n";
	echo "</td></tr>\n";
/*	echo "<tr bgcolor=\"".$my_colors["main_hilite"]."\"><td valign=\"top\">\n";
		echo  "<b>大小: </b>".ShowBytes($header->size)."<br>\n";
	echo "</td></tr>\n";*/
	
	//show attachments/parts
/*	if ($num_parts > 0){
		echo "<tr bgcolor=\"".$my_colors["main_hilite"]."\"><td valign=\"top\">\n";
		echo "<b>".$rmStrings[6].": </b>\n";
		echo "<table size=100%><tr valign=top><tr>\n";
		//echo "<td valign=\"top\"><b>".$rmStrings[6].": </b>\n";
		echo "<td></td>\n";
		echo "<td valign=\"top\"><b>&nbsp;&nbsp;&nbsp;&nbsp;</b></td>\n";
		$icons_a = array("text.gif", "multi.gif", "multi.gif", "application.gif", "music.gif", "image.gif", "movie.gif", "unknown.gif");

		for ($i=1;$i<=$num_parts;$i++){
			//get attachment info
			if ($parent_type == 1)
				$code=$part.(empty($part)?"":".").$i;
			else if ($parent_type == 2){
				$code=$part.(empty($part)?"":".").$i;
				//echo implode(" ", iml_GetPartArray($structure, $code));
			}
				
			$type=iml_GetPartTypeCode($structure, $code);
			$name=iml_GetPartName($structure, $code);
			$typestring=iml_GetPartTypeString($structure,$code);
			list($dummy, $subtype) = explode("/", $typestring);
			$bytes=iml_GetPartSize($structure,$code);
			$encoding=iml_GetPartEncodingCode($structure, $code);
			$disposition = iml_GetPartDisposition($structure, $code);
		
			//format href
			if (($type == 1) || ($type==2) || (($type==3)&&(strcasecmp($subtype, "ms-tnef")==0))) $href = "read_message.php?user=$user&folder=$folder_url&id=$id&part=".$code;
			else $href = "view.php?user=$user&folder=$folder_url&id=$id&part=".$code;
			
			//show icon, file name, size
			echo "<td align=\"center\">";
			echo "<a href=\"".$href."\" ".(($type==1)||($type==2)||(($type==3)&&(strcasecmp($subtype, "ms-tnef")==0))?"":"target=_blank").">";
			echo "<img src=\"images/".$icons_a[$type]."\" border=0><br>";
			echo "<span class=\"small\">";
			if (is_string($name)) echo LangDecodeSubject($name, $my_charset);
			if ($bytes>0) echo "<br>[".ShowBytes($bytes)."]";
			if (is_string($typestring)) echo "<br>".$typestring;
			echo "</span>";
			echo "</a>";
			echo "</td>\n";
			if (($i % 4) == 0) echo "</tr><tr><td></td><td></td>";
		}
		echo "</tr>\n</table>\n";
		echo "</td></tr>\n";
	}
*/	
	//more header stuff (source/header links)
/*	echo "<tr bgcolor=\"".$my_colors["main_hilite"]."\"><td valign=\"top\" align=\"center\">\n";
	echo "<a href=\"view.php?user=$user&folder=$folder_url&id=$id&source=1\" target=\"_blank\">".$rmStrings[9]."</a>\n";
	echo "&nbsp;|&nbsp;<a href=\"view.php?user=$user&folder=$folder_url&id=$id&show_header=1\" target=\"_blank\">".$rmStrings[12]."</a>\n";
	echo "&nbsp;|&nbsp;<a href=\"view.php?user=$user&folder=$folder_url&id=$id&printer_friendly=1\" target=\"_blank\">".$rmStrings[16]."</a>\n";
	if ($report_spam_to){
		echo "&nbsp;|&nbsp;<a href=\"compose2.php?user=$user&folder=$folder_url&forward=1&id=$id&show_header=1&to=".urlencode($report_spam_to);
		echo "\" target=\"_blank\">".$rmStrings[13]."</a>\n";
	}
	if ($header->answered){
		echo "&nbsp;|&nbsp;".$rmStrings[15]."\n";
	}
	echo "</td></tr>\n";
*/

	echo "<tr bgcolor=\"".$my_colors["main_bg"]."\"><td>\n";
		
	echo "<table width=\"90%\" align=\"left\" border=\"0\" cellpadding=\"5\"><tr><td>\n";
	echo "\n<!-- BEGIN MESSAGE CELL //-->\n";
	
	/***** BEGIN READ MESSAGE HANDLER ****/
	
	//now include the handler that determines what to display and how	
	include("read_message_handler.inc");	
	/***** END READ MESSAGE HANDLER *****/
	echo "\n<!-- END MESSAGE CELL //-->\n";
	echo "<a name='mailcode'>";
	echo "<TEXTAREA NAME=message ROWS=20 COLS=130 WRAP=virtual>\n".encodeUTFSafeHTML($body)."</TEXTAREA>";
	echo "</td></tr></table>\n";
	
	echo "</td></tr></table>\n";
	echo "</td></tr></table>\n";

	//show toolbar
//	include("read_message_tools.inc");
fclose($fp);
?>
</BODY></HTML>
