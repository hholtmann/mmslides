<?php

/*
 * http_request.php
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


class http_request
{
	var $add_headers = array('CONTENT_TYPE', 'CONTENT_LENGTH');
	
	function http_request($add_headers = false)
	{
		$this->retrieve_headers($add_headers);
		$this->body = @file_get_contents('php://input');
	}
	
	function retrieve_headers($add_headers = false)
	{
		if ($add_headers) 
		{
			$this->add_headers = array_merge($this->add_headers, $add_headers);
		}
		if (isset($_SERVER['HTTP_METHOD']))
		{
			$this->method = $_SERVER['HTTP_METHOD'];
			unset($_SERVER['HTTP_METHOD']);
		}
		else
		{
			$this->method = isset($_SERVER['REQUEST_METHOD']) ? $_SERVER['REQUEST_METHOD'] : false;
			$this->protocol = isset($_SERVER['SERVER_PROTOCOL'])? $_SERVER['SERVER_PROTOCOL'] : false;
			$this->request_method = isset($_SERVER['REQUEST_METHOD']) ? $_SERVER['REQUEST_METHOD'] : false;
			
			$this->headers = array();
			foreach ($_SERVER as $i => $val)
			{
				if (strpos($i, 'HTTP_') === 0 || in_array($i, $this->add_headers))
				{
					$name = str_replace(array('HTTP_', '_'), array('', '-'), $i);
					$this->headers[$name] = $val;
				}
			}
		}
	}
	
	function method()
	{
		return $this->method;
	}
	
	function body()
	{
		return $this->body;
	}
	
	function header($name)
	{
		$name = strtoupper($name);
		return isset($this->headers[$name]) ? $this->headers[$name] : false;
	}
	
	function headers()
	{
		return $this->headers;
	}
	
	function raw($refresh = false)
	{
		if (isset($this->raw) && !$refresh)
		{
			return $this->raw;
		}
		$headers = $this->headers();
		$this->raw = "($this->method)\r\n";
		foreach ($headers as $i => $header)
		{
			$this->raw .= "$i: $header\r\n";
		}
		$this->raw .= "\r\n(BODY: $this->body)";
		return $this->raw;
	}
}

?>