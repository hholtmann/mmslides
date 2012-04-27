<?php
/*
 * user.php
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

if ($userdata->getUserId() === false)
{
	header("HTTP/1.1 403 Forbidden");
	header("Content-Type: text/html" );
	$data = array('error' => 'Invalid credentials');
	echo json_encode($data);
	exit;
}

$ok = false;
if (strlen($request['cmd']) && strlen($request['username']))
{
	if (strcmp($request['cmd'], 'savePreferences') == 0)
	{
		if (!$userdata->userExists($request['username']))
		{
			header("HTTP/1.1 403 Forbidden");
			header("Content-Type: text/html" );
			print "User does not exist\r\n";
			exit;
		}
		else
		{
			$res = $userdata->savePreferences($request['username'], $request['data']);
			if ($res)
			{
				header("HTTP/1.1 200 OK");
				header("Content-Type: text/html" );
				echo json_encode($data);
				exit;
			}
		}
	}
	else if (strcmp($request['cmd'], 'loadPreferences') == 0)
	{
		if (!$userdata->userExists($request['username']))
		{
			header("HTTP/1.1 403 Forbidden");
			header("Content-Type: text/html" );
			print "User does not exist\r\n";
			exit;
		}
		else
		{
			$data = $userdata->loadPreferences($request['username']);
			if (is_array($data))
			{
				header("HTTP/1.1 200 OK");
				header("Content-Type: text/html" );
				echo json_encode($data);
				exit;
			}
		}
	}
	else if (strcmp($request['cmd'], 'loadExportSettings') == 0)
	{
		if (!$userdata->userExists($request['username']))
		{
			header("HTTP/1.1 403 Forbidden");
			header("Content-Type: text/html" );
			print "User does not exist\r\n";
			exit;
		}
		else
		{
			$data = $userdata->loadExportSettings($request['username']);
			if (is_array($data))
			{
				header("HTTP/1.1 200 OK");
				header("Content-Type: text/html" );
				echo json_encode($data);
				exit;
			}
		}
	}
}


header("HTTP/1.1 404 Not Found");
header("Content-Type: text/html" );
print "unknown command\r\n";
exit;

?>