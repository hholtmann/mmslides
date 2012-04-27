<?php

require_once "config.php";

class SqliteProvider
{
	var $dbh;
	
	function __construct() 
	{
		global $db_path;
				
		if (!file_exists($db_path)) {
			$this->initDatabase();
		} else {
			$this->dbh = new PDO('sqlite:'.$db_path);
		}
	}
	
	private function initDatabase()
	{
		global $db_path;		
		$this->dbh = new PDO('sqlite:'.$db_path);
		$schema = file_get_contents("./dbschema.sql");
		$this->dbh->exec($schema);	
	}
	
}

?>