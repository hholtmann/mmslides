 {include file="header.tpl" title="Hauptseite"}
 {include file="leftnav_admin.tpl"}

		<script>

		</script>

		<h2><a href="#">Administration</a> &raquo; <a href="index.php?action=user">User</a> &raquo; <a href="#" class="active">Edit User</a></h2>
		                <div id="main">
		                	<form action="" class="jNice" method="post">
							<h3>Edit User "{$username}"</h3>
		                    	<fieldset>
		                        	<p><label>Username:</label><input type="text" disabled name="username" class="text-long" value="{$username}" /></p>
		                        	<p><label>Firstname:</label><input type="text" name="firstname" class="text-long" value="{$firstname}" /></p>
		                        	<p><label>Lastname:</label><input type="text" name="lastname" class="text-long" value="{$lastname}" /></p>
		                        	<p><label>Email:</label><input type="text" name="email" class="text-long" value="{$email}" /></p>
		                        	<p><label>Telephone:</label><input type="text" name="telephone" class="text-long" value="{$telephone}" /></p>
		                        	<p><label>Organization:</label><input type="text" name="organization" class="text-long" value="{$organization}" /></p>
									<p><label>Approved/Enabled:</label><input type="checkbox" name="approved" value="ON" {$approved} /></p>
									<p style="color:red;"> 
										{$errors}
									</p>
		                            <input type="submit" value="Save" />
									<input type="hidden" name="action" value="updateuser">
									<input type="hidden" name="id" value="{$userid}">
		                        </fieldset>
		                    </form>
		                </div>
		                <!-- // #main -->

{include file="footer.tpl"}