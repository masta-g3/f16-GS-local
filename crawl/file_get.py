'''
Getting related file by inputting CIK
'''

import os
import sys
import getopt
import optparse
import json
import glob
#from setting import Setting


class FileGet:

    def __init__(self, cik, year, category):
        self.cik = cik
        self.year = year
        self.type = category
	self.path = "/mnt/output/" + cik
        self.data = {self.cik : {}}
        '''
        year_list = ["2011", "2012", "2013", "2014", "2015"]
        type_list = ["10-K", "10-Q"]
        for year in year_list:
            self.data[self.cik][year] = {}
            for t in type_list:
                 self.data[self.cik][year][t] = {}
        self.unique = ""
        '''

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


    def dfs(self, path, depth):
        tmp_path = glob.glob(path + os.sep + "*")
        if len(tmp_path) == 0:
            return
        if depth == 3:
            self.year = path.split(os.sep)[-1]
        if depth == 4:
            self.type = path.split(os.sep)[-1]
        if depth == 5:
            self.unique = path.split(os.sep)[-1]
        for p in tmp_path:
            if "output.json" in p:
                json_text = open(p, 'r').read().encode('utf-8')
                json_data = json.loads(json_text)
                self.create_json_dir(json_data)
                return
        for p in tmp_path:
            self.dfs(p, depth + 1)
        if depth > 6: 
            return

    def get_path(self):
        return self.path

    def get_data(self):
        return self.data

    def get_json(self):
        return json.dumps(self.data)


def search_by_cik(cik):
    fileget = FileGet(str(cik), "", "")
    fileget.bfs(fileget.get_path())
    return fileget.get_data()


def debug(tmp):
    for k1 in tmp:
        for k2 in tmp[k1]:
            for k3 in tmp[k1][k2]:
                for k4 in tmp[k1][k2][k3]:
                    #print k1 + " " + k2 + " " + k3 + " " + k4 + " " + str(len(tmp[k1][k2][k3][k4]))
                    print k1 + " " + k2 + " " + k3 + " " + k4

if __name__ == "__main__":
    debug(search_by_cik(1129260))    
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
