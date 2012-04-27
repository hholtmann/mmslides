<?php

/*
 * SessionHandler.php
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


require_once "SqliteProvider.php";

class SessionHandler
{
	protected $sql;
	protected $dbh;
	private $user_id;

	function __construct($request) 
	{
		session_start();

		$this->sql = new SqliteProvider();
		$this->dbh = $this->sql->dbh;

		if (strlen($request['SID']) && $request['SID'] == session_id() && strlen($_SESSION['id']))
		{
			$this->user_id = $_SESSION['id'];
		}
		else
		{
			$this->user_id = false;
		}
	}

	public function getUserId()
	{
		return $this->user_id;
	}

	public function getProjectId()
	{
		if ($this->user_id)
		{
			if ($_SESSION['project_id'] > 0)
			{
				return $_SESSION['project_id'];
			}
		}
		return false;
	}
	
	protected function lastInsertId()
	{
		return $this->dbh->lastInsertId();
	}
}

?>