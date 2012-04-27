<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>MMSlides Admin</title>

<!-- CSS -->
<link href="style/css/transdmin.css" rel="stylesheet" type="text/css" media="screen" />
<!--[if IE 6]><link rel="stylesheet" type="text/css" media="screen" href="style/css/ie6.css" /><![endif]-->
<!--[if IE 7]><link rel="stylesheet" type="text/css" media="screen" href="style/css/ie7.css" /><![endif]-->
<script type="text/javascript" src="style/js/jquery.js"></script>
<script type="text/javascript" src="style/js/jNice.js"></script>
<script type="text/javascript" src="media/js/jquery.dataTables.min.js"></script>

<!-- JavaScripts-->
</head>

<body>
	
	<div  class="centered">
	<div style="color:red">{$errormsg}</div>
	<form action="" class="jNice" method="post">
    
	{if $adminpw == true} 
	<table>
	<tr>
		<td><p><label>Enter admin password:</label></td><td><input type="password" name="password" class="text-long" /></p></td>
	</tr>
	<tr>
	<td colspan ="2" align="right"><p>	<input type="submit" value="Login" /></p></td>
	</tr>
	</table>
	<input type="hidden" name="action" value="login">
	{else}
	<table>
	<tr>
		<td><p><label>Define admin password:</label></td><td><input type="password" name="password1" class="text-long" /></p></td>
	</tr>
		<td><p><label>Repeat admin password:</label></td><td><input type="password" name="password2" class="text-long" /></p></td>
	</tr>
	<tr>
		<td colspan ="2" align="right"><p><input type="submit" value="Continue" /></p></td>
	</tr>	
	</table>
	<input type="hidden" name="action" value="newpassword">
	{/if}
	</form>
	</div>
</body>

</html>