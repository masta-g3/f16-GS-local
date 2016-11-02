'''
Converting json format data outputted from Scrapy into text or mongodb.
'''

import json
import os
import codecs

class Convert:
    def __init__(self, json_text, company, year, category, unique):
        # Convert json to python object
        self.data = json.loads(json_text)
        self.converted = {}
        # TODO(hs2865) Think of how to efficiently get company/year/category/unique time info
        #self.company = "Netflix"
        #self.year = "2015"
        #self.category = "10-Q"
        #self.unique = "201510061076"
        self.company = company
        self.year = year
        self.category = category
        self.unique = unique

    def parse(self):
        for d in self.data:
            if d["number"] not in self.converted:
                self.converted[d["number"]] = {}
                self.converted[d["number"]]["title"] = d["title"]
                self.converted[d["number"]]["content"] = []
            # TODO(hs2865) This part needs to be changed depending on json format
            self.converted[d["number"]]["content"].append(d["content"])

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
        basename = self.company + os.sep + self.year + os.sep +\
                   self.category + os.sep + self.unique + os.sep
        nas_dest = setting.nas_dest
        self.create_directory(nas_dest + basename)

        for number in self.converted:
            dirname = basename + number + os.sep
            self.create_directory(dirname)

            # Write title
            tmp_file_name = "title.txt"

            with codecs.open(dirname + tmp_file_name, "w", 'utf-8') as f:
                f.write(self.converted[number]["title"])
            f.close()

            # Write content
            for ind_content in range(len(self.converted[number]["content"])):
                content = self.converted[number]["content"][ind_content]
                for key_content in content:
                    tmp_file_name = key_content + ".txt"
                    tmp_content = content[key_content]

                with codecs.open(dirname + tmp_file_name, "w", 'utf-8') as f:
                    f.write(tmp_content)
                f.close()

    def create_directory(self, path):
        if not os.path.exists(os.path.dirname(path)):
            try:
                os.makedirs(os.path.dirname(path))
            except OSError as exc:  # Guard against race condition
                print(exc.message)

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
