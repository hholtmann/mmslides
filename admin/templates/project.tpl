 {include file="header.tpl" title="Hauptseite"}
 {include file="leftnav_admin.tpl"}

	<script>
	$(document).ready(function() {
	    $('#usertable').dataTable(
			{
				"sPaginationType": "full_numbers",
				"aaSorting": [[ 2, "desc" ]]
			}
		);
	} );
	function deleteProject(id,name) {
		var answer = confirm("Do you want to delete the project "+name+" ?");
			if (answer){
				window.location.href = 'index.php?action=deleteproject&id='+id;
			}
	}
	</script>

<h2><a href="#">Administration</a> &raquo; <a href="#" class="active">Projects</a></h2>


                <div id="main">
					<h3>Project List</h3>
				<table border=1 width="85%" id="usertable" class="display">
				<thead>	
				<tr>
					<th>Project</th><th>Owner</th><th>Last Edited</th><th>Action</th>
				</tr>
				</thead>
				<tbody>
        		{foreach key=cid item=con from=$result}
				<tr>
			    	<td>{$con.project|truncate:30:"..":true:true}</td> 
					<td><a class="tablelink" href="index.php?action=edituser&id={$con.userid}">{$con.lastname}, {$con.firstname}</a> </td> <td>{$con.last}</td>
					<td width="40"><a href="#" onclick="deleteProject({$con.projectid},'{$con.project}')"><img title="Delete" alt="Delete" src="style/img/icons/delete.png"/></a>&nbsp;&nbsp;<a class="tablelink" href="index.php?action=files&id={$con.projectid}">Files>></a></td>
				</tr>
				{/foreach}
				</tbody>
				<tfoot>	
				<tr>
					<th>Project</th><th>Owner</th><th>Last Edited</th><th>Action</th>
				</tr>
				</tfoot>
				</table>
                </div>
                <!-- // #main -->

{include file="footer.tpl"}