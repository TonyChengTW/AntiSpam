<?
//執行sql，傳回一個欄位的資料
function SQL_GetResult($sql)  {
	global $conn,$db;
	if(!($res=mysql_db_query($db,$sql)))
	{
		echo mysql_error();
		exit;
	}
	
	$row = mysql_fetch_array($res);
	$result_field = $row[0];

	//mysql_close($conn);

	return $result_field;
}

//執行sql，傳回多筆資料
function SQL_GetResultFields($sql)  {
	global $conn,$db;
	if(!($res=mysql_db_query($db,$sql)))
	{
		echo mysql_error();
		exit;
	}
	
	$col = 0;
	while($field_obj = mysql_fetch_field($res)) {
		$field_arr[$col] = $field_obj->name;		
		$col++;
	}
	
	$record = 0;
	while($row = mysql_fetch_array($res)) {
		$col = 0;
		while(isset($row[$col])) {
			$result_fields[$record][$field_arr[$col]] = $row[$col];
			$result_fields[$record][$col] = $row[$col];
			
			$col++;
		}
		$record++;
	}

	//mysql_close($conn);

	return $result_fields;
}

//執行sql不傳回值
function SQL_ExecSQLs($sql)  {
	global $conn,$db;
	if(!($res=mysql_db_query($db,$sql)))
	{
		echo mysql_error();
		exit;
	}

	$affect_rows = mysql_affected_rows($conn);
	
	//mysql_close($conn);

	return $affect_rows;
}

//執行sql不傳回值
function SQL_ExecSQLsInsert($sql)  {
	global $conn,$db;
	if(!($res=mysql_db_query($db,$sql)))
	{
		echo mysql_error();
		exit;
	}

	//$affect_rows = mysql_affected_rows($conn);
	
	//mysql_close($conn);

	return mysql_insert_id();
}

function SQL_InsertId()  {
	global $conn;
	if(!($res=mysql_insert_id($conn)))
	{
		echo mysql_error();
		exit;
	}
	$result_field = $res;

	//mysql_close($conn);

	return $result_field;
}
?>
