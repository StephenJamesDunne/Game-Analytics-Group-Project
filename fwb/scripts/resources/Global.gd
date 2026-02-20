extends Node

@onready var http_request: HTTPRequest = HTTPRequest.new()

func _ready():
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func send_analytics_data(level: int, time_taken: float):
	var url = "http://127.0.0.1:5000/upload_data"
	
	var data = {
		"level": level,
		"completion_time": time_taken,
		"platform": OS.get_name()
	}
	
	var json_query = JSON.stringify(data)
	
	var headers = ["Content-Type: application/json"]
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_query)
	
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_request_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("HTTP request failed with result: " + str(result))
		return
	
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result == OK:
		var response = json.get_data()
		print("Server Response: ", response)
	else:
		print("Failed to parse server response.")
