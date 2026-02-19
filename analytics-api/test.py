import requests

def test_post_data():
    url = 'http://localhost:5000/upload_data'
    payload = {
        "completion_time": 2000,
        "level": 7,
        "engine": "Godot"
    }
    
    try:
        r = requests.post(url, json=payload)
        print(f"Status Code: {r.status_code}")
        print(f"Response Body: {r.json()}")
    except Exception as e:
        print(f"Connection failed: {e}")

if __name__ == "__main__":
    test_post_data()
