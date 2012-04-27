 {include file="header.tpl" title="Hauptseite"}
 {include file="leftnav_admin.tpl"}

<h2><a href="#">Administration</a> &raquo; <a href="#" class="active">General</a></h2>


                <div id="main">
						<h3>Info</h3>
						<fieldset>
						<p><label>Number of Projects:</label>{$cproject}</p>
						<p><label>Number of Users:</label>{$cuser}</p>
						<p><label>E-Mail of Administrator:</label>{$admin_mail} &nbsp; <a href="index.php?action=setup">(Change)</a></p>
						<p><label>Password of Administrator:</label> <a href="index.php?action=changepassword">Change</a></p>
						</fieldset>
						<h3>General Settings</h3>
						<form action="index.php" method="post">
						<fieldset>
						<p><label>Auto-Approve new users:</label><input type="checkbox" name="auto_approve" value="ON" {$auto_approve} /></p>
                     	<input type="submit" value="Submit" name="Submit" />
						</fieldset>
						<input type="hidden" name="action" value="updategeneral">
					</form>
                </div>
                <!-- // #main -->
                
{include file="footer.tpl"}