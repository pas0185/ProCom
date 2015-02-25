Parse.Cloud.define("userConvos", function(request, response) {

	// Get the User by its objectId
	var qUser = new Parse.Query("User");
	qUser.equalTo("objectId", request.params.objectId);

	var qConvo = new Parse.Query("Convo");

	qUser.first({
		success: function(user) {
			convoIds = user.get("convoIds");
			response.success(convoIds);
	});
});