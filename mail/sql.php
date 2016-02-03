<?
include("spam.db");
include("sqlFunction.php");

function selectSpam(){
	global $account;
	$sql = "SELECT * FROM `spam` WHERE `account` = '$account' ";
	$result = SQL_GetResultFields($sql);
	return $result;
}
?>
