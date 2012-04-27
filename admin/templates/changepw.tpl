 {include file="header.tpl" title="Hauptseite"}
 {include file="leftnav_admin.tpl"}

		<script>

		</script>

		<h2><a href="#">Administration</a> &raquo; <a href="#">Change Password</a></h2>
		                <div id="main">
		                	<form action="" class="jNice" method="post">
							<h3>Change Administrator Password</h3>
		                    	<fieldset>
		                        	<p><label>New Password:</label><input type="password" name="password1" class="text-long" value="" /></p>
		                        	<p><label>Password Repeat:</label><input type="password" name="password2" class="text-long" value="" /></p>
									<p style="color:red;"> 
										{$errors}
									</p>
		                            <input type="submit" value="Change" />
									<input type="hidden" name="action" value="updatepassword">
		                        </fieldset>
		                    </form>
		                </div>
		                <!-- // #main -->

{include file="footer.tpl"}