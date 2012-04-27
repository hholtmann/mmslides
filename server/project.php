<?php
/*
 * project.php
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
require_once 'Projects.php';

$http_request = new http_request();
$request = json_decode($http_request->body, true);
$projects = new Projects($request);
$ok = false;

if ($_GET['rebuildAllImages'] == 42)
{
	$projects->rebuildImages();
}

if ($projects->getUserId() === false)
{
	header("HTTP/1.1 403 Forbidden");
	header("Content-Type: text/html" );
	$data = array('error' => 'Invalid credentials');
	echo json_encode($data);
	exit;
}

if (strlen($request['cmd']))
{
	if (strcmp($request['cmd'], 'checkMovieQueue') == 0)
	{
		$data = $projects->checkMovieQueue($request['data']);
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			echo json_encode($data);
			exit;
		}
	}
	if (strcmp($request['cmd'], 'addProject') == 0 && strlen($request['project']))
	{
		if ($projects->projectExists($request['project']))
		{
			header("HTTP/1.1 403 Forbidden");
			header("Content-Type: text/html" );
			print "Project exists\r\n";
			exit;
		}
		else
		{
			$data = $projects->addProject($request['project']);
			if (is_array($data))
			{
				header("HTTP/1.1 200 OK");
				header("Content-Type: text/html" );
				echo json_encode($data);
				exit;
			}
		}
	}
	else if (strcmp($request['cmd'], 'saveProject') == 0)
	{
		$data = $projects->saveProject($request['data']);
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			echo json_encode($data);
			exit;
		}
	}
	else if (strcmp($request['cmd'], 'isPublished') == 0)
	{
		if (array_key_exists('serverpath', $request))
		{
			$data = $projects->isPublished($request['data'], $request['serverpath']);
		}
		else
		{
			$data = $projects->isPublished($request['data']);
		}
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			echo json_encode($data);
			exit;
		}
	}
	else if (strcmp($request['cmd'], 'exportProject') == 0)
	{
		if ($request['isMovie'])
		{
			$data = $projects->exportProjectAsMovie($request['data']);
		}
		else
		{
			$data = $projects->exportProject($request['data']);
		}
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			echo json_encode($data);
			exit;
		}
	}
	else if (strcmp($request['cmd'], 'createPreview') == 0)
	{
		$data = $projects->createPreview($request['data']);
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			echo json_encode($data);
			exit;
		}
	}
	else if (strcmp($request['cmd'], 'publishProject') == 0)
	{
		$republish = (array_key_exists('republish', $request)) ? $request['republish'] : false;
		if (array_key_exists('serverpath', $request))
		{
			$data = $projects->publishLocal($request['data'], $request['serverpath'], $republish);
		}
		else
		{
			$data = $projects->publishViaFTP($request['data'], $republish);
		}
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			echo json_encode($data);
			exit;
		}
	}
	else if (strcmp($request['cmd'], 'unpublishProject') == 0)
	{
		if (array_key_exists('serverpath', $request))
		{
			$data = $projects->unpublishLocal($request['data'], $request['serverpath']);
		}
		else
		{
			$data = $projects->unpublishViaFTP($request['data']);
		}
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			echo json_encode($data);
			exit;
		}
	}
	else if (strcmp($request['cmd'], 'loadProject') == 0)
	{
		$data = $projects->loadProject($request['projectid'], $request['distributeslides']);
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			echo json_encode($data);
			exit;
		}
	}
	else if (strcmp($request['cmd'], 'deleteImages') == 0)
	{
		$data = $projects->deleteImages($request['images']);
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			echo json_encode($data);
			exit;
		}
	}
	else if (strcmp($request['cmd'], 'updateSlideLengths') == 0)
	{
		$data = $projects->saveProject($request['data']);
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			echo json_encode($data);
			exit;
		}
	}
	else if (strcmp($request['cmd'], 'deleteProject') == 0)
	{
		if (!$projects->projectIdExists($request['projectid']))
		{
			header("HTTP/1.1 404 Not found");
			header("Content-Type: text/html" );
			print "Project not found\r\n";
			exit;
		}
		else
		{
			$data = $projects->deleteProject($request['projectid']);
			if (is_array($data))
			{
				header("HTTP/1.1 200 OK");
				header("Content-Type: text/html" );
				echo json_encode($data);
				exit;
			}
		}
	}
	else if (strcmp($request['cmd'], 'deleteAudio') == 0)
	{
		$data = $projects->deleteAudio();
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: text/html" );
			echo json_encode($data);
			exit;
		}
	}
	else if (strcmp($request['cmd'], 'listProjects') == 0)
	{
		$data = $projects->getAvailableProjects();
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: application/json" );
			$datastring = json_encode($data);
			header("Content-Length: ".strlen($datastring));
			print($datastring);
			exit;
		}
	}
	
	else if (strcmp($request['cmd'], 'manageProjects') == 0)
	{
		$data = $projects->getAvailableProjectsAsArray();
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: application/json" );
			$datastring = json_encode($data);
			header("Content-Length: ".strlen($datastring));
			print($datastring);
			exit;
		}
	}
	
	else if (strcmp($request['cmd'], 'searchUsers') == 0)
	{
		$data = $projects->searchUsers($request['searchString']);
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: application/json" );
			$datastring = json_encode($data);
			header("Content-Length: ".strlen($datastring));
			print($datastring);
			exit;
		}
	}
	
	else if (strcmp($request['cmd'], 'addTeamMember') == 0)
	{
		$data = $projects->addTeamMember($request['userid'],$request['projectid']);
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: application/json" );
			$datastring = json_encode($data);
			header("Content-Length: ".strlen($datastring));
			print($datastring);
			exit;
		}
	}
	
	else if (strcmp($request['cmd'], 'loadTeamMembers') == 0)
	{
		$data = $projects->loadTeamMembers($request['projectid']);
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: application/json" );
			$datastring = json_encode($data);
			header("Content-Length: ".strlen($datastring));
			print($datastring);
			exit;
		}
	}
	
	else if (strcmp($request['cmd'], 'deleteTeamMember') == 0)
	{
		$data = $projects->deleteTeamMember($request['userid'],$request['projectid']);
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: application/json" );
			$datastring = json_encode($data);
			header("Content-Length: ".strlen($datastring));
			print($datastring);
			exit;
		}
	}
	
	else if (strcmp($request['cmd'], 'listSharedProjects') == 0)
	{
		$data = $projects->getAvailableProjects(true);
		if (is_array($data))
		{
			header("HTTP/1.1 200 OK");
			header("Content-Type: application/json" );
			$datastring = json_encode($data);
			header("Content-Length: ".strlen($datastring));
			print($datastring);
			exit;
		}
	}
	
	else if (strcmp($request['cmd'], 'renameProject') == 0 && strlen($request['project']))
	{
		if ($projects->projectExists($request['project']))
		{
			header("HTTP/1.1 403 Forbidden");
			header("Content-Type: text/html" );
			print "Project exists\r\n";
			exit;
		}
		else
		{
			$data = $projects->renameProject($request['project'], $request['id']);
			if (is_array($data))
			{
				header("HTTP/1.1 200 OK");
				header("Content-Type: text/html" );
				echo json_encode($data);
				exit;
			}
		}
	}
	
	else if (strcmp($request['cmd'], 'copyProject') == 0 && strlen($request['project']))
	{
		if ($projects->projectExists($request['project']))
		{
			header("HTTP/1.1 403 Forbidden");
			header("Content-Type: text/html" );
			print "Project exists\r\n";
			exit;
		}
		else
		{
			$data = $projects->copyProject($request['project'], $request['id']);
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
print "unknown command ".$request['cmd']."\r\n";
exit;

?>