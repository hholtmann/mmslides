 {include file="header.tpl" title="Hauptseite" configured=$configured}
 {include file="leftnav_setup.tpl"}

<h2><a href="#">Setup</a> &raquo; <a href="#" class="active">General</a></h2>


                <div id="main">
                	<form action="" class="jNice" method="post">
					<h3>Install Configuration</h3>
                    	<fieldset>
                        	<p><label>Web-Root (URL):</label><input type="text" name="webroot" class="text-long" value="{$webroot}" /></p>
                        	<p><label>Installation-Root (Path):</label><input type="text" name="installroot" class="text-long" value="{$installroot}" /></p>
                        	<p><label>Data-Path:</label><input type="text" name="datapath" class="text-long" value="{$datapath}" /></p>
                        	<p><label>ffmpeg Path:</label><input type="text" name="ffmpeg_path" class="text-long" value="{$ffmpeg_path}" /></p>
                        	<p><label>Lame Path:</label><input type="text" name="lame_path" class="text-long" value="{$lame_path}" /></p>
                        	<p><label>ImageMagick (Convert)-Path</label><input type="text" name="convert_path" class="text-long" value="{$convert_path}" /></p>
                        	<p><label>Mail of Administrator(s)</label><input type="text" name="admin_mail" class="text-long" value="{$admin_mail}" /></p>
	                       	<p><label>Enable Movie Export Feature:</label><input type="checkbox" value="ON" name="movie_exports" {$movie_exports} /></p>
							<p style="color:red;"> 
								{$errors}
							</p>
                            <input type="submit" value="Save" />
							<input type="hidden" name="action" value="updateconfig">
                        </fieldset>
                    </form>
                </div>
                <!-- // #main -->
                
{include file="footer.tpl"}