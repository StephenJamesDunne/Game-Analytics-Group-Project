from flask import Flask
from flask_cors import CORS
from api_basic_upload import api_basic_upload

def create_app():
    app = Flask(__name__)
    app.secret_key = 'dev_key_only'
    
    # Enable CORS so Godot web builds aren't blocked by browsers
    CORS(app, resources={r"/*": {"origins": "*"}})
    
    app.register_blueprint(api_basic_upload)
    return app

if __name__ == "__main__":
    app = create_app()
    print("Server starting on http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)
