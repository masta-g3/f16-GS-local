'''
Inserting index information into mongodb
This mongo data source will be the base data for all crawling operation
'''

import os
import setting
from mongodb import MongodbIndex
import codecs

class Crawl:
    def __init__(self):
        self.mongodb_index = MongodbIndex()

    def execute_scrapy(self):
        print 'scrapy is executed'
        pass

    def create_url_for_scrapy_current(self):
        path = setting.Setting.url_filepath_for_scrapy
        filename = setting.Setting.url_filename_for_scrapy
        list = crawl.mongodb_index.get_top_url_from_current()
        with codecs.open(path + filename, "w", 'utf-8') as f:
            for l in list:
                f.write(l + os.linesep)
            f.close()
        return list

    def year_crawl_my(self, year):
        keyword = {"year": year}
        self.mongodb_index.copy_to_mycurrent(keyword)

    def year_crawl_all(self, year):
        keyword = {"year": year}
        self.mongodb_index.copy_to_current(keyword)
        url_list = self.create_url_for_scrapy_current()
        self.execute_scrapy()
        # TODO(hs2865) once scrapy output is fixed, proceed here. delete url_list from current


if __name__ == "__main__":
    crawl = Crawl()
    crawl.year_crawl_all("2015")
    #print crawl.mongodb_index.get_top_url_from_current(5)

    '''
    # example of designating individual cik
    keyword = {"cik": "1444144"}
    crawl = Crawl()
    crawl.crawl_begin_mycurrent(keyword)
    keyword = {"cik": "910638"}
    crawl.crawl_add_mycurrent(keyword)
    '''