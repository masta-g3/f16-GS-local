'''
Setting information for crawler
'''
from socket import gethostname

class Setting:
    crawler_index_file_path = '/home/gs/files/file/'
    csv_path = '/home/gs/files/csv/'
    mongodb_host = '127.0.0.1'
    mongodb_port = 27017
    hostname = gethostname()
    url_filepath_for_scrapy = '/home/gs/files/scrapy/'
    url_filename_for_scrapy = 'url_list.txt'
    global_parsed_text_output = ''

    def __init__(self):
        # Change "input_path", "output_path" accordingly
        # Store index file for crawler under "input_path"
        pass


