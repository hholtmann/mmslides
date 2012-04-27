 {include file="header.tpl" title="Hauptseite"}
 {include file="leftnav_admin.tpl"}

		<script>

		</script>

		<h2><a href="#">Administration</a> &raquo; <a href="#">User Agreement</a></h2>
		                <div id="main">
		                	<form action="" class="jNice" method="post">
							<h3>Change User Agreement</h3>
		                    	<fieldset>
									<p><label>User Agreement:</label>
									<textarea rows="35" cols="120" name="agreement">{$agreement}</textarea>
									</p>
									<p style="color:green;"> 
										{$message}
									</p>
		                            <input type="submit" value="Change" />
									<input type="hidden" name="action" value="updateagreement">
		                        </fieldset>
		                    </form>
		                </div>
		                <!-- // #main -->

{include file="footer.tpl"}