'''
Getting related file by inputting CIK
'''

import os
import sys
import getopt
import optparse
import json
import glob
import datetime
from bs4 import BeautifulSoup
import requests
import codecs
import traceback
from convert_json_to_text import Convert

class FileGet:

    def __init__(self, cik, year, category):
        self.cik = cik
        self.year = year
        self.type = category
	self.path = "/mnt/output/" + cik
        self.data = {self.cik : {}}
        self.missing = []
        self.url_filepath_for_scrapy = "/home/gs/files/scrapy/"
        self.url_filename_for_scrapy = "url_list.txt"
        self.nas_output = "/mnt/output/"
        self.missing_data = {}
        self.missing_info = []
        self.company = ""

    def check_company(self):
        company = glob.glob(self.path + os.sep + "*")
        if len(company) > 0:
            company = company[0]
            self.company = company.split("/")[-1]

    def check_missing(self):
        self.check_company()
        year_list = ["2011", "2012", "2013", "2014", "2015"]
        type_list = ["10-K"] # Add 10-Q if we would like to parse
        for year in year_list:
            tmp_path = glob.glob(self.path + os.sep + "*" + os.sep + year)
            if len(tmp_path) == 0:
                self.missing.append(year) 
                continue
            for t in type_list:
                tmp_path = glob.glob(self.path + os.sep + "*" + os.sep + year + os.sep + t)
                if len(tmp_path) == 0:
                    self.missing.append(year)
                    continue


    def create_url_for_top_10k(self, year):
        priorto = datetime.date(int(year) + 1, 1, 1)
        priorto = priorto.isoformat().replace("-", "") 
        base_url = "http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=" + self.cik + "&type=10-K&dateb=" + str(priorto) + "&owner=exclude&output=xml&count=10"
        return base_url


    def missing_prepare(self):
        for year in self.missing: # this time, at missing, only year will be inserted
            try:
                index_url = self.create_url_for_top_10k(year)
                [manage_url, unique] = self.get_manage_url_and_unique(index_url)
                actual_url = self.get_actual_url(manage_url)
                missing_tmp = [actual_url, self.company, year, "10-K", unique, self.cik]
                self.missing_info.append(missing_tmp)
                #print self.missing_info
            except:
                #e = sys.exc_info()[0]
                #print e
                exc_type, exc_value, exc_traceback = sys.exc_info()
                traceback.print_exception(exc_type, exc_value, exc_traceback)
                continue


    def missing_parse(self):
        list_data = self.missing_parse_helper()
        if len(list_data) != 0:
            path = self.url_filepath_for_scrapy
            filename = self.url_filename_for_scrapy
            success = os.system('python ../new_scraper.py ' + path + filename)
        else:
            return
        if success == 0:
            # convert json to text to NAS
            json_text = open('content.json', 'r')
            json_data = json.loads(json_text.read())
            self.missing_data = json_data
            json_keys = json_data.keys()
            for ind in range(len(list_data)):
                data = list_data[ind]
                # ([d['url'], d['company'], d['year'], d['form_type'], d['data_filed'].replace("-", "_")])
                try:
                    #print json_data[json_keys[ind]]
                    convert = Convert(json_data[json_keys[ind]], data[1], data[2], data[3], data[4], data[5])
                    convert.parse()
                    convert.output("text")
                except:
                    exc_type, exc_value, exc_traceback = sys.exc_info()
                    traceback.print_exception(exc_type, exc_value, exc_traceback)
                    continue
            logs = open('logs.csv', 'r').read()
            errors = open('errors.csv', 'r').read()
            self.log_output(errors, logs)
        else:
            print success

    def log_output(self, error, log):
        with codecs.open(self.nas_output + 'errors.csv', "a", 'utf-8') as f:
            f.write(error)
        f.close()
        with codecs.open(self.nas_output + 'logs.csv', "a", 'utf-8') as f:
            f.write(log)
        f.close()


    def missing_parse_helper(self):
        path = self.url_filepath_for_scrapy
        filename = self.url_filename_for_scrapy
        with codecs.open(path + filename, "w", 'utf-8') as f:
            for data in self.missing_info:
                f.write(data[0] + os.linesep)
            f.close()
        list_data = []
        return self.missing_info 

    def missing_insert(self):
        pass

    def get_actual_url(self, url):
        data = requests.get(url).text
        soup = BeautifulSoup(data)
        table = soup.find("table", attrs={"summary": "Document Format Files"})
        tr = table.find_all("tr")
        return "https://www.sec.gov" + tr[1].find("a").get("href")
 

    def get_manage_url_and_unique(self, url):
        data = requests.get(url).text
        soup = BeautifulSoup(data)
        filing = soup.find("filing")
        datefiled = filing.find("datefiled")
        filinghref = filing.find("filinghref")
        unique = datefiled.string.replace("-", "_")
        url = filinghref.string
        return [url, unique]


    def create_json_dir(self, json_data):
        if self.year in self.data[self.cik]:
            if self.type in self.data[self.cik][self.year]:
               self.data[self.cik][self.year][self.type][self.unique] = json_data
            else:
               pass
        else:
            pass

    def bfs(self, path):
        queue = []
        depth = []
        queue.append(path)
        depth.append(1)
        while len(queue) != 0:
            cur = queue.pop(0)
            d = depth.pop(0)
            if d == 7:
                continue
            if "output.json" in cur:
                json_text = open(cur, 'r').read().encode('utf-8')
                json_data = json.loads(json_text)
                p = cur.split(os.sep)
                unique = p[-2]
                t = p[-3]
                year = p[-4]
                self.data[self.cik][year][t][unique] = json_data
                continue
            if d == 3:
                year = cur.split(os.sep)[-1]
                if year not in self.data[self.cik]:
                    self.data[self.cik][year] = {}
            elif d == 4:
                p = cur.split(os.sep)
                t = p[-1]
                year = p[-2]
                if t not in self.data[self.cik][year]:
                    self.data[self.cik][year][t] = {}
            elif d == 5:
                p = cur.split(os.sep)
                unique = p[-1]
                t = p[-2]
                year = p[-3]
                self.data[self.cik][year][t][unique] = {}
            if d != 5:
                tmp_path = glob.glob(cur + os.sep + "*")
            else:
                tmp_path = glob.glob(cur + os.sep + "output.json")
            for p in tmp_path:
                queue.append(p)
                depth.append(d + 1)  

    def get_path(self):
        return self.path

    def get_data(self):
        return self.data

    def get_json(self):
        return json.dumps(self.data)

    def top_missing_operation(self):
        self.missing_prepare()
        self.missing_parse()
        self.missing_insert()

def get_modified_cik(cik):
    cik_str = str(cik)
    ind = 0
    while cik_str[ind] == '0':
        ind = ind + 1
    if ind >= len(cik_str):
        return ""
    cik_str = cik_str[ind : ] 
    return cik_str

def search_by_cik(cik):
    cik_str = get_modified_cik(cik)
    fileget = FileGet(cik_str, "", "")
    fileget.bfs(fileget.get_path())
    #fileget.check_missing()
    #if len(fileget.missing) != 0:
    #    fileget.top_missing_operation()
    return fileget.get_data()


def get_missing_by_cik(cik):
    cik_str = get_modified_cik(cik)
    fileget = FileGet(cik_str, "", "")
    fileget.bfs(fileget.get_path())
    fileget.check_missing()
    if len(fileget.missing) != 0:
        fileget.top_missing_operation()
        print "Getting missing files finished"
        return "Getting missing files finished" 
    else:
        print "There is no missing files"
        return "There is no missing files" 

def debug(tmp):
    for k1 in tmp:
        for k2 in tmp[k1]:
            for k3 in tmp[k1][k2]:
                for k4 in tmp[k1][k2][k3]:
                    #print k1 + " " + k2 + " " + k3 + " " + k4 + " " + str(len(tmp[k1][k2][k3][k4]))
                    print k1 + " " + k2 + " " + k3 + " " + k4


if __name__ == "__main__":
    get_missing_by_cik("1100412")
    #debug(search_by_cik("1100412"))    
    #print search_by_cik(1129260)
    #print search_by_cik(11)

    '''
    parser = optparse.OptionParser()
    parser.add_option('-c', '--cik',
                      dest="cik",
                      default="",
                      type="str"
                      )
    parser.add_option('-y', '--year',
                      dest="year",
                      default="",
                      type="str"
                      )
    parser.add_option('-t', '--type',
                      dest="type",
                      default="",
                      type="str"
                      )

    options, reminder = parser.parse_args()
    fileget = FileGet(options.cik, options.year, options.type)
    fileget.dfs(fileget.get_path(), 1)
    #print(fileget.get_data())
    fileget.debug(fileget.get_data())

    '''
