'''
Classes for mongodb operation
'''

from pymongo import MongoClient
from setting import Setting
import json

class MongodbIndex:
    def __init__(self):
        self.client = MongoClient(Setting.mongodb_host, Setting.mongodb_port)
        self.db = self.client.index
        self.collection_all = self.db.all
        self.collection_current = self.db.current
        self.collection_mycurrent = self.db["current_" + Setting.hostname.replace("-", "_")]

    def add(self, data):
        # data has the data like this format ['year', 'quarter', 'company', 'form_type', 'CIK', 'data_filed', 'URL']
        label = ['year', 'quarter', 'company', 'form_type', 'cik', 'data_filed', 'url']
        post = {}
        for l in range(len(label)):
            post[label[l]] = data[l]
        self.collection_all.insert_one(post)

    def copy_to_current(self, keyword):
        # copy into current collection
        self.collection_current.remove()
        self.collection_current.insert_many(self.collection_all.find(keyword))

    def add_to_current(self, keyword):
        self.collection_current.insert_many(self.collection_all.find(keyword))

    def copy_to_mycurrent(self, keyword):
        # copy into current collection
        self.collection_mycurrent.remove()
        data = self.collection_all.find(keyword)
        if data.count() > 0:
            self.collection_mycurrent.insert_many(data)

    def add_to_mycurrent(self, keyword):
        data = self.collection_all.find(keyword)
        if data.count() > 0:
            self.collection_mycurrent.insert_many(data)

    def get_top_url_from_current(self, limit = 10):
        data = self.collection_all.find()
        list = []
        for d in data.limit(limit):
            list.append(d['url'])
        return list

    def get_top_url_from_mycurrent(self, limit = 10):
        data = self.collection_all.find()
        list = []
        for d in data.limit(limit):
            list.append(d['url'])
        return list