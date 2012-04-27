<?php
/*
 * Userdata.php
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


require_once "SessionHandler.php";
require_once "config.php";

class Userdata extends SessionHandler
{
	private $data;
	
	function __construct($request) 
	{
		parent::__construct($request);
		
		$this->data = array();
	}
	

	protected function loadThemes()
	{
		$nodes = glob('./themes/*'); 
		foreach ($nodes as $node) 
		{ 
			if (@is_dir($node)) 
			{ 
				$themefile = $node . '/theme.php';
				if (@file_exists($themefile))
				{
					include_once $themefile;
				}
			} 
		}
		return $theme;
	}
	
	public function userExists($username)
	{
		try {
			$stmt = $this->dbh->prepare("SELECT username FROM t_user WHERE username = :username");
			$stmt->bindParam(':username', $username, PDO::PARAM_STR, strlen($username));
		    $stmt->execute();
	    	if ($stmt->fetchColumn()) {
				return true;
			} else {
				return false;
			}
		} catch (PDOException $e) {
			return false;
		}	
	}

	public function getUserdataForUsername($username)
	{
		try {
			$stmt = $this->dbh->prepare("SELECT * FROM t_user WHERE username = :username");
			$stmt->bindParam(':username', $username, PDO::PARAM_STR, strlen($username));
		    $stmt->execute();
			$result = $stmt->fetch(PDO::FETCH_ASSOC);
	    	if ($result) {
				$result['preferences'] = unserialize($result['preferences']);
				$result['exportSettings'] = unserialize($result['exportSettings']);
				return $result;
			} else {
				return false;
			}
		} catch (PDOException $e) {
			return false;
		}	
	}
	
	public function getUserdataForId($userid)
	{
		try {
			$stmt = $this->dbh->prepare("SELECT * FROM t_user WHERE id = :userid");
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
		    $stmt->execute();
			$result = $stmt->fetch(PDO::FETCH_ASSOC);
	    	if ($result) {
				$result['preferences'] = unserialize($result['preferences']);
				$result['exportSettings'] = unserialize($result['exportSettings']);
				return $result;
			} else {
				return false;
			}
		} catch (PDOException $e) {
			return false;
		}	
	}
	
	public function getUserdata()
	{
		try {
			$stmt = $this->dbh->prepare("SELECT * FROM t_user WHERE id = :id");
			$id = $this->getUserId();
			$stmt->bindParam(':id', $id, PDO::PARAM_INT);
		    $stmt->execute();
			$result = $stmt->fetch(PDO::FETCH_ASSOC);
	    	if ($result) {
				$result['preferences'] = unserialize($result['preferences']);
				$result['exportSettings'] = unserialize($result['exportSettings']);
				return $result;
			} else {
				return false;
			}
		} catch (PDOException $e) {
			return false;
		}	
	}
	
	public function savePreferences($username, $data)
	{
		
		try {
			$stmt = $this->dbh->prepare("UPDATE t_user SET preferences=:preferences WHERE (username=:username)");
			$stmt->bindParam(':username', $username, PDO::PARAM_STR, strlen($username));
			$stmt->bindParam(':preferences', serialize($data), PDO::PARAM_STR, strlen(serialize($data)));
	    	if ($stmt->execute()) {
				return true;
			} else {
				return false;
			}
		} catch (PDOException $e) {
			return false;
		}	
	}
	
	public function loadPreferences($username)
	{
		$theme = $this->loadThemes();
		$prefs = array();
		$export = array();
		
		try {
			
			$stmt = $this->dbh->prepare("SELECT * FROM t_user WHERE username = :username");
			$stmt->bindParam(':username', $username, PDO::PARAM_STR, strlen($username));
		    $stmt->execute();
			$result = $stmt->fetch(PDO::FETCH_ASSOC);
			
			//preferences
	    	if (strlen($result['preferences'])>0) {
				$found = unserialize($result['preferences']);
				$found['themes'] = $theme;
				$prefs = $found;
			} else {
				$prefs = array('themes' => $theme);
			}
			
			//export
			if (strlen($result['exportSettings'])>0) {
				$export = unserialize($result['exportSettings']);
			} else {
				$export = array();
			}
			return array('preferences' => $prefs, 'exportSettings' => $export);

		} catch (PDOException $e) {
			return null;
		}	
	}
	
	public function saveExportSettings($data)
	{
		try {
			$stmt = $this->dbh->prepare("UPDATE t_user SET exportSettings=:exportSettings WHERE (id=:id)");
			$user_id = $this->getUserId();
			$stmt->bindParam(':id', $user_id, PDO::PARAM_INT);
			$stmt->bindParam(':exportSettings', serialize($data), PDO::PARAM_STR, strlen(serialize($data)));
			if ($stmt->execute()) 
			{
				return true;
			} else {
				return false;
			}
		} catch (PDOException $e) {
			return false;
		}	
	}

	public function addUser($username, $firstname, $lastname, $password, $email, $organization,$phone,$data)
	{
		$auto_approval = "false";
		$enabled = 0;
		$confirmHash = md5(time());
		try {
			//check for auto approval
			
			$stmt = $this->dbh->prepare("SELECT * FROM t_settings WHERE(key = 'auto_approve')");
		    $stmt->execute();
			$approval = $stmt->fetchAll(PDO::FETCH_ASSOC);
			if ($approval[0]['value']=="true") {
				$auto_approval = false;
				$enabled = 1;
			}
			
			$stmt = $this->dbh->prepare("INSERT INTO t_user (confirmHash, enabled,username, firstname, lastname,password, email,organization,telephone,created) values (:confirmHash, :enabled,:username, :firstname, :lastname, :password, :email, :organization, :telephone, :created)");
			$stmt->bindParam(':username', $username, PDO::PARAM_STR, strlen($username));
			$stmt->bindParam(':firstname', $firstname, PDO::PARAM_STR, strlen($firstname));
			$stmt->bindParam(':lastname', $lastname, PDO::PARAM_STR, strlen($lastname));
			$stmt->bindParam(':password', md5($password), PDO::PARAM_STR, strlen(md5($password)));
			$stmt->bindParam(':email', $email, PDO::PARAM_STR, strlen($email));
			$stmt->bindParam(':organization', $organization, PDO::PARAM_STR, strlen($organization));
			$stmt->bindParam(':telephone', $phone, PDO::PARAM_STR, strlen($phone));
			$stmt->bindParam(':created', time(), PDO::PARAM_INT);
			$stmt->bindParam(':enabled', $enabled, PDO::PARAM_INT);
			$stmt->bindParam(':confirmHash', $confirmHash, PDO::PARAM_STR, strlen($confirmHash));
			
			if ($stmt->execute()) 
			{
				global $admin_mail;
				$last_insert_id = $this->lastInsertId();
				$this->savePreferences($username, $data);
				if ($enabled) {
					$subject = "MMSlides - New user registration";
					$body = "SignUp-Data:\n\n Name: $lastname, $firstname \n EMail: $email\n Username: $username \n Organization: $organization \n\n This user has been auto-approved.";
					mail($admin_mail, $subject, $body);
					return $last_insert_id;
				} else {
					global $_admin_web_root;
					$url = $_admin_web_root."/admin/index.php?action=approve&hash=$confirmHash";
					$subject = "MMSlides - New user / Approval needed";
					$body = "SignUp-Data:\n\n Name: $lastname, $firstname \n EMail: $email\n Username: $username \n Organization: $organization\n\n Please click the following link to approve the user: $url";
					mail($admin_mail, $subject, $body);
					return "approval needed";
				}
			} 
			else 
			{
				return false;
			}
		} catch (PDOException $e) {
			return false;
		}	
	}
	
	public function checkLogin($username, $password)
	{
		$userdata = $this->getUserdataForUsername($username);
//		return $userdata;
		if ($userdata !== false)
		{
			if (strcmp($userdata['password'], md5($password)) == 0)
			{
				return $userdata;
			}
		}
		return false;
	}
	
	public function getLostPasswordDataForSession($session)
	{
		if (strlen($session) == 0) return false;
		try 
		{
			$stmt = $this->dbh->prepare("SELECT * FROM t_user WHERE lostpassword = :lostpassword");
			$stmt->bindParam(':lostpassword', $session, PDO::PARAM_STR, strlen($session));
			$stmt->execute();

			$result = $stmt->fetch(PDO::FETCH_ASSOC);
			if (is_array($result))
			{
				$this->removeLostPasswordSession($session);
				return $result;
			}
			else
			{
				return false;
			}
			return $found;
		} 
		catch (PDOException $e) 
		{
			return false;
		}	
	}
	
	public function lostPasswordForUserWithEmail($email, $url, $subject, $body)
	{
		try {
			
			$stmt = $this->dbh->prepare("SELECT * FROM t_user WHERE email = :email");
			$stmt->bindParam(':email', $email, PDO::PARAM_STR, strlen($email));
			$stmt->execute();

			$found = false;
			while ($result = $stmt->fetch(PDO::FETCH_ASSOC))
			{
				$username = $result['username'];
				$session = $this->addLostPasswordSession($result['id']);
				if ($session !== false)
				{
					$body = sprintf($body, $username, "$url?lostpassword=$session");
					if (mail($email, $subject, $body)) 
					{
						$found = true;
					} else {
						$found = false;
					}
				}
			}
			return $found;
		} 
		catch (PDOException $e) 
		{
			return false;
		}	
	}

	public function changePassword($user_id, $password)
	{
		try {
			$stmt = $this->dbh->prepare("UPDATE t_user SET password=:password WHERE (id=:id)");
			$session = uniqid();
			$stmt->bindParam(':password', md5($password), PDO::PARAM_STR, strlen(md5($password)));
			$stmt->bindParam(':id', $user_id, PDO::PARAM_INT);
			if ($stmt->execute()) 
			{
				return true;
			} 
			else 
			{
				return false;
			}
		} catch (PDOException $e) 
		{
			return false;
		}	
	}

	protected function addLostPasswordSession($user_id)
	{
		try {
			$stmt = $this->dbh->prepare("UPDATE t_user SET lostpassword=:lostpassword WHERE (id=:id)");
			$session = uniqid();
			$stmt->bindParam(':lostpassword', $session, PDO::PARAM_STR, strlen($session));
			$stmt->bindParam(':id', $user_id, PDO::PARAM_INT);
			if ($stmt->execute()) 
			{
				return $session;
			} 
			else 
			{
				return false;
			}
		} catch (PDOException $e) 
		{
			return false;
		}	
	}

	protected function removeLostPasswordSession($session)
	{
		try {
			$stmt = $this->dbh->prepare("UPDATE t_user SET lostpassword=:empty WHERE (lostpassword=:lostpassword)");
			$empty = "";
			$stmt->bindParam(':empty', $empty, PDO::PARAM_STR, 0);
			$stmt->bindParam(':lostpassword', $session, PDO::PARAM_STR, strlen($session));
			if ($stmt->execute()) 
			{
				return true;
			} 
			else 
			{
				return false;
			}
		} catch (PDOException $e) 
		{
			return false;
		}	
	}
}

?>