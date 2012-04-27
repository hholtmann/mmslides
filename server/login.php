<?php
/*
 * login.php
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


require_once 'http_request.php';
require_once 'Userdata.php';

$http_request = new http_request();
$request = json_decode($http_request->body, true);
$userdata = new Userdata($request);

$ok = false;
if (strcmp($request['cmd'], 'lostpassword') == 0)
{
	if (!$userdata->lostPasswordForUserWithEmail($request['email'], $request['url'], $request['subject'], $request['body']))
	{
		header("HTTP/1.1 200 OK");
		header("Content-Type: text/html" );
		$data = array('error' => 12);
		echo json_encode($data);
		$ok = true;
	}
	else
	{
		header("HTTP/1.1 200 OK");
		header("Content-Type: text/html" );
		$data = array('success' => 1);
		echo json_encode($data);
		$ok = true;
	}
}
else if (strcmp($request['cmd'], 'checkLostPassword') == 0)
{
	if ($data = $userdata->getLostPasswordDataForSession($request['session']))
	{
		header("HTTP/1.1 200 OK");
		header("Content-Type: text/html" );
		echo json_encode($data);
		$ok = true;
	}
	else
	{
		header("HTTP/1.1 200 OK");
		header("Content-Type: text/html" );
		$data = array('error' => 1);
		echo json_encode($data);
		$ok = true;
	}
}
else if (strcmp($request['cmd'], 'changePassword') == 0)
{
	if (strlen($request["id"]) && strlen($request["password"]))
	{
		if ($data = $userdata->changePassword($request['id'], $request['password']))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			$data = array('success' => 1);
			echo json_encode($data);
			$ok = true;
		}
		else
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			$data = array('error' => 2);
			echo json_encode($data);
			$ok = true;
		}
	}
}
if (strlen($request["username"]) && strlen($request["password"]) && strlen($request['cmd']))
{
	if (strcmp($request['cmd'], 'login') == 0)
	{
		if ($found = $userdata->checkLogin($request['username'], $request['password']))
		{
			if ($found['enabled'] == 1) {
				$_SESSION['username'] = $request["username"];
				$_SESSION['id'] = $found['id'];
				unset($_SESSION['project_id']);
				header("HTTP/1.1 200 OK");
				header("Content-Type: text/html" );
				$data = array('username' => $request["username"], 'SID' => session_id(),"mail"=>$found['email']);
				echo json_encode($data);
				$ok = true;
			} else {
				header("HTTP/1.1 200 OK");
				header("Content-Type: text/html" );
				$data = array('disabled' => 11);
				echo json_encode($data);
		       	$ok = true;	
			}
		}
		else
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			$data = array('error' => 5);
			echo json_encode($data);
			$ok = true;
		}
	}
	else if (strcmp($request['cmd'], 'register') == 0)
	{
		if ($userdata->userExists($request['username']))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			$data = array('error' => 10);
			echo json_encode($data);
			$ok = true;
		}
		else if ($res = $userdata->addUser($request['username'], $request['firstname'], $request['lastname'],$request['password'], $request['email'],$request['organization'],$request['phone'],$request['data']))
		{
			if ($res == "approval needed") {
				header("HTTP/1.1 200 OK");
				header("Content-Type: text/html" );
				$data = array('pending' => 11);
				echo json_encode($data);
				$ok = true;
			}  else {
				$_SESSION['username'] = $request["username"];
				$_SESSION['id'] = $res;
				unset($_SESSION['project_id']);
				header("HTTP/1.1 200 OK");
				header("Content-Type: text/html" );
				$data = array('username' => $request["username"], 'SID' => session_id());
				echo json_encode($data);
				$ok = true;
			}
		}
		else
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			$data = array('error' => 11);
			echo json_encode($data);
			$ok = true;
		}
	}
}
if (!$ok)
{
	header("HTTP/1.1 403 Forbidden");
	header("Content-Type: text/html" );
	print "not found\r\n";
}

exit;

?>