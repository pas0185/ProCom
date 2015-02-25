
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
	response.success("Hello world!");
});

Parse.Cloud.define("userConvos", function(request, response) {
	var query = new Parse.Query("User");
	
	query.equalTo("objectId", request.params.objectId);

	query.first({
		success: function(user) {
			convoIds = user.get("convoIds");
			response.success(convoIds);
		},
		error: function() {
			response.error("No convos found for this user");
		}
	});
});