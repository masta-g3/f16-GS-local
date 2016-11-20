'''
Converting json format data outputted from Scrapy into text or mongodb.
'''

import json
import os
import codecs
import setting
import sys

class Convert:
    def __init__(self, json_data, company, year, category, unique, cik):
        # Convert json to python object
        self.data = json_data
        self.converted = {}
        self.company = str(company)
        self.year = str(year)
        self.category = str(category)
        self.unique = str(unique)
        self.cik = str(cik)

    def parse(self):
        for section in self.data:
            if section not in self.converted:
                self.converted[section] = []
            list_data = self.data[section]
            for l in list_data:
                self.converted[section].append(l)

    def output(self, mod):
        # At mode, we can designate "text" or "mongodb"
        # TODO(hs2865) Here, we need to get unique time value
        if len(self.converted) == 0:
            return

        if mod == "":
            return

        if mod == 'text':
            self.output_text()
        elif mod == 'mongodb':
            pass


    def output_text(self):
        # (ex) Netflix/2015/10-Q/201510061076
        basename = self.cik + os.sep + self.company + os.sep + self.year + os.sep +\
                   self.category + os.sep + self.unique + os.sep
        nas_dest = setting.Setting.nas_output
        basename = nas_dest + basename
        self.create_directory(basename)
        with codecs.open(basename + "output.json", "w", 'utf-8') as f:
            json.dump(self.data, f)
        f.close()
        
        for section in self.converted:
            dirname = basename + section + os.sep
            self.create_directory(dirname)

            # Write content
            for ind in range(len(self.converted[section])):
                content = self.converted[section][ind]

                with codecs.open(dirname + str(ind) + '.txt', "w", 'utf-8') as f:
                    f.write(content)
                f.close()


    def create_directory(self, path):
        if not os.path.exists(os.path.dirname(path)):
            try:
                os.makedirs(os.path.dirname(path))
            except:
                print(sys.exc_info()[0])

    def get_raw_text(self):
        return self.data

    def get_mod_text(self):
        return self.converted

    def test(self):
        print(len(self.data))

'''
if __name__ == "__main__":
    json_text = open('netflix.json', 'r')
    convert = Convert(json_text.read().encode('utf-8'), "Netflix", "2015", "10-Q", "201510061076")
    convert.parse()
    convert.output("text")
    #print convert.get_mod_text()
'''
