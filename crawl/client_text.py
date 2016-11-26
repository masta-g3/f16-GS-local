import json
import requests

url = "http://104.196.215.189:7777"
path = "/api/v1/gettext/" 

def get(cik):
    fullpath = url + path + str(cik)
    response = requests.get(fullpath)
    json_data = json.loads(response.text)
    return json_data
