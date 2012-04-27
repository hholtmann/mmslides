<?php
/*
 * moviedownload.php
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


include_once "config.php";

deliverData($_GET['id']);

/**
*   deliver data for download via browser.
*/
function deliverData($id, $mime = "application/octet-stream", $charset = "")
{
	if (strlen($id))
	{
		$disposition = "attachment"; // "inline" to view file in browser or "attachment" to download to hard disk
		//		$mime = "application/octet-stream"; // or whatever the mime type is

		if ($disposition == "attachment")
		{
			header("Cache-control: private");
		}
		else
		{
			header("Cache-Control: no-cache, must-revalidate");
			header("Pragma: no-cache");
		}

		if (strlen($charset))
		{
			$charset = "; charset=$charset";
		}

		global $movie_dir;
		$data = file_get_contents($movie_dir . $id);
		$result = preg_split("/:::/", $data);
		$filename = $result[0];
		$projectname = $result[1];
		if (@file_exists($filename))
		{
			header("Content-Type: $mime$charset");
			header("Content-Disposition:$disposition; filename=\"".$projectname."\"");
			header("Content-Description: ".$projectname);
			header("Content-Length: ".(string)filesize($filename));
			header("Connection: close");
			echo file_get_contents($filename);
		}
	}
	exit;
}


?>