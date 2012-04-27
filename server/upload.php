<?php

/*
 * upload.php
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


require_once 'Projects.php';

$request = array('SID' => $_POST['SID']);
$projects = new Projects($request);

$project = $_POST['project'];
$type = $_POST['type'];

if (strlen($project))
{
	global $project_webroot;

	$arrProject = $projects->getProject();
	if ($arrProject)
	{
		$result = "";
		if ($type == "image")
		{
			foreach ($_FILES['file']['tmp_name'] as $idx => $filename)
			{
				$pathinfo = pathinfo($_FILES['file']['name'][$idx]);
				$extension = strtolower($pathinfo['extension']);
				if (preg_match(":image/(.*):", $_FILES['file']['type'][$idx], $matches))
				{
					$newfilename = md5($_FILES['file']['name'][$idx] . time()) . "." . $matches[1];
					if (move_uploaded_file($filename, $project_webroot . $arrProject['path'] . "/" . $newfilename))
					{
						$p = $projects->addImage($newfilename);
					} 
				} else if (strtolower($_FILES['file']['type'][$idx]) == "application/zip" || $extension == "zip") {
					$p = $projects->extractImageArchive($filename, $arrProject['path']);
				}
			}
		}
		else if ($type == "audio")
		{
			foreach ($_FILES['file']['tmp_name'] as $idx => $filename)
			{
				if (preg_match(":(mp3)|(mpeg):", $_FILES['file']['type'][$idx], $matches))
				{
					$newfilename = md5($_FILES['file']['name'][$idx] . time()) . ".mp3";
					if (move_uploaded_file($filename, $project_webroot . $arrProject['path'] . "/" . $newfilename))
					{
						$p = $projects->addAudio($newfilename, $_FILES['file']['name'][$idx]);
					}
				}
			}
		}
		header("HTTP/1.1 200 OK");
		header("Content-Type: text/html" );echo $b;
	}
	else
	{
		header("HTTP/1.1 404 Not found");
		header("Content-Type: text/html" );
	}
}
else
{
	header("HTTP/1.1 401 Unauthorized");
	header("Content-Type: text/html" );
}
exit;

?>