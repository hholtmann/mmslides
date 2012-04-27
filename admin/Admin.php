<?php
/*
 * Admin.php
 * 
 * Copyright (c) 2012 Hendrik Holtmann
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */


require_once("smarty.inc.php");

if (file_exists("../server/config.php"))
{
	require_once("../server/config.php");
}

class Admin {
	
	private $smartyObj;
	protected $sql;
	protected $dbh;
	
	
	function __construct() 
	{
		global $smarty;
		$this->smartyObj = $smarty;
		if (file_exists("../server/config.php"))
		{
			global $db_path;
			global $project_webroot;
			global $admin_mail;
			$this->projectpath = $project_webroot;
			$this->admin_mail = $admin_mail;
			if (file_exists($db_path)) {
				$this->dbh = new PDO('sqlite:'.$db_path);
			} else {
				$this->dbh = new PDO('sqlite:'.$db_path);
				$schema = file_get_contents("../server/dbschema.sql");
				$this->dbh->exec($schema);	
			}
		}
	}
	
	public function checkLogin() {
		if (file_get_contents( dirname(__FILE__)."/.hash") == $_SESSION['login']) {
			return true;
		} else {
			return false;
		}
	}
	
	public function logout() {
		$_SESSION['login'] = null;
	}
	
	public function approveAccount($errors = "", $readpost = false) {
		global $_admin_web_root;
		$confirmHash = $_GET["hash"];
		try {	
				$stmt = $this->dbh->prepare("UPDATE t_user SET enabled=1 WHERE(confirmHash = :confirmHash)");
				$stmt->bindParam(':confirmHash', $confirmHash, PDO::PARAM_STR,strlen($confirmHash));
			   	$stmt->execute();
			
				$stmt = $this->dbh->prepare("SELECT * FROM t_user WHERE(confirmHash = :confirmHash)");
				$stmt->bindParam(':confirmHash', $confirmHash, PDO::PARAM_STR,strlen($confirmHash));
			    $stmt->execute();
				$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
				$email = $result[0]['email'];
				$username = $result[0]['username'];
				
				$url = $_admin_web_root;
				$subject = "MMSlides - Account confirmed.";
				$body = "Your account with the username $username has been confirmed. Login to MMSlides at $url.";
				mail($email, $subject, $body);
				$this->smartyObj->assign("username",$username);
				$this->smartyObj->display('confirm.tpl');
				//get data
			}	catch (PDOException $e) {
				error_log("PDO-Exception: ".$e);
				return false;
			}
	}
	
	public function showFiles($id=0,$errors = "", $readpost = false) {
		$result = null;
		$configured = file_exists("../server/config.php");
		$this->smartyObj->assign("configured",$configured);
		try {	
				$stmt = $this->dbh->prepare("SELECT * FROM t_project WHERE(id = :id)");
				$stmt->bindParam(':id', $id, PDO::PARAM_INT);
			    $stmt->execute();
				$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
				$this->smartyObj->assign("result",$result);
				$data = unserialize($result[0]['data']);
				$this->smartyObj->assign("slides",$data['slides']);				
			} catch (PDOException $e) {
				error_log("PDO-Exception: ".$e);
				return false;
			}
		$this->smartyObj->display('files.tpl');
	}
	
	public function showProjects($errors = "", $readpost = false) {
		$result = null;
		$configured = file_exists("../server/config.php");
		$this->smartyObj->assign("configured",$configured);
		try {	
				$stmt = $this->dbh->prepare("SELECT *,datetime(lastchange, 'unixepoch') AS last,t_project.id AS projectid FROM t_project,t_user WHERE(t_project.userid=t_user.id)");
				$stmt->execute();
				$result = $stmt->fetchAll(PDO::FETCH_ASSOC);	
				$this->smartyObj->assign("result",$result);
			} catch (PDOException $e) {
				error_log("PDO-Exception: ".$e);
				return false;
			}
		$this->smartyObj->display('project.tpl');
	}
	
	function deleteDirectory($dir) 
	{
		if (!file_exists($dir)) return true;
		if (!is_dir($dir)) return unlink($dir);
		foreach (scandir($dir) as $item) 
		{
			if ($item == '.' || $item == '..') continue;
			if (!$this->deleteDirectory($dir.DIRECTORY_SEPARATOR.$item)) return false;
		}
		return rmdir($dir);
	}
	
	public function deleteProject($id = 0,$errors = "", $readpost = false)
	{
		try {	
				$stmt = $this->dbh->prepare("SELECT * FROM t_project WHERE (t_project.id=:projectid)");
				$stmt->bindParam(':projectid', $id, PDO::PARAM_INT);
				$stmt->execute();
				$result = $stmt->fetch(PDO::FETCH_ASSOC);
				$filepath = $this->projectpath . $result['path'];
				if ($result['path']!="") {
					$this->deleteDirectory($filepath);
				}
				$stmt = $this->dbh->prepare("DELETE FROM t_project WHERE(id=:id)");
				$stmt->bindParam(':id', $id, PDO::PARAM_INT);
				$stmt->execute();
				$this->showProjects();
			} catch (PDOException $e) {
				error_log("PDO-Exception: ".$e);
				$this->showProjects();
				return false;
			}
	}
	
	public function deleteUser($id = 0,$errors = "", $readpost = false)
	{
		try {	
				$stmt = $this->dbh->prepare("DELETE FROM t_user WHERE(id=:id)");
				$stmt->bindParam(':id', $id, PDO::PARAM_INT);
				$stmt->execute();
				$this->showUser();
			} catch (PDOException $e) {
				error_log("PDO-Exception: ".$e);
				$this->showUser();
				return false;
			}
	}

	public function editUser($id = 0,$errors = "", $readpost = false) {
		$result = null;
		$configured = file_exists("../server/config.php");
		$this->smartyObj->assign("configured",$configured);
		$stmt = $this->dbh->prepare("SELECT * FROM t_user WHERE (id=:id)");
		$stmt->bindParam(':id', $id, PDO::PARAM_INT);
		$stmt->execute();
		$result = $stmt->fetch(PDO::FETCH_ASSOC);
		$this->smartyObj->assign("username",$result['username']);
		$this->smartyObj->assign("firstname",$result['firstname']);
		$this->smartyObj->assign("lastname",$result['lastname']);
		$this->smartyObj->assign("email",$result['email']);
		$this->smartyObj->assign("telephone",$result['telephone']);
		$this->smartyObj->assign("organization",$result['organization']);
		$this->smartyObj->assign("userid",$result['id']);
		$this->smartyObj->assign("errors",$errors);
		
		if ($result['enabled']==1) {
			$this->smartyObj->assign("approved","checked");
		}
		$this->smartyObj->display('userform.tpl');
	}

	public function updateUser($id =0, $errors = "", $readpost = false) {
		$errormsg = "";
		
		$firstname = $_POST["firstname"];
		$lastname = $_POST["lastname"];
		$email = $_POST["email"];
		$organization = $_POST["organization"];
		$telephone = $_POST["telephone"];
		$approved = $_POST["approved"];
		$enabled = 0;
		
		if ($firstname == "") {
			$errormsg = $errormsg."Firstname required.<br/>";
		}
		if ($lastname == "") {
			$errormsg = $errormsg."Lastname required.<br/>";
		}
		if ($email == "") {
			$errormsg = $errormsg."Email required.<br/>";
		}
		
		if ($approved == "ON") {
			$enabled = 1;
		}
		
		if ($errormsg!="") {
			$this->editUser($id,$errormsg);
		} else {
			$stmt = $this->dbh->prepare("UPDATE t_user SET enabled=:enabled,firstname=:firstname,lastname=:lastname,email=:email,telephone=:telephone,organization=:organization WHERE(id=:id)");
			$stmt->bindParam(':id', $id, PDO::PARAM_INT);
			$stmt->bindParam(':enabled', $enabled, PDO::PARAM_INT);
			$stmt->bindParam(':firstname', $firstname, PDO::PARAM_STR,strlen($firstname));
			$stmt->bindParam(':lastname', $lastname, PDO::PARAM_STR,strlen($lastname));
			$stmt->bindParam(':email', $email, PDO::PARAM_STR,strlen($email));
			$stmt->bindParam(':telephone', $telephone, PDO::PARAM_STR,strlen($telephone));
			$stmt->bindParam(':organization', $organization, PDO::PARAM_STR,strlen($organization));
			
		    $stmt->execute();
			$this->showUser();
		}
		
	}
		
	public function showUser($errors = "", $readpost = false) {
		$result = null;
		$configured = file_exists("../server/config.php");
		$this->smartyObj->assign("configured",$configured);
		try {	
				$stmt = $this->dbh->prepare("SELECT *,datetime(created, 'unixepoch') AS registerd FROM t_user");
				$stmt->execute();
				$result = $stmt->fetchAll(PDO::FETCH_ASSOC);	
				$this->smartyObj->assign("result",$result);
			} catch (PDOException $e) {
				error_log("PDO-Exception: ".$e);
				return false;
			}
		$this->smartyObj->display('user.tpl');
	}
	
	public function exportUsers($errors = "", $readpost = false) {
		$result = null;
		$configured = file_exists("../server/config.php");
		try {	
				$stmt = $this->dbh->prepare("SELECT username,firstname,lastname,email,organization,telephone
				 FROM t_user");
				$stmt->execute();
				$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
				$fileName = 'allUsers_mmslides.csv';
				header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
				header('Content-Description: File Transfer');
				header("Content-type: text/csv");
				header("Content-Disposition: attachment; filename={$fileName}");
				header("Expires: 0");
				header("Pragma: public");
				$fh = @fopen( 'php://output', 'w' );	
				$headerDisplayed = false;
				foreach ( $result as $data ) {
				    if ( !$headerDisplayed ) {
				        fputcsv($fh, array_keys($data));
				        $headerDisplayed = true;
				    }

				    fputcsv($fh, $data);
				}
				fclose($fh);
				exit;
			} catch (PDOException $e) {
				error_log("PDO-Exception: ".$e);
				return false;
			}
	}
	
	public function updateGeneral($errors = "", $readpost = false) {
		$auto_approve = $_POST["auto_approve"];
		try {	
			$value = "false";
			if ($auto_approve == "ON") {
				$value = "true";
			}
			$stmt = $this->dbh->prepare("UPDATE t_settings SET value=:value WHERE(key='auto_approve')");
			$stmt->bindParam(':value', $value, PDO::PARAM_STR,strlen($value));
		    $stmt->execute();
			$this->showAdmin();
		} catch (PDOException $e) {
			error_log("PDO-Exception: ".$e);
			$this->showAdmin();
			return false;
		}
	}
	
	public function showAdmin($errors = "", $readpost = false) {
		$configured = file_exists("../server/config.php");
		$this->smartyObj->assign("configured",$configured);
		$this->smartyObj->assign("admin_mail",$this->admin_mail);
		try {	
				$stmt = $this->dbh->prepare("SELECT Count(*) FROM t_project");
			    $stmt->execute();
				$cproject = $stmt->fetchColumn();
				$this->smartyObj->assign("cproject",$cproject);
				
				$stmt = $this->dbh->prepare("SELECT Count(*) FROM t_user");
			    $stmt->execute();
				$cuser = $stmt->fetchColumn();
				$this->smartyObj->assign("cuser",$cuser);
				
				$stmt = $this->dbh->prepare("SELECT * FROM t_settings WHERE(key = 'auto_approve')");
			    $stmt->execute();
				$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
				if ($result[0]['value']=="true") {
					$this->smartyObj->assign("auto_approve","checked");
				}
			} catch (PDOException $e) {
				error_log("PDO-Exception: ".$e);
				return false;
			}
		$this->smartyObj->display('admin.tpl');
	}
	
	private function checkPath($path,$file = false,$title = "") {
		if ($path == "") {
			return "$title can't be empty.<br/>";
		}
		if (file_exists($path)) {
			if (is_writable($path) || $file == true) {
				return "";
			} else {
				return "Path: $path is not writeable. <br/>";
			}
		} else {
			if ($file) {
				return "File: ".$path." does not not exist. <br/>";
			} else {
				return "Path: ".$path." does not not exist. <br/>";
			}
		}
	}
	
	public function updateConfig() {
		//get all variables
		$webroot = $_POST["webroot"];
		$installroot = $_POST["installroot"];
		$datapath = $_POST["datapath"];
		$ffmpeg_path = $_POST["ffmpeg_path"];
		$lame_path = $_POST["lame_path"];
		$admin_mail = $_POST["admin_mail"];
		$convert_path = $_POST["convert_path"];
		$movie_exports = $_POST["movie_exports"];
		
		$errormsg = $errormsg.$this->checkPath($installroot,false,"Install-Root");
		$errormsg = $errormsg.$this->checkPath($datapath,false,"Data-Path");
		$errormsg = $errormsg.$this->checkPath($ffmpeg_path,true,"ffmpeg-Path");
		$errormsg = $errormsg.$this->checkPath($lame_path,true,"Lame-Path");
		$errormsg = $errormsg.$this->checkPath($convert_path,true,"Convert-Path");

		if ($webroot == "") {
			$errormsg = $errormsg."Valid Web-Root required.<br/>";
		}

		
		if ($admin_mail == "") {
			$errormsg = $errormsg."Valid admin mail required.<br/>";
		}
		
		if ($errormsg == "") {
			
			$moviequeue = $datapath."/"."moviequeue";
			$moviedir = $installroot."/server/"."moviecreator";
			mkdir($moviequeue);
			mkdir($moviedir);
			
			//save config
			$php_cfg = "<?php\n";
			$php_cfg .= '$admin_mail = \''.$admin_mail."';\n";
			$php_cfg .= '$project_webroot = \''.$installroot."/server/"."';\n";
			$php_cfg .= '$db_path = \''.$datapath."/mmslide.sqlite"."';\n";
			$php_cfg .= '$lame_path = \''.$lame_path."';\n";
			$php_cfg .= '$ffmpeg_path = \''.$ffmpeg_path."';\n";
			$php_cfg .= '$movie_queue = \''.$moviequeue."';\n";
			$php_cfg .= '$movie_dir = \''.$moviedir."/';\n";
			$php_cfg .= '$_admin_web_root = \''.$webroot."';\n";
			$php_cfg .= '$_admin_install_root = \''.$installroot."';\n";
			$php_cfg .= '$_admin_data_path = \''.$datapath."';\n";
			$php_cfg .= '$_admin_convert_path = \''.$convert_path."';\n";
			$php_cfg .= "?>\n";
			file_put_contents("../server/config.php",$php_cfg);
			
			//save plist file
			
			$server_webroot = $webroot."/server/";
			$publish_folder = $installroot."/publish";
			mkdir($publish_folder);
			mkdir($server_webroot."/projects");
			$publish_url = $webroot."/publish/";

			$movie = 0;
			
			if ($movie_exports == "ON") {
				$movie = 1;
			}
			
			$plist_cfg = '<?xml version="1.0" encoding="UTF-8"?>
			<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
			<plist version="1.0">';
			
			$plist_cfg .= "<dict>
				<key>Main cib file base name</key>
				<string>MainMenu.cib</string>
				<key>CPBundleName</key>
				<string>mmslide</string>
				<key>CPBundleLocale</key>
				<string>en</string>
				<key>CPPrincipalClass</key>
				<string>CPApplication</string>
				<key>WebRoot</key>
				<string>$server_webroot</string>
				<key>PublishFTP</key>
				<integer>0</integer>
				<key>PublishFolder</key>
				<string>$publish_folder</string>
				<key>PublishURL</key>
				<string>$publish_url</string>
				<key>MovieExport</key>
				<integer>$movie</integer>
			</dict>
			</plist>";
			
			file_put_contents("../author/Info.plist",$plist_cfg);
			
			$m_server_dir =  $webroot."/server/moviecreator";
			$m_queue_dir = $datapath."/"."moviequeue";
			$m_movie_dir = $installroot."/server/moviecreator";
			$m_convert = dirname($convert_path);
			$m_downloader =  $webroot."/server/moviedownload.php";
			
			$java_cfg = "
server.dir = $m_server_dir
queue.dir = $m_queue_dir
movie.dir = $m_movie_dir
im.path = $m_convert
moviedownloader = $m_downloader
ffmpeg.app = $ffmpeg_path
mail.from = mmslides@example.com
mail.smtp.host = localhost";
			
			file_put_contents("../server/MovieCreator.config",$java_cfg);
			
			
			$this->showMain("Settings saved",false);
		} else {
			$this->showMain($errormsg,true);
		}
	}
	
	public function showMain($errors = "", $readpost = false) {
		
		global $_admin_web_root;
		global $_admin_install_root;
		global $_admin_data_path;
		global $ffmpeg_path;
		global $lame_path;
		global $admin_mail;
		global $_admin_convert_path;
		
		
		if ($readpost == false) {
			
			$webroot = dirname(dirname("http://".$_SERVER['HTTP_HOST'].$_SERVER[PHP_SELF]));
			$installroot =  dirname(dirname(__FILE__));
			$datapath = "/opt/mmslide";
			$_lame_path = "/usr/local/bin/lame";
			$_ffmpeg_path = "/usr/local/bin/ffmpeg";
			$_admin_mail = "test@test.de";
			$convert_path = "/usr/local/bin/convert";
			$movie_exports = "checked";
		
			if (file_exists("../server/config.php")) {
				require_once("../server/config.php");
				$webroot = $_admin_web_root;
				$installroot = $_admin_install_root;
				$data_path = $_admin_data_path;
				$_lame_path = $lame_path;
				$_ffmpeg_path = $ffmpeg_path;
				$_admin_mail = $admin_mail;
				$convert_path = $_admin_convert_path;
			}
			if (file_exists("../author/Info.plist")) {
				$plist = new CFPropertyList( "../author/Info.plist", CFPropertyList::FORMAT_XML );
				$plistArray = $plist->toArray();
				if ($plistArray["MovieExport"] == 0) {
					$movie_exports = "";		
				}
		
			}
		} else {
			$webroot = $_POST["webroot"];
			$installroot = $_POST["installroot"];
			$datapath = $_POST["datapath"];
			$_ffmpeg_path = $_POST["ffmpeg_path"];
			$_lame_path = $_POST["lame_path"];
			$_admin_mail = $_POST["admin_mail"];
			$convert_path = $_POST["convert_path"];
			if ($_POST["movie_exports"] == "ON") {
				$movie_exports = "checked"; 
			} else {
				$movie_exports = ""; 
			}
		}
		
		$configured = file_exists("../server/config.php");
		$this->smartyObj->assign("configured",$configured);
		
		$this->smartyObj->assign("webroot",$webroot);
		$this->smartyObj->assign("installroot",$installroot);
		$this->smartyObj->assign("datapath",$data_path);
		$this->smartyObj->assign("ffmpeg_path",$_ffmpeg_path);
		$this->smartyObj->assign("lame_path",$_lame_path);
		$this->smartyObj->assign("admin_mail",$_admin_mail);
		$this->smartyObj->assign("convert_path",$convert_path);
		$this->smartyObj->assign("movie_exports",$movie_exports);
		$this->smartyObj->assign("errors",$errors);
		
		$this->smartyObj->display('main.tpl');
	}
	
	public function showLogin($errormsg = "") { 
		$this->smartyObj->assign("errormsg",$errormsg);			
		
		if (file_exists( dirname(__FILE__)."/.hash")) {
			$this->smartyObj->assign("adminpw",true);
		} else {
			$this->smartyObj->assign("adminpw",false);			
		}
		$this->smartyObj->display('login.tpl');
	}
	
	public function changePassword($errors = "", $readpost = false)
	{
		$configured = file_exists("../server/config.php");
		$this->smartyObj->assign("configured",$configured);
		$this->smartyObj->assign("errors",$errors);
		$this->smartyObj->display('changepw.tpl');	
	}
	
	public function showAgreement($errors = "", $readpost = false)
	{
		$stmt = $this->dbh->prepare("SELECT * FROM t_settings WHERE(key = 'user_agreement')");
	    $stmt->execute();
		$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
		$this->smartyObj->assign("agreement",$result[0]['value']);
		if ($errors == "saved") {
			$this->smartyObj->assign("message","Agreement changed");
		}
		$this->smartyObj->display('agreement.tpl');	
	}
	
	public function changeAgreement($errors = "", $readpost = false)
	{
		error_log("changing");
		$stmt = $this->dbh->prepare("UPDATE t_settings SET value=:newtext WHERE(key = 'user_agreement')");
		$stmt->bindParam(':newtext', $_POST["agreement"] , PDO::PARAM_STR,strlen($_POST["agreement"] ));
	   	$stmt->execute();
		$this->showAgreement('saved');
	}
	
	public function updatePassword() {
		if ($_POST["password1"] != "" && $_POST["password2"] != "" &&  $_POST["password1"] == $_POST["password2"] && strlen($_POST["password1"])>=6) {
			$pwhash = md5($_POST["password1"]);
			file_put_contents( dirname(__FILE__)."/.hash",$pwhash);
			$_SESSION['login'] = file_get_contents( dirname(__FILE__)."/.hash");
			$this->showAdmin();
		} else {
			$this->changePassword("Passwords have to match and need to be at lest 6 characters long.");
		}
	}
	
	public function createUser() {
		if ($_POST["password1"] != "" && $_POST["password2"] != "" &&  $_POST["password1"] == $_POST["password2"] && strlen($_POST["password1"])>=6) {
			$pwhash = md5($_POST["password1"]);
			file_put_contents( dirname(__FILE__)."/.hash",$pwhash);
			$_SESSION['login'] = file_get_contents( dirname(__FILE__)."/.hash");
			$this->showMain();
		} else {
			$this->showLogin("Passwords have to match and need to be at lest 6 characters long.");
		}
	}
	
	public function loginUser() {
		if (file_get_contents( dirname(__FILE__)."/.hash") == md5($_POST["password"])) {
			$_SESSION['login'] = file_get_contents( dirname(__FILE__)."/.hash");
			$configured = file_exists("../server/config.php");
			if ($configured) {
				$this->showAdmin();
			} else {
				$this->showMain();
			}
		} else {
			$this->showLogin("Wrong Password");
		}
	} 
}

?>