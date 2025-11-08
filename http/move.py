import requests

# Byt ut med turtlens IP-adress eller använd 'localhost' om den kör på samma maskin
turtle_url = "http://172.232.147.44:8000/move"

# Skicka JSON-data för att be turtlen att röra sig framåt
payload = {"action": "move", "direction": "forward"}

# Skicka POST-begäran
response = requests.post(turtle_url, json=payload)

# Kontrollera svar
if response.status_code == 200:
    print("Response:", response.json())
else:
    print("Failed:", response.status_code, response.text)

