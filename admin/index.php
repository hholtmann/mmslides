<?php

/*
 * index.php
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


	require_once("Admin.php");

	session_start();
	
	$installDir = dirname(__FILE__);
	if (!is_writable($installDir)) {
		echo "InstallDir: $installDir needs to be writeable by the webserver";
		exit;
	}
	$admin = new Admin();
	
	//approve
	if ($_GET["action"]=="approve") {
		$admin->approveAccount();			
		exit;
	}
		
	//not logged in
	if (!(isset($_SESSION['login']) && $_SESSION['login'] != '')) {	
		if ($_POST["action"] == "") {
			$admin->showLogin();
		} else if ($_POST["action"] == "login") {
			$admin->loginUser();
		} else if ($_POST["action"] == "newpassword") {
			$admin->createUser();			
		}
		//user logged in
	} else {
		if ($_POST['action'] == "updateconfig") {
			$admin->updateConfig();
			exit;
		}
		
		if ($_GET["action"]=="logout") {
			$admin->logout();			
		}
		$auth = $admin->checkLogin();
		
		if ( $auth== true && $_POST['action'] == "updategeneral") {
			$admin->updateGeneral();
			exit;
		}
		
		if ( $auth== true && $_POST['action'] == "updateuser") {
			$admin->updateUser($_POST["id"]);
			exit;
		}
		
		if ( $auth== true && $_POST['action'] == "updatepassword") {
				$admin->updatepassword();
				exit;
		}
		
		if ($auth==true && $_POST["action"]=="updateagreement") {
			$admin->changeAgreement();
			exit;
		}
		
		if ($auth== true && $_GET["action"]=="" ||  $_GET["action"]=="setup") {
			$admin->showMain();
		} elseif ($auth==true && $_GET["action"]=="admin") {
			$admin->showAdmin();
		} elseif ($auth==true && $_GET["action"]=="user") {
			$admin->showUser();
		} elseif ($auth==true && $_GET["action"]=="projects") {
			$admin->showProjects();
		} elseif ($auth==true && $_GET["action"]=="exportusers") {
			$admin->exportUsers();
		} elseif ($auth==true && $_GET["action"]=="files") {
			$admin->showFiles($_GET["id"]);
		} elseif ($auth==true && $_GET["action"]=="deleteuser") {
			$admin->deleteUser($_GET["id"]);
		} elseif ($auth==true && $_GET["action"]=="deleteproject") {
			$admin->deleteProject($_GET["id"]);
		} elseif ($auth==true && $_GET["action"]=="edituser") {
			$admin->editUser($_GET["id"]);
		} elseif ($auth==true && $_GET["action"]=="changepassword") {
			$admin->changePassword();
		} elseif ($auth==true && $_GET["action"]=="agreement") {
			$admin->showAgreement();
		} 	else {
			$admin->showLogin();
		}
	}
	
	
?>