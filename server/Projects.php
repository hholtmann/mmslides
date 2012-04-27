<?php

/*
 * Projects.php
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


require_once "SessionHandler.php";
require_once "Userdata.php";
require_once "config.php";

if (class_exists("ZipArchive")) {
	require_once "Zipper.php";
} else {

}

class Projects extends SessionHandler
{
	private $projectpath;
	private $userdata;

	function __construct($request) 
	{
		parent::__construct($request);

		global $project_datapath;
		global $project_webroot;
		
		$this->projectpath = $project_webroot;
		$this->userdata = new Userdata($request);
	}

	protected function createthumbWithAspect($src_path, $dst_path, $aspect_w, $aspect_h, $max_w)
	{
		$system=explode(".",$src_path);
		if (preg_match("/jpg|jpeg/",$system[1])){$src_img=@imagecreatefromjpeg($src_path);}
		try
		{
			if (preg_match("/png/",$system[1])){$src_img=@imagecreatefrompng($src_path);}
		}
		catch (Exception $e)
		{
			$src_img=@imagecreatefromjpeg($src_path);
		}
		$old_w=imageSX($src_img);
		$old_h=imageSY($src_img);
		$new_w = $max_w;
		$max_h = $max_w * $aspect_h/$aspect_w;
		$new_h = ($max_w/$old_w)*$old_h;
		if ($new_h > $max_h)
		{
			$shrink = $new_h/$max_h;
			$new_h = $max_h;
			$new_w = $new_w/$shrink;
		}
		$dst_img = ImageCreateTrueColor($max_w,$max_h);
		/*
		$black = ImageColorAllocate ($im, 0, 0, 0);
		imagefill($dst_img, 0, 0, $black);
		*/
		$offsetx = ($new_w < $max_w) ? round(($max_w-$new_w)/2.0) : 0;
		$offsety = ($new_h < $max_h) ? round(($max_h-$new_h)/2.0) : 0;
		imagecopyresampled($dst_img,$src_img,$offsetx,$offsety,0,0,$new_w,$new_h,$old_w,$old_h); 

		if (preg_match("/png/",$system[1]))
		{
//			imagepng($dst_img,$dst_path); 
			imagejpeg($dst_img,$dst_path); 
		} else {
			imagejpeg($dst_img,$dst_path); 
		}
		imagedestroy($dst_img); 
		imagedestroy($src_img); 
	}

	protected function createthumb($name, $filename, $new_w, $new_h, $makesquare = false)
	{
		$system=explode(".",$name);
		if (preg_match("/jpg|jpeg/",$system[1])){$src_img=imagecreatefromjpeg($name);}
		if (preg_match("/png/",$system[1])){$src_img=imagecreatefrompng($name);}
		$old_w=imageSX($src_img);
		$old_h=imageSY($src_img);
		$aspect = $old_w/$old_h;
		if ($new_w == 0) $new_w = $new_h * $aspect;
		if ($new_h == 0) $new_h = $new_w / $aspect;
		$thumb_w = $new_w;
		$thumb_h = $new_h;
		$dst_img=null;
		if ($makesquare)
		{
			$max = max($thumb_w, $thumb_h);
			$min = min($thumb_w, $thumb_h);
			$factor = $max / $min;
			$big_img = ImageCreateTrueColor($thumb_w*$factor,$thumb_h*$factor);
			imagecopyresampled($big_img,$src_img,0,0,0,0,$thumb_w*$factor,$thumb_h*$factor,$old_w,$old_h); 
			$dst_img = ImageCreateTrueColor($max,$max);
			imagecopy($dst_img,$big_img,0,0,round((($thumb_w*$factor)-$max)/2),round((($thumb_h*$factor)-$max)/2),$max,$max); 
		}
		else
		{
			$dst_img = ImageCreateTrueColor($thumb_w,$thumb_h);
			imagecopyresampled($dst_img,$src_img,0,0,0,0,$thumb_w,$thumb_h,$old_w,$old_h); 
		}
		if (preg_match("/png/",$system[1]))
		{
			imagepng($dst_img,$filename); 
		} else {
			imagejpeg($dst_img,$filename); 
		}
		imagedestroy($dst_img); 
		imagedestroy($src_img); 
	}
	
	public function projectIdExists($projectid)
	{
		
		try {
			
			$userid = $this->getUserId();
			error_log("Checking for ".$project );
			$stmt = $this->dbh->prepare("SELECT * FROM t_project WHERE (id = :projectid AND userid=:userid)");
			$stmt->bindParam(':projectid', $projectid, PDO::PARAM_INT);
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
		    $stmt->execute();
	    	if ($stmt->fetchColumn()) {
				error_log("Returning true");
				return true;
			} else {
				return false;
			}
		} catch (PDOException $e) {
			return false;
		}	
	}
	
	public function checkMovieQueue($project)
	{
		global $movie_queue;

		$userid = $this->getUserId();
		$found = 0;
		foreach (scandir($movie_queue) as $item) 
		{
			if ($item == '.' || $item == '..') continue;
			if (@is_file($movie_queue.DIRECTORY_SEPARATOR.$item))
			{
				$json = json_decode(file_get_contents($movie_queue.DIRECTORY_SEPARATOR.$item), true);
				if ($project['id'] == $json['projectid']) $found++;
			}
		}
		return array("found" => $found);
	}
		
	public function projectExists($project)
	{
		
		try {
			
			$userid = $this->getUserId();
			error_log("Checking for ".$project );
			$stmt = $this->dbh->prepare("SELECT * FROM t_project WHERE (project = :projectname AND userid=:userid)");
			$stmt->bindParam(':projectname', $project, PDO::PARAM_STR,strlen($project));
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
		    $stmt->execute();
	    	if ($stmt->fetchColumn()) {
				error_log("Returning true");
				return true;
			} else {
				return false;
			}
		} catch (PDOException $e) {
			return false;
		}	
	}

	public function isMember($projectid)
	{		
		try {
			$userid = $this->getUserId();
			$stmt = $this->dbh->prepare("SELECT * FROM t_projectuser WHERE (projectid = :projectid AND userid=:userid)");
			$stmt->bindParam(':projectid', $projectid, PDO::PARAM_INT);
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
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

	public function isOwner($projectid)
	{
		try {
			$userid = $this->getUserId();
			$stmt = $this->dbh->prepare("SELECT * FROM t_project WHERE (id = :id AND userid=:userid)");
			$stmt->bindParam(':id', $projectid, PDO::PARAM_INT);
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
			$stmt->execute();
		   	if ($stmt->fetchColumn()) {
				return true;
			} else {
				return false;
			}
		}	catch (PDOException $e) {
			return false;
		}	
	}
	
	private function createPathsIfNecessary($path)
	{
		if (!is_dir($this->projectpath .$path . "/thumbs"))
			mkdir($this->projectpath .  $path. "/thumbs");
		if (!is_dir($this->projectpath . $path . "/originals"))
			mkdir($this->projectpath . $path . "/originals");
		if (!is_dir($this->projectpath .$path . "/1280"))
			mkdir($this->projectpath . $path . "/1280");
		if (!is_dir($this->projectpath .$path . "/1024"))
			mkdir($this->projectpath . $path. "/1024");
		if (!is_dir($this->projectpath . $path . "/800"))
			mkdir($this->projectpath . $path . "/800");
		if (!is_dir($this->projectpath . $path . "/640"))
			mkdir($this->projectpath . $path . "/640");
		if (!is_dir($this->projectpath . $path . "/480"))
			mkdir($this->projectpath . $path . "/480");	
		if (!is_dir($this->projectpath .$path . "/320"))
			mkdir($this->projectpath . $path . "/320");
	}
	
	
	public function extractImageArchive($filename,$projectpath) {
		$zip = new ZipArchive;
		$res = $zip->open($filename);
		if ($res === TRUE) {
			for($i = 0; $i < $zip->numFiles; $i++) {
				$targetFile = basename($zip->getNameIndex($i));
				$pathinfo =  pathinfo($zip->getNameIndex($i));
				$extension = strtolower($pathinfo['extension']);
				if (($extension == "jpg" || $extension == "png" || $extension == "jpeg") &&  substr($targetFile, 0,1) != ".")
				{
					error_log("======> BASENAME ".$targetFile);
					$newfilename = md5($targetFile . time()) . "." . $extension;
					$fh = $zip->getStream( $zip->getNameIndex($i)); 
					$dh = fopen($this->projectpath.$projectpath."/".$newfilename, 'w' ); 
					if ( ! $fh )  {
						continue; // next file 
					}
					while ( ! feof( $fh ) )  {
						fwrite( $dh, fread($fh, 8192) ); 
					}
					fclose($fh); 
					fclose($dh); 
					$this->addImage($newfilename);
				}
			}
		 	$zip->close(); 
		} else {
			return false;
		}
	}
	
	public function rebuildImages()
	{
		global $project_webroot; // = '/Users/hschottm/Sites/mmslideserver/';

		$dir = $project_webroot . "projects";
		
		foreach (scandir($dir) as $item) 
		{
			if ($item == '.' || $item == '..') continue;
			if (is_dir($dir.DIRECTORY_SEPARATOR.$item.DIRECTORY_SEPARATOR.'originals'))
			{
				$originalsdir = $dir.DIRECTORY_SEPARATOR.$item.DIRECTORY_SEPARATOR.'originals';
				foreach (scandir($originalsdir) as $original)
				{
					if ($original == '.' || $original == '..') continue;
					if (is_file($originalsdir.DIRECTORY_SEPARATOR.$original))
					{
						$filepath = $originalsdir.DIRECTORY_SEPARATOR.$original;
						$filepath1280 = $dir.DIRECTORY_SEPARATOR.$item.DIRECTORY_SEPARATOR."1280".DIRECTORY_SEPARATOR.$original;
						$filepath1024 = $dir.DIRECTORY_SEPARATOR.$item.DIRECTORY_SEPARATOR."1024".DIRECTORY_SEPARATOR.$original;
						$filepath800  = $dir.DIRECTORY_SEPARATOR.$item.DIRECTORY_SEPARATOR."800".DIRECTORY_SEPARATOR.$original;
						$filepath640  = $dir.DIRECTORY_SEPARATOR.$item.DIRECTORY_SEPARATOR."640".DIRECTORY_SEPARATOR.$original;
						$filepath480  = $dir.DIRECTORY_SEPARATOR.$item.DIRECTORY_SEPARATOR."480".DIRECTORY_SEPARATOR.$original;
						$filepath320  = $dir.DIRECTORY_SEPARATOR.$item.DIRECTORY_SEPARATOR."320".DIRECTORY_SEPARATOR.$original;
						list($width, $height, $type, $attr) = getimagesize($filepath);
						$aspect = $width/$height;
						$this->createPathsIfNecessary($data['path']);
						if ((($width*1.0)/($height*1.0)) > 4.0/3.0)
						{
							$this->createthumbWithAspect($filepath, $filepath, 4, 3, $width);
						}
						else
						{
							$this->createthumbWithAspect($filepath, $filepath, 4, 3, $height*4.0/3.0);
						}
						$this->createthumbWithAspect($filepath, $filepath1280, 4, 3, 1280);
						$this->createthumbWithAspect($filepath, $filepath1024, 4, 3, 1024);
						$this->createthumbWithAspect($filepath, $filepath800 , 4, 3, 800);
						$this->createthumbWithAspect($filepath, $filepath640 , 4, 3, 640);
						$this->createthumbWithAspect($filepath, $filepath480 , 4, 3, 480);
						$this->createthumbWithAspect($filepath, $filepath320 , 4, 3, 320);
					}
				}
			}
		}
	}
	
	public function addImage($filename)
	{
		$userid = $this->getUserId();
		$projectid = $this->getProjectId();
		if (!$projectid) return false;

		$data = $this->loadProjectData();

		$data['lastchange'] = time();
		if (!is_array($data['data']))
		{
			$data['data'] = array();
		}
		if (!is_array($data['data']['slides']))
		{			
			$data['data']['slides'] = array();
		}
		$udata = $this->userdata->getUserdata();
		$transition = (is_array($udata['preferences']) && strcmp($udata['preferences']['defaultTransition'], 'none') != 0) ? $udata['preferences']['defaultTransition'] : false;
		$slidelength = (is_array($udata['preferences'])) ? $udata['preferences']['defaultSlideLength'] : 8.0*1000.0;
		$jpegfilename = str_replace('.PNG', '.jpg', str_replace('.png', '.jpg', $filename));
		$ip = $_SERVER["REMOTE_ADDR"];
		if ($transition)
		{
			$transitionlength = (is_array($udata['preferences'])) ? $udata['preferences']['defaultTransitionLength'] : 2.0*1000.0;
			$data['data']['slides'][] = array("ip" => $ip, "file" => $jpegfilename, "caption" => "", "length" => $slidelength, 'transition' => array('type' => $transition, 'length' => $transitionlength));
		}
		else
		{
			$data['data']['slides'][] = array("ip" => $ip, "file" => $jpegfilename, "caption" => "", "length" => $slidelength);
		}
		$calculatedlength = 0.0;
		foreach ($data['data']['slides'] as $tmpslide)
		{
			$calculatedlength += $tmpslide['length'];
		}
		if ($calculatedlength > $data['data']['length'])
		{
			$data['data']['length'] = $calculatedlength;
		}		
		
		$filepath = $this->projectpath . $data['path'] . "/" . $filename;
		$filepathOrig = $this->projectpath . $data['path'] . "/originals/" . $jpegfilename;
		$filepath1280 = $this->projectpath . $data['path'] . "/1280/" . $jpegfilename;
		$filepath1024 = $this->projectpath . $data['path'] . "/1024/" . $jpegfilename;
		$filepath800 = $this->projectpath . $data['path'] . "/800/" . $jpegfilename;
		$filepath640 = $this->projectpath . $data['path'] . "/640/" . $jpegfilename;
		$filepath480 = $this->projectpath . $data['path'] . "/480/" . $jpegfilename;
		$filepath320 = $this->projectpath . $data['path'] . "/320/" . $jpegfilename;
		$filepathThumb = $this->projectpath . $data['path'] . "/thumbs/" . $jpegfilename;
		list($width, $height, $type, $attr) = getimagesize($filepath);
		$aspect = $width/$height;
		$this->createPathsIfNecessary($data['path']);
		if ((($width*1.0)/($height*1.0)) > 4.0/3.0)
		{
			$this->createthumbWithAspect($filepath, $filepathOrig, 4, 3, $width);
		}
		else
		{
			$this->createthumbWithAspect($filepath, $filepathOrig, 4, 3, $height*4.0/3.0);
		}
		$this->createthumbWithAspect($filepath, $filepath1280, 4, 3, 1280);
		$this->createthumbWithAspect($filepath, $filepath1024, 4, 3, 1024);
		$this->createthumbWithAspect($filepath, $filepath800 , 4, 3, 800);
		$this->createthumbWithAspect($filepath, $filepath640 , 4, 3, 640);
		$this->createthumbWithAspect($filepath, $filepath480 , 4, 3, 480);
		$this->createthumbWithAspect($filepath, $filepath320 , 4, 3, 320);
		$this->createthumb($filepath, $filepathThumb, 94, 0, true);
		@unlink($filepath);

		//update
		$this->updateProjectWithData($data);
		
		return $data;
	}
	
	public function converToOgg($orgFileName) {
	  	global $ffmpeg_path;
	  	$ext = strrchr($orgFileName, '.'); 
		if($ext !== false) 
	    { 
			$basename = substr($orgFileName, 0, -strlen($ext)); 
	    } 
	  	$cmd1 = "$ffmpeg_path -i $orgFileName -acodec libvorbis -ab 96000 $basename".".ogg";
		$out = shell_exec($cmd1);
	}
	
	public function addAudio($filename, $name = "")
	{
		$userid = $this->getUserId();
		$projectid = $this->getProjectId();
		if (!$projectid) return false;
		$data = $this->loadProjectData();

		$this->deleteAudio();
		$data['lastchange'] = time();
		if (!is_array($data['data']))
		{
			$data['data'] = array();
		}
		if (!is_array($data['data']['meta']))
		{
			$data['data']['meta'] = array();
		}
		$filedir = $this->projectpath . $data['path'] . "/";
		$filepath = $filedir . $filename;
		require_once "getid3/getid3.php";
		$getID3 = new getID3;
		$fileinfo = $getID3->analyze($filepath);
		$data['data']['meta']['audio'] = array("file" => $filename, "name" => $name, "length" => $fileinfo['playtime_seconds']);
		$data['data']['length'] = $fileinfo['playtime_seconds']*1000.0;
		$waveform = $this->generateWaveform($filedir, $filename);
		$data['data']['meta']['waveform'] = $waveform;
		$this->converToOgg($filepath);
		$this->updateProjectWithData($data);
		return $data;
	}

	public function deleteAudio()
	{
		$userid = $this->getUserId();
		$projectid = $this->getProjectId();
		if (!$projectid) return false;
		$data = $this->loadProjectData();
		
		$data['lastchange'] = time();
		if (!is_array($data['data']))
		{
			$data['data'] = array();
		}
		if (!is_array($data['data']['meta']))
		{
			$data['data']['meta'] = array();
		}
		$audiotrack = $data['data']['meta']['audio'];
		if (is_array($audiotrack) && strlen($audiotrack['file']) > 0) 
		{
			@unlink($this->projectpath . $data['path'] . "/" . $audiotrack['file']);
			$ext = strrchr($audiotrack['file'], '.'); 
			if($ext !== false) 
		    { 
				$basename = substr($audiotrack['file'], 0, -strlen($ext)); 
		    }
			@unlink($this->projectpath . $data['path'] . "/" . $basename.".ogg");
		}
		unset($data['data']['meta']['audio']);
		unset($data['data']['meta']['waveform']);
		$this->updateProjectWithData($data);
		return $data;
	}

	public function deleteImages($filenames)
	{
		foreach ($filenames as $filename) 
		{
			$this->deleteImage($filename);
		}
		$userid = $this->getUserId();
		$projectid = $this->getProjectId();
		$data = $this->loadProjectData();
		return $data;
	}
	
	public function deleteImage($filename)
	{
		$userid = $this->getUserId();
		$projectid = $this->getProjectId();
		if (!$projectid) return false;
		$data = $this->loadProjectData();
		$data['lastchange'] = time();
		
		if (!is_array($data['data']))
		{
			$data['data'] = array();
		}
		if (!is_array($data['data']['slides']))
		{
			$data['data']['slides'] = array();
		}
		foreach ($data['data']['slides'] as $idx => $filedata)
		{
			if (strcmp($filedata['file'], $filename) == 0) 
			{
				@unlink($this->projectpath . $data['path'] . "/thumbs/" . $filename);
//				echo "thumbs\n";
				@unlink($this->projectpath . $data['path'] . "/originals/" . $filename);
//				echo "originals\n";
				@unlink($this->projectpath . $data['path'] . "/1280/" . $filename);
//				echo "1280\n";
				@unlink($this->projectpath . $data['path'] . "/1024/" . $filename);
//				echo "1024\n";
				@unlink($this->projectpath . $data['path'] . "/800/" . $filename);
//				echo "800\n";
				@unlink($this->projectpath . $data['path'] . "/640/" . $filename);
				@unlink($this->projectpath . $data['path'] . "/480/" . $filename);
//				echo "640\n";
				@unlink($this->projectpath . $data['path'] . "/320/" . $filename);
//				echo "320\n";
				unset($data['data']['slides'][$idx]);
			}
		}
		$data['data']['slides'] = array_values($data['data']['slides']);
		
		//update
		$this->updateProjectWithData($data);
		return $data;
	}

	public function deleteProject($projectid)
	{
		$userid = $this->getUserId();
		if (!$projectid) return false;
		$data = $this->loadProjectData($projectid);
		error_log("Trying delete for userid ".$userid. "and projectid ".$projectid);

		if (strlen($data['path']))
		{
			$filepath = $this->projectpath . $data['path'];
			if ($this->deleteDirectory($filepath))
			{
				$stmt = $this->dbh->prepare("DELETE FROM t_project WHERE(userid = :userid AND id = :projectid)");
				$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
				$stmt->bindParam(':projectid', $projectid, PDO::PARAM_INT);

				if ($stmt->execute()) 
				{
					return $this->getAvailableProjectsAsArray();
				}
			}	
		}
		else
		{
			return false;
		}
	}

	public function getProject()
	{
		$userid = $this->getUserId();
		$projectid = $this->getProjectId();
		if (!$projectid) return false;
		$result = $this->loadProjectData();
		return $result;
	}
	
	public function addProject($project)
	{
		if (strlen($project) == 0) return false;
		try {
			$pathid = md5(time());
			
			$path = "projects/".$pathid;
			
			$udata = $this->userdata->getUserdata();
			$userid = $this->getUserId();

			$projectlength = (is_array($udata['preferences'])) ? $udata['preferences']['defaultLength'] : 180000;

			
			$stmt = $this->dbh->prepare("INSERT INTO t_project (project,userid,path,created,lastchange,lasteditor,data) values (:project,:userid,:path,:created,:lastchange,:userid,:data)");
			$stmt->bindParam(':project', $project, PDO::PARAM_STR, strlen($project));
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
			$stmt->bindParam(':path', $path, PDO::PARAM_STR,strlen($path));
			$stmt->bindParam(':created', time(), PDO::PARAM_INT);
			$stmt->bindParam(':lastchange', time(), PDO::PARAM_INT);
			$data = array("project" => $project, "id" => 0, "path" => $path, "lastchange" => time(), "created" => time(), 
				'data' => array('length' => $projectlength));
			$stmt->bindParam(':data', serialize($data['data']), PDO::PARAM_STR,strlen(serialize($data['data'])));
			if ($stmt->execute()) 
			{
				$data = array("project" => $project, "id" => $this->lastInsertId(), "path" => 'projects/' . $pathid, "lastchange" => time(), "created" => time(), 
							  'data' => array('length' => $projectlength));
				$_SESSION['project_id'] = $data['id'];
				mkdir($this->projectpath . $path,0777, true);
				return $data;
			} else {
				error_log("Exception ".print_r($this->dbh->errorInfo(), true));

				return false;
			}
		} catch (PDOException $e) {
			return false;
		}
	}

	public function saveProject($data)
	{
		$userid = $this->getUserId();
		$projectid = $this->getProjectId();
		if (!$projectid) return false;
		$completeData = $this->loadProjectData();
		$completeData['lastchange'] = time();
		$completeData['data'] = $data;
		$this->updateProjectWithData($data);
		return $completeData;
	}

	protected function standardize($varValue)
	{
		$varValue = preg_replace
		(
			array('/[^a-zA-Z0-9 _-]+/i', '/ +/', '/\-+/'),
			array('', '-', '-'),
			$varValue
		);
		return strtolower($varValue);
	}
	
	public function exportProjectAsMovie($exportsettings, $dontsavesettings = false)
	{
		$userid = $this->getUserId();
		$udata = $this->userdata->getUserdata();
		$projectid = $this->getProjectId();
		$data = $this->loadProjectData();
		if (!$dontsavesettings) $this->userdata->saveExportSettings($exportsettings);

		global $project_webroot;
		global $movie_queue;
		
		$params = array(
			"exportsettings" => $exportsettings,
			"userid" => $userid,
			"email" => $udata['email'],
			"projectid" => $projectid,
			"data" => $data,
			"project_webroot" => $project_webroot
		);
		$file = fopen($movie_queue . '/' . md5(time()), "w"); 
		fwrite($file, json_encode($params)); 
		fclose ($file);  
		
		return array('error' => 0, 'result' => $movie_queue . '/' . $tmpfname);
	}

	public function exportProject($exportsettings, $dontsavesettings = false)
	{
		$userid = $this->getUserId();
		$projectid = $this->getProjectId();
		$data = $this->loadProjectData();
		if (!$dontsavesettings) $this->userdata->saveExportSettings($exportsettings);
		
//		$theme = (strlen($exportsettings['styleTemplate'])) ? $exportsettings['styleTemplate'] : 'default';
		$theme = "default";
		$zip = new Zipper();
		$filename = $this->projectpath . $data['path'] . "/" . $this->standardize($data['project']) . '.zip';
		if (@file_exists($filename)) @unlink($filename);

		if ($zip->open($filename, ZIPARCHIVE::CREATE)!==TRUE) 
		{
			exit("cannot open <$filename>\n");
		}

		$zip->addEmptyDir('images');
		$zip->addEmptyDir('thumbs');
		$zip->addEmptyDir('audio');
		$zip->addEmptyDir('config');
		$zip->addDir('./css');
		$zip->addFile('./themes/' . $theme . '/css/styles.css', './css/styles.css');
		$zip->addEmptyDir('icons');
		$zip->addFilesFromDir('./themes/' . $theme . '/icons', './icons');
		$zip->addDir('./js');
		$zip->addFile('_index.html', '/index.html');
		$zip->addFile('integration.html', '/integration.html');
		$zip->addFile('_index_computer.html', '/_index_computer.html');
		$zip->addFile('./flash/mmslides.swf', '/mmslides.swf');
		$imageformat = (strlen($exportsettings['width'])) ? $exportsettings['width'] : "1024";
		foreach ($data['data']['slides'] as $idx => $filedata)
		{
			if (array_key_exists('file', $filedata) && strlen($filedata['file'])) 
			{
				$filepaths = array(
					'1280' => $this->projectpath . $data['path'].DIRECTORY_SEPARATOR."1280".DIRECTORY_SEPARATOR.$filedata['file'],
					'1024' => $this->projectpath . $data['path'].DIRECTORY_SEPARATOR."1024".DIRECTORY_SEPARATOR.$filedata['file'],
					'800' => $this->projectpath . $data['path'].DIRECTORY_SEPARATOR."800".DIRECTORY_SEPARATOR.$filedata['file'],
					'640' => $this->projectpath . $data['path'].DIRECTORY_SEPARATOR."640".DIRECTORY_SEPARATOR.$filedata['file'],
					'480' => $this->projectpath . $data['path'].DIRECTORY_SEPARATOR."480".DIRECTORY_SEPARATOR.$filedata['file'],
					'320' => $this->projectpath . $data['path'].DIRECTORY_SEPARATOR."320".DIRECTORY_SEPARATOR.$filedata['file']
				);
				foreach ($filepaths as $filesize => $filepath)
				{
					if (@file_exists($filepath))
					{
						$zip->addFile($filepath, '/images/' . $filesize . '/' . $filedata['file']);
					}
					$thumbpath = $this->projectpath . $data['path'] . "/thumbs/" . $filedata['file'];
					if (@file_exists($thumbpath))
					{
						$zip->addFile($thumbpath, '/thumbs/' . $filedata['file'] . ".thumb.jpg");
					}
				}
			}
		}
		$audiotrack = $data['data']['meta']['audio'];
		if (is_array($audiotrack) && strlen($audiotrack['file']) > 0) 
		{
			$audiopath = $this->projectpath . $data['path'] . "/" . $audiotrack['file'];
			if (@file_exists($audiopath))
			{
				$zip->addFile($audiopath, '/audio/' . $audiotrack['file']);
			}
		}
		$projectdata = $data;
		if (strlen($exportsettings['password']))
		{
			$exportsettings['password'] = md5($exportsettings['password']);
		}
		$projectdata['slideshow'] = $exportsettings;
		$zip->addFromString('config/jsonconfig.js', json_encode($projectdata));
		$zip->close();
		return array('url' => $data['path'] . '/' . basename($filename));
	}

	public function createPreview($exportsettings)
	{
		error_log("HALLO ".$exportsettings['showCaptionsByDefault']);
		$exportsettings['autoPlay'] = true;
		$exportsettings['loop'] = true;
		$exportsettings['showCaptionsByDefault'] = true;
		$userid = $this->getUserId();
		$projectid = $this->getProjectId();
		if (!$projectid) return array('result' => false);
		$data = $this->loadProjectData();
		
		$previewpath = $this->projectpath . $data['path'] . "/preview";
		if (is_dir($previewpath))
		{
			if (!$this->deleteDirectory($previewpath))
			{
				return array('result' => false);
			}
		}
		$this->exportProject($exportsettings, true);
		$filename = $this->projectpath . $data['path'] . "/" . $this->standardize($data['project']) . '.zip';
		$zip = new ZipArchive;
		if ($zip->open($filename) === true) 
		{
			$res = $zip->extractTo($previewpath);
			$zip->close();
			if ($res)
			{
				return array('result' => true);
			}
			else
			{
				return array('result' => false);
			}
		} 
	}

	public function publishLocal($exportsettings, $serverpath, $republish = false)
	{
		
		$userid = $this->getUserId();
		$projectid = $this->getProjectId();
		$data = $this->loadProjectData();
		
		if ($republish)
		{
			$this->unpublishLocal($exportsettings, $serverpath);
		}
		$this->exportProject($exportsettings);
		$filename = $this->projectpath . $data['path'] . "/" . $this->standardize($data['project']) . '.zip';
		$zip = new ZipArchive;
		if ($zip->open($filename) === true) 
		{
			if (substr($serverpath, -1) !== '/') $serverpath .= '/';
			$serverpath .= $projectid;
			if (is_dir($serverpath))
			{
				$this->deleteDirectory($serverpath);
			}
			$res = $zip->extractTo($serverpath);
			$zip->close();
			if ($res)
			{
				return array('result' => true);
			}
			else
			{
				return array('result' => false);
			}
		} 
		else 
		{
			return array('result' => false);
		}
	}

	function ftp_rmAll($conn_id,$dst_dir)
	{
		$ar_files = ftp_nlist($conn_id, $dst_dir);
		if (is_array($ar_files))
		{
			for ($i=0;$i<sizeof($ar_files);$i++)
			{
				$st_file = basename($ar_files[$i]);
				if ($st_file == '.' || $st_file == '..') continue;
				if (ftp_size($conn_id, $dst_dir.'/'.$st_file) == -1)
				{
					$this->ftp_rmAll($conn_id,  $dst_dir.'/'.$st_file);
				} 
				else 
				{
					ftp_delete($conn_id,  $dst_dir.'/'.$st_file);
				}
			}
		}
		$flag = ftp_rmdir($conn_id, $dst_dir); // delete empty directories
		return $flag;
	}

	public function publishViaFTP($exportsettings, $republish = false)
	{
		
		$userid = $this->getUserId();
		$projectid = $this->getProjectId();
		$data = $this->loadProjectData();
		
		if ($republish)
		{
			$this->unpublishViaFTP($exportsettings);
		}
		$protect = false;
		$this->userdata->saveExportSettings($exportsettings);
		$theme = (strlen($exportsettings['styleTemplate'])) ? $exportsettings['styleTemplate'] : 'default';
		$theme = "default";
		$udata = $this->userdata->getUserdata();
		$ftp_server = $udata['preferences']['publish']['FTPServer']; 
		$username = $udata['preferences']['publish']['FTPUsername']; 
		$password = $udata['preferences']['publish']['FTPPassword']; 
		$rootpath = $udata['preferences']['publish']['FTPDataDir'];
		if (substr($rootpath, -1) !== '/') $rootpath .= '/';
		$rootpath .= $projectid;   
		$connection_id = ftp_connect($ftp_server);   
		$login_result = ftp_login($connection_id, $username, $password);   
		if ((!$connection_id) || (!$login_result)) 
		{ 
			echo "<H1>Ftp-Verbindung nicht hergestellt!<H1>"; 
			echo "<P>Verbindung mit ftp_server als Benutzer 
			$username nicht möglich!</P>"; die; 
		} 
		else 
		{ 
		}   
		$result = ftp_chdir($connection_id, $rootpath);
		if ($result)
		{
			// delete all
			$this->ftp_rmAll($connection_id, $rootpath);
		}
		$result = ftp_mkdir($connection_id, $rootpath);
		if (!$result)
		{
			return array('result' => false, 'error' => 'The directory already exists'); 
		}
		ftp_mkdir($connection_id, $rootpath . '/images');
		ftp_mkdir($connection_id, $rootpath . '/thumbs');
		ftp_mkdir($connection_id, $rootpath . '/audio');
		ftp_mkdir($connection_id, $rootpath . '/config');
		ftp_mkdir($connection_id, $rootpath . '/css');
		ftp_put($connection_id, $rootpath . '/css/style.css', './themes/' . $theme . '/css/style.css', FTP_BINARY);
		ftp_mkdir($connection_id, $rootpath . '/icons');
		$nodes = glob('./themes/' . $theme . '/icons' . '/*'); 
		foreach ($nodes as $node) 
		{ 
			if (is_file($node))  
			{ 
				ftp_put($connection_id, $rootpath . '/icons/' . basename($node), $node, FTP_BINARY);
			} 
		} 
		ftp_mkdir($connection_id, $rootpath . '/js');
		$nodes = glob('./js/*'); 
		foreach ($nodes as $node) 
		{ 
			if (is_file($node))
			{ 
				ftp_put($connection_id, $rootpath . '/' . $node, $node, FTP_BINARY);
			} 
		}
		ftp_mkdir($connection_id, $rootpath . '/js/jme');
		$nodes = glob('./js/jme/*'); 
		foreach ($nodes as $node) 
		{ 
			if (is_file($node))
			{ 
				ftp_put($connection_id, $rootpath . '/' . $node, $node, FTP_BINARY);
			} 
		}
		$imageformat = (strlen($exportsettings['width'])) ? $exportsettings['width'] : "1024";
		foreach ($data['data']['slides'] as $idx => $filedata)
		{
			if (array_key_exists('file', $filedata) && strlen($filedata['file'])) 
			{
				$filepath = $this->projectpath . $data['path'] . "/$imageformat/" . $filedata['file'];
				if (@file_exists($filepath))
				{
					ftp_put($connection_id, $rootpath . '/images/' . $filedata['file'], $filepath, FTP_BINARY);
				}
				$thumbpath = $this->projectpath . $data['path'] . "/thumbs/" . $filedata['file'];
				if (@file_exists($thumbpath))
				{
					ftp_put($connection_id, $rootpath . '/thumbs/' . $filedata['file'] . ".thumb.jpg", $thumbpath, FTP_BINARY);
				}
			}
		}
		$audiotrack = $data['data']['meta']['audio'];
		if (is_array($audiotrack) && strlen($audiotrack['file']) > 0) 
		{
			$audiopath = $this->projectpath . $data['path'] . "/" . $audiotrack['file'];
			if (@file_exists($audiopath))
			{
				ftp_put($connection_id, $rootpath . '/audio/' . $audiotrack['file'], $audiopath, FTP_BINARY);
			}
		}

		$projectdata['slideshow'] = $exportsettings;

		$f = $this->createTempFileWithContent(json_encode($projectdata));
		ftp_put($connection_id, $rootpath . '/config/jsonconfig.js', $f, FTP_BINARY);
		unlink($f);

		ftp_quit($connection_id);
		return array('result' => true);
	}
	
	function isPublished($exportsettings, $serverpath = '')
	{
		if (strlen($serverpath))
		{
			// check local
			if (substr($serverpath, -1) !== '/') $serverpath .= '/';
			$serverpath .= $this->getProjectId();
			if (is_dir($serverpath))
			{
				return array('result' => true);
			}
		}
		else
		{
			// check via ftp
			$udata = $this->userdata->getUserdata();
			$ftp_server = $udata['preferences']['publish']['FTPServer']; 
			$username = $udata['preferences']['publish']['FTPUsername']; 
			$password = $udata['preferences']['publish']['FTPPassword']; 
			$rootpath = $udata['preferences']['publish']['FTPDataDir'];
			if (substr($rootpath, -1) !== '/') $rootpath .= '/';
			$rootpath .= $this->getProjectId();   
			$connection_id = ftp_connect($ftp_server);   
			$login_result = ftp_login($connection_id, $username, $password);   
			if ((!$connection_id) || (!$login_result)) 
			{ 
				echo "<H1>Ftp-Verbindung nicht hergestellt!<H1>"; 
				echo "<P>Verbindung mit ftp_server als Benutzer 
				$username nicht möglich!</P>"; die; 
			} 
			else 
			{ 
			}   
			$result = ftp_chdir($connection_id, $rootpath);
			ftp_quit($connection_id);
			if ($result)
			{
				return array('result' => true);
			}
		}
		return array('result' => false);
	}
	
	function createTempFileWithContent($content)
	{
		$settings = tempnam("/tmp", 'ht_');
		$filePointer = fopen($settings, "w+");
		fputs($filePointer, $content);
		fclose($filePointer);
		return $settings;
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
	
	public function unpublishLocal($exportsettings, $serverpath)
	{
		if (substr($serverpath, -1) !== '/') $serverpath .= '/';
		$serverpath .= $this->getProjectId();   
		if (is_dir($serverpath))
		{
			if (!$this->deleteDirectory($serverpath))
			{
				return array('result' => false);
			}
		}
		return array('result' => true);
	}
	
	public function unpublishViaFTP($exportsettings)
	{
		$udata = $this->userdata->getUserdata();
		$ftp_server = $udata['preferences']['publish']['FTPServer']; 
		$username = $udata['preferences']['publish']['FTPUsername']; 
		$password = $udata['preferences']['publish']['FTPPassword']; 
		$rootpath = $udata['preferences']['publish']['FTPDataDir'];
		if (substr($rootpath, -1) !== '/') $rootpath .= '/';
		$rootpath .= $this->getProjectId();   
		$connection_id = ftp_connect($ftp_server);   
		$login_result = ftp_login($connection_id, $username, $password);   
		if ((!$connection_id) || (!$login_result)) 
		{ 
			echo "<H1>Ftp-Verbindung nicht hergestellt!<H1>"; 
			echo "<P>Verbindung mit ftp_server als Benutzer 
			$username nicht möglich!</P>"; die; 
		} 
		else 
		{ 
		}   
		$result = $this->ftp_rmAll($connection_id, $rootpath);
		return array('result' => $result);
	}
		
	private function loadProjectData($projectid = 0) 
	{
		
		if (!$projectid) $projectid = $this->getProjectId();

		if ($this->isMember($projectid) || $this->isOwner($projectid)) {
			try 
			{
				$userid = $this->getUserId();
				$stmt = $this->dbh->prepare("SELECT * FROM t_project WHERE (t_project.id=:projectid)");
			//	$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
				$stmt->bindParam(':projectid', $projectid, PDO::PARAM_INT);
				$stmt->execute();
				$result = $stmt->fetch(PDO::FETCH_ASSOC);
				$result['data'] = unserialize($result['data']);
				return $result;
			} catch (PDOException $e) {
				return null;
			}	
		} else {
			return null;
		}	
	}
	
	private function updateProjectWithData($data)
	{
		$projectid = $this->getProjectId();
		if ($this->isMember($projectid) || $this->isOwner($projectid)) {
			try {
	
				$userid = $this->getUserId();
				$stmt = $this->dbh->prepare("UPDATE t_project SET data=:data, lastchange=:lastchange,lasteditor=:userid WHERE (id=:projectid)");
				$stmt->bindParam(':projectid', $projectid, PDO::PARAM_INT);
				$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
				$stmt->bindParam(':lastchange', time(), PDO::PARAM_INT);
				$stmt->bindParam(':data', serialize($data['data']), PDO::PARAM_STR, strlen(serialize($data['data'])));
	    		$stmt->execute();
				return true;
			} catch (PDOException $e) {
				return false;
			}	
		} else {
			return false;
		}	
	}
	
	public function loadProject($projectid, $distributeslides = 0)
	{
		$userid = $this->getUserId();
		if (!$projectid) return false;
		if ($distributeslides)
		{
			$data = $this->loadProjectData($projectid);
			$_SESSION['project_id'] = $data['id'];
			$slidecount = count($data['data']['slides']);
			$playtime = $data['data']['length'];
			
			foreach ($data['data']['slides'] as $idx => $slidedata) {
				$data['data']['slides'][$idx]['length'] = $playtime / $slidecount;
				if (array_key_exists('transition', $slidedata) && $slidedata['transition']['length'] > $playtime / $slidecount)
				{
					$data['data']['slides'][$idx]['transition']['length'] = $playtime / $slidecount;
				}
			}
			//update
			$this->updateProjectWithData($data);
		}
		$result = $this->loadProjectData($projectid);
		$_SESSION['project_id'] = $result['id'];
		return $result;
	}
	
	public function getAvailableProjectsAsArray()
	{
		$dataDict = $this->getAvailableProjects();
		$dataArray = array();
		$retDict = array();
		foreach ($dataDict as $key => $value) {
			array_push($dataArray,$value);
		}
		$retDict['data'] = $dataArray;
		return $retDict;
	}
		

	public function getAvailableProjects($shared = false)
	{
		$result = array();
		try {
			$stmt = null;
			if (!$shared) {	
				$stmt = $this->dbh->prepare("SELECT * FROM t_project WHERE userid = :userid ORDER by lastchange DESC");
			} else {
				$stmt = $this->dbh->prepare("SELECT *,t_project.created AS created,t_project.id AS id FROM t_project LEFT JOIN t_projectuser ON t_project.id=t_projectuser.projectid WHERE (t_projectuser.userid=:userid) ORDER by lastchange DESC");
			}
			$userid = $this->getUserId();
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
		    $stmt->execute();
			$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
			
			for ($i=0;$i<count($result);$i++) {
				//check for shared
				if (!$shared) {
					$stmt2 = $this->dbh->prepare("SELECT userid FROM t_projectuser WHERE projectid = :projectid");
					$stmt2->bindParam(':projectid', $result[$i]['id'], PDO::PARAM_INT);
				 	$stmt2->execute();
					$result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);
					if (count($result2)>0) {
						$result[$i]['shared'] = true;
					} else {
						$result[$i]['shared'] = false;	
					}
				} else {
					$result[$i]['shared'] = false;	
				}
				
				$data = unserialize($result[$i]['data']);
				if (count($data['slides'])>0) {
					$result[$i]['thumbnail'] = $data['slides'][0]['file'];
				}
				$result[$i]['slidecount'] = count($data['slides']);
				$result[$i]['duration'] = $data['length'];
				$udata = $this->userdata->getUserdataForId($result[$i]['lastEditor']);
				$result[$i]['lastusername'] = $udata['username'];
				$result[$i]['lastname'] = $udata['firstname']." ".$udata['lastname'];
				unset($result[$i]['data']);
			}
			
			return $result;
			
		} catch (PDOException $e) {
			return false;
		}
	}
	
	public function searchUsers($searchString) {
		if ($searchString == "") {
			return false;
		}
		try {
			$userid = $this->getUserId();
			$stmt = $this->dbh->prepare("SELECT username,id,firstname,lastname FROM t_user 
				WHERE ( 
					((lower(username) LIKE :searchString) OR (lower(email) LIKE :searchString) OR (lower(firstname) LIKE :searchString) OR (lower(lastname) LIKE :searchString)) AND (id <> :userid))");
			$searchString = $searchString."%";
			$stmt->bindParam(':searchString', $searchString, PDO::PARAM_STR,strlen($searchString));
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
		    $stmt->execute();
			$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
			return $result;
			
		} catch (PDOException $e) {
			return false;
		}
	}
	
	public function loadTeamMembers($projectid) {
		try {
			$stmt = $this->dbh->prepare("SELECT username,userid,projectid,firstname,lastname FROM t_projectuser,t_user WHERE (projectid = :projectid AND t_user.id = t_projectuser.userid)");
			$stmt->bindParam(':projectid', $projectid, PDO::PARAM_INT);
		    $stmt->execute();
			$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
			return $result;
		} catch (PDOException $e) {
			return false;
		}
	}
	
	private function userAssignedForPorject($userid,$projectid) {
		try {
			
			$stmt = $this->dbh->prepare("SELECT * FROM t_projectuser WHERE(userid = :userid AND projectid = :projectid)");
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
			$stmt->bindParam(':projectid', $projectid, PDO::PARAM_INT);
			$stmt->execute();
			$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
			if (count($result)>0) {
				return true;
			} else {
				return false;
			}
		}  catch (PDOException $e) {
			return false;
		}
	}
	
	public function addTeamMember($userid,$projectid) {
		if ($this->userAssignedForPorject($userid,$projectid)) {
			return $this->loadTeamMembers($projectid);
		}
		try {
			$stmt = $this->dbh->prepare("INSERT INTO t_projectuser (userid,projectid,created) values (:userid,:projectid,:created)");
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
			$stmt->bindParam(':projectid', $projectid, PDO::PARAM_INT);
			$stmt->execute();
			return $this->loadTeamMembers($projectid);
		} catch (PDOException $e) {
			return false;
		}
	}
	
	public function deleteTeamMember($userid,$projectid) {
		try {
			$stmt = $this->dbh->prepare("DELETE FROM t_projectuser WHERE(userid = :userid AND projectid = :projectid)");
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
			$stmt->bindParam(':projectid', $projectid, PDO::PARAM_INT);
			$stmt->execute();
			return $this->loadTeamMembers($projectid);
		} catch (PDOException $e) {
			return false;
		}
	}
	
	
	public function renameProject($projectname, $projectid)
	{
		$userid = $this->getUserId();
		if (!$projectid) return false;
		try {
			$stmt = $this->dbh->prepare("UPDATE t_project SET project = :projectname WHERE(userid = :userid AND id = :projectid)");
			
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
			$stmt->bindParam(':projectid', $projectid, PDO::PARAM_INT);
			$stmt->bindParam(':projectname', $projectname, PDO::PARAM_STR,strlen($projectname));
			if ($stmt->execute()) {
				return $this->getAvailableProjectsAsArray();
			} else {
				return false;
			}
		} catch (PDOException $e) {
			return false;
		}	
		
	}
	
	public function copyProject($projectname, $projectid)
	{
		$userid = $this->getUserId();
		$data = $this->loadProjectData($projectid);
		
		if ($data) {
			try {
				$newpathid = md5(time());
				$newpath = "projects/".$newpathid;
				$stmt = $this->dbh->prepare("INSERT INTO t_project (project,userid,path,created,lastchange,lasteditor,data) values (:project,:userid,:path,:created,:lastchange,:userid,:data)");
				$stmt->bindParam(':project', $projectname, PDO::PARAM_STR,strlen($projectname));
				$stmt->bindParam(':path', $newpath, PDO::PARAM_STR,strlen($newpath));
				$stmt->bindParam(':userid', $data['userid'], PDO::PARAM_INT);
				$stmt->bindParam(':created', time(), PDO::PARAM_INT);
				$stmt->bindParam(':lastchange', time(), PDO::PARAM_INT);
				$stmt->bindParam(':data', serialize($data['data']), PDO::PARAM_STR,strlen(serialize($data['data'])));
				$this->recurse_copy($this->projectpath.$data['path'],$this->projectpath.$newpath);
				if (is_dir($this->projectpath.$newpath)) {
					if ($stmt->execute()) {
						return $this->getAvailableProjectsAsArray();
					} else {
						return false;
					}
				} else {
					return false;
				}				
			} catch (PDOException $e) {
				return false;
			}

		} else {
			return false;
		}
	}


	//Helper
	private function recurse_copy($src,$dst) { 
   	 $dir = opendir($src); 
	    @mkdir($dst); 
	    while(false !== ( $file = readdir($dir)) ) { 
	        if (( $file != '.' ) && ( $file != '..' )) { 
	            if ( is_dir($src . '/' . $file) ) { 
	                $this->recurse_copy($src . '/' . $file,$dst . '/' . $file); 
	            } 
	            else { 
	                copy($src . '/' . $file,$dst . '/' . $file); 
	            } 
	        } 
	    } 
	    closedir($dir); 
	}
	 
	function bytehelper($byte1, $byte2)
	{
		$byte1 = hexdec(bin2hex($byte1));                        
		$byte2 = hexdec(bin2hex($byte2));                        
		return ($byte1 + ($byte2*256));
	}

		/**
		* Great function slightly modified as posted by Minux at
		* http://forums.clantemplates.com/showthread.php?t=133805
	*/
	function html2rgb($input) 
	{
		$input=($input[0]=="#")?substr($input, 1,6):substr($input, 0,6);
		return array(
		hexdec( substr($input, 0, 2) ),
		hexdec( substr($input, 2, 2) ),
		hexdec( substr($input, 4, 2) )
		);
	}

	function generateWaveform($filedir, $mp3_file)
	{
		global $lame_path;
		
	  // temporary file name
	  $tmpname = $filedir . substr(md5(time()), 0, 10);

	  // copy from temp upload directory to current
	  copy($filedir . $mp3_file, "{$tmpname}_o.mp3");
	  /**
	   * convert mp3 to wav using lame decoder
	   * First, resample the original mp3 using as mono (-m m), 16 bit (-b 16), and 8 KHz (--resample 8)
	   * Secondly, convert that resampled mp3 into a wav
	   * We don't necessarily need high quality audio to produce a waveform, doing this process reduces the WAV
	   * to it's simplest form and makes processing significantly faster
	   */
		$cmd1 = "${lame_path} {$tmpname}_o.mp3 -f -m m -b 16 --resample 8 {$tmpname}.mp3";
	  $out = shell_exec($cmd1);
		$cmd2 = "${lame_path} --decode {$tmpname}.mp3 {$tmpname}.wav";
		$out = shell_exec($cmd2);

	  $filename = "{$tmpname}.wav";

	  // delete temporary files
	  @unlink("{$tmpname}_o.mp3");
	  @unlink("{$tmpname}.mp3");

	  if (!file_exists($filename)) return "";

	  /**
	   * Below as posted by "zvoneM" on
	   * http://forums.devshed.com/php-development-5/reading-16-bit-wav-file-318740.html
	   * as bytehelper() defined above
	   */
	  $handle = fopen ($filename, "r");
	  //dohvacanje zaglavlja wav datoteke
	  $zaglavlje[] = fread ($handle, 4);
	  $zaglavlje[] = bin2hex(fread ($handle, 4));
	  $zaglavlje[] = fread ($handle, 4);
	  $zaglavlje[] = fread ($handle, 4);
	  $zaglavlje[] = bin2hex(fread ($handle, 4));
	  $zaglavlje[] = bin2hex(fread ($handle, 2));
	  $zaglavlje[] = bin2hex(fread ($handle, 2));
	  $zaglavlje[] = bin2hex(fread ($handle, 4));
	  $zaglavlje[] = bin2hex(fread ($handle, 4));
	  $zaglavlje[] = bin2hex(fread ($handle, 2));
	  $zaglavlje[] = bin2hex(fread ($handle, 2));
	  $zaglavlje[] = fread ($handle, 4);
	  $zaglavlje[] = bin2hex(fread ($handle, 4));

	  //bitrate wav datoteke
	  $peek = hexdec(substr($zaglavlje[10], 0, 2));
	  $bajta = $peek / 8;

	  //provjera da li se radi o mono ili stereo wavu
	  $kanala = hexdec(substr($zaglavlje[6], 0, 2));

	  if($kanala == 2){
	    $omjer = 40;
	  }
	  else{
	    $omjer = 80;
	  }

	  while(!feof($handle)){
	    $bytes = array();
	    //get number of bytes depending on bitrate
	    for ($i = 0; $i < $bajta; $i++){
	      $bytes[$i] = fgetc($handle);
	    }
	    switch($bajta){
	      //get value for 8-bit wav
	      case 1:
	          $data[] = $this->bytehelper($bytes[0], $bytes[1]);
	          break;
	      //get value for 16-bit wav
	      case 2:
	        if(ord($bytes[1]) & 128){
	          $temp = 0;
	        }
	        else{
	          $temp = 128;
	        }
	        $temp = chr((ord($bytes[1]) & 127) + $temp);
	        $data[]= floor($this->bytehelper($bytes[0], $temp) / 256);
	        break;
	    }
	    //skip bytes for memory optimization
	    fread ($handle, $omjer);
	  }

	  // close and cleanup
	  fclose ($handle);
	  unlink("{$tmpname}.wav");

	  /**
	   * Image generation
	   */

	  // how much detail we want. Larger number means less detail
	  // (basically, how many bytes/frames to skip processing)
	  // the lower the number means longer processing time
	  define("DETAIL", 5);

	  // get user vars from form
	  $width = 920*8;
	  $height = 45;
	  $foreground = "#333333";
	  $background = "#e4e4e4";

	  // create original image width based on amount of detail
	  $img = imagecreatetruecolor(sizeof($data) / DETAIL, $height);

	  // fill background of image
	  list($r, $g, $b) = $this->html2rgb($background);
	  imagefilledrectangle($img, 0, 0, sizeof($data) / DETAIL, $height, imagecolorallocate($img, $r, $g, $b));

	  // generate background color
	  list($r, $g, $b) = $this->html2rgb($foreground);

	  // loop through frames/bytes of wav data as genearted above
	  for($d = 0; $d < sizeof($data); $d += DETAIL) {
	    // relative value based on height of image being generated
	    // data values can range between 0 and 255
	    $v = (int) ($data[$d] / 255 * $height);
	    // draw the line on the image using the $v value and centering it vertically on the canvas
	    imageline($img, $d / DETAIL, 0 + ($height - $v), $d / DETAIL, $height - ($height - $v), imagecolorallocate($img, $r, $g, $b));
	  }

    $rimg = imagecreatetruecolor($width, $height);
    imagecopyresampled($rimg, $img, 0, 0, 0, 0, $width, $height, sizeof($data) / DETAIL, $height);
		$filename = str_replace('mp3', 'png', $mp3_file);
		$waveformimage = $filedir . $filename;
    imagepng($rimg, $waveformimage);
    imagedestroy($rimg);
		return $filename;
	}
}

?>