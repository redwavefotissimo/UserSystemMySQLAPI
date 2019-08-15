<%@include file="COMMON/header.jsp" %>
<%= request.getContextPath() %>
<table id="userListTable"  style="width:100%" >
	<thead>
		<tr>
			<th data-sortable="true" data-field="firstName">First Name</th>
			<th data-sortable="true" data-field="lastName">Last Name</th>
			<th data-sortable="true" data-field="userName">User Name</th>
			<th data-field="profileFolderId">Profile Folder id</th>
			<th data-field="attachementFolderId">Attachment Folder id</th>
			<th data-field="profileId">Profile id</th>
		</tr>
	</thead>
</table>
<script>
$(document).ready(function() {
    $('#userListTable').bootstrapTable({
        pagination: true,
        search: true,
        sidePagination: 'server',
        pageSize: 2,
        pageList: [1,2,3,4],
        showButtonIcons: true,
        sortStable : true,
        url: '/ListUserServer.jsp'
     });
} );
</script>
<%@include file="COMMON/footer.jsp" %>