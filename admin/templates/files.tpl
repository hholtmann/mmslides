 {include file="header.tpl" title="Hauptseite"}
 {include file="leftnav_admin.tpl"}

	
		<h2><a href="#">Administration</a> &raquo; <a href="index.php?action=projects">Projects</a> &raquo; <a href="#" class="active">{$result[0].project} / Files</a></h2>

                <div id="main">
					<h3>File List</h3>
				<br/>
				<table border=1 width="85%" id="usertable" class="display">
				<thead>	
				<tr>
					<th>Thumb</th><th>IP</th><th>Caption</th>
				</tr>
				</thead>
				<tbody>
        		{foreach key=cid item=slide from=$slides}
				<tr>
			    	<td>
				<img src="../server/{$result[0].path}/thumbs/{$slide.file}" /></td><td>{$slide.ip}</td><td>{$slide.caption}</td>
				</tr>
				{/foreach}
				</tbody>
			
				</table>
                </div>
                <!-- // #main -->

{include file="footer.tpl"}