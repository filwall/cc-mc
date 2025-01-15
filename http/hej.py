import requests

url = "http://172.232.147.44:8090"  # Byt ut <minecraft-ip> mot IP:n till Minecraft-servern eller datorns IP.
message = "hej från Python"

try:
    response = requests.post(url, data=message)
    print(f"Server svarade: {response.text}")
except Exception as e:
    print(f"Kunde inte ansluta till servern: {e}")

