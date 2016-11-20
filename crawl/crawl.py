'''
Inserting index information into mongodb
This mongo data source will be the base data for all crawling operation
'''

import os
import setting
from mongodb import MongodbIndex
import codecs
from convert_json_to_text import Convert

class Crawl:
    def __init__(self):
        self.mongodb_index = MongodbIndex()

    def execute_scrapy(self):
        print('scrapy is executed')
        success = os.system('python ../new_scraper.py ' + setting.Setting.url_filepath_for_scrapy + setting.Setting.url_filename_for_scrapy)
        return success

    def create_url_for_scrapy_current(self):
        path = setting.Setting.url_filepath_for_scrapy
        filename = setting.Setting.url_filename_for_scrapy
        list_data = crawl.mongodb_index.get_top_url_from_current()
        with codecs.open(path + filename, "w", 'utf-8') as f:
            for data in list_data:
                f.write(data[0] + os.linesep)
            f.close()
        return list_data

    # This is executed only at once
    def crawl_prepare(self):
        self.mongodb_index.copy_to_current()
        #url_list = self.create_url_for_scrapy_current()
        #self.execute_scrapy()
        # TODO(hs2865) once scrapy output is fixed, proceed here. delete url_list from current


if __name__ == "__main__":
    crawl = Crawl()
    crawl.crawl_prepare()
    mongodb = MongodbIndex()
    list_data = crawl.create_url_for_scrapy_current()
    if len(list_data) != 0:
        success = crawl.execute_scrapy()
    else:
        pass
    if success == 0:
        # convert json to text to NAS
        for data in list_data:
            json_text = open(setting.scrapy_parsed_text_output, 'r')
            # ([d['url'], d['company'], d['year'], d['form_type'], d['data_filed'].replace("-", "_")])
            convert = Convert(json_text, data[1], data[2], data[3], data[4])
            convert.parse()
            convert.output("text")

