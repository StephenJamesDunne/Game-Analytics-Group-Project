from flask import Blueprint, request, jsonify, make_response
from pymongo import MongoClient
import os
import csv
from io import StringIO

api_basic_upload = Blueprint('api_basic_upload', __name__)

client = MongoClient(os.getenv("MONGO_URI", "mongodb://149.153.106.15:27017/analytics_db"))
db = client.get_database()
collection = db.game_events

@api_basic_upload.route('/upload_data', methods=['POST'])
def post_upload():
    try:
        data = request.get_json()
        
        # Insert into MongoDB
        result = collection.insert_one(data)
        
        return jsonify({
            "status": "success", 
            "id": str(result.inserted_id)
        })
    except Exception as e:
      return make_response(jsonify({"error": str(e)}), 500)
  
  
@api_basic_upload.route('/download_csv', methods=['GET'])
def download_csv():
    data = list(collection.find({}, {'_id': 0})) # Exclude Mongo ID
    
    if not data:
        return "No data found", 404

    output = StringIO()
    writer = csv.DictWriter(output, fieldnames=data[0].keys())
    writer.writeheader()
    writer.writerows(data)
    
    response = make_response(output.getvalue())
    response.headers["Content-Disposition"] = "attachment; filename=analytics.csv"
    response.headers["Content-type"] = "text/csv"
    return response
