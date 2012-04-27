 {include file="header.tpl" title="Hauptseite"}
 {include file="leftnav_admin.tpl"}

		<script>
		$(document).ready(function() {
		    $('#usertable').dataTable(
				{
					"sPaginationType": "full_numbers",
					"aaSorting": [[ 5, "desc" ]]
				}
			);
		} );
		$('.delete').click(function(){
		  	var answer = confirm('Delete user');
		  	return answer // answer is a boolean
		});
		function deleteuser(id,name) {
			var answer = confirm("Do you want to delete the user "+name+" ?");
				if (answer){
					window.location.href = 'index.php?action=deleteuser&id='+id;
				}
		}
		</script>

<h2><a href="#">Administration</a> &raquo; <a href="#" class="active">User</a></h2>


                <div id="main">
					<h3>User List</h3>
				<table>
					<tr><td>
					<form>
						<input type="button" value="Export Users" onclick="window.location.href='index.php?action=exportusers'"/>
					</form>	
					</td>
					</tr>
				</table>
				<br/>
				<table border=1 width="85%" id="usertable" class="display">
				<thead>	
				<tr>
					<th>Enabled</th><th>Username</th><th>Lastname</th><th>Firstname</th><th>Organization</th><th>Registered</th><th>Action</th>
				</tr>
				</thead>
				<tbody>
        		{foreach key=cid item=con from=$result}
				<tr>
			    	<td width="20">{if $con.enabled==1} <img title="Approved" alt="Approved" src="style/img/icons/approved.png"/>{/if}</td>
					<td>{$con.username}</td> <td>{$con.lastname}</td> <td>{$con.firstname}</td><td>{$con.organization|truncate:20:"...":true}</td><td>{$con.registerd}</td>
					<td width="50"><a href="index.php?action=edituser&id={$con.id}"><img title="Edit" alt="Edit" src="style/img/icons/edit.png"/></a>&nbsp;&nbsp;
								   <a href="#" onclick="deleteuser({$con.id},'{$con.username}')"><img title="Delete" alt="Delete" src="style/img/icons/delete.png"/></a></td>
				</tr>
				{/foreach}
				</tbody>
			
				</table>
                </div>
                <!-- // #main -->

{include file="footer.tpl"}