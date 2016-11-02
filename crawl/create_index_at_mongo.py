'''
Inserting index information into mongodb
This mongo data source will be the base data for all crawling operation
'''

import os
import csv
import setting
from mongodb import MongodbIndex

input_path = setting.Setting.csv_path

def read_all():
    files = os.listdir(input_path)
    count = 0
    for file in files:
        create_mongodb_data(input_path, file)
        count = count + 1
        if count >= 1:
            break

def create_mongodb_data(path, filename):
    data = open(path + filename, 'r')
    reader = csv.reader(data)
    year = filename[0:4]
    quarter = filename[5:6]
    mongodb_index = MongodbIndex()
    for row in reader:
        post = row
        post.insert(0, quarter)
        post.insert(0, year)
        mongodb_index.add(post)

if __name__ == "__main__":
    read_all()

