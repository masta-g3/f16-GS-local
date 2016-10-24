'''
Setting information for crawler
'''
from socket import gethostname

class Setting:
    crawler_index_file_path = 'C:\\Users\\HS\\Desktop\\school\\classes\\CAPSTONE\\system\\test_app\\file\\'
    csv_path = 'C:\\Users\\HS\\Desktop\\school\\classes\\CAPSTONE\\system\\test_app\\csv\\'
    mongodb_host = '127.0.0.1'
    mongodb_port = 27017
    hostname = gethostname()
    url_filepath_for_scrapy = 'C:\\Users\\HS\\Desktop\\school\\classes\\CAPSTONE\\system\\scrapy\\url\\'
    url_filename_for_scrapy = 'url_list.txt'

    def __init__(self):
        # Change "input_path", "output_path" accordingly
        # Store index file for crawler under "input_path"
        pass

