import json
import requests

url = "http://104.196.215.189:7777"
path = "/api/v1/gettext/" 
path_for_missing = "/api/v1/getmissingtext/"

def get(cik):
    fullpath = url + path + str(cik)
    response = requests.get(fullpath)
    json_data = json.loads(response.text)
    return json_data

def get_missing(cik):
    fullpath = url + path_for_missing + str(cik)
    response = requests.get(fullpath)
    json_data = json.loads(response.text)
    return json_data
