Parse.Cloud.define("userGroups", function(request, response) {
	var query = new Parse.Query("User");
	
	query.equalTo("objectId", request.params.objectId);

	query.first({
		success: function(user) {
			groupIds = user.get("groupIds");
			response.success(groupIds);
		},
		error: function() {
			response.error("No convos found for this user");
		}
	});
});

