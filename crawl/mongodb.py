'''
Classes for mongodb operation
'''

from pymongo import MongoClient
from setting import Setting
import json
from bson.objectid import ObjectId

class MongodbIndex:
    def __init__(self):
        self.client = MongoClient(Setting.mongodb_host, Setting.mongodb_port)
        self.db = self.client.index
        self.collection_all = self.db.all
        self.collection_current = self.db.current

    def remove_all(self):
        self.collection_all.remove()

    def add(self, data):
        label = ['year', 'quarter', 'company', 'form_type', 'cik', 'data_filed', 'url']
        post = {}
        for l in range(len(label)):
            post[label[l]] = data[l]
        self.collection_all.insert_one(post)

    def copy_to_current(self):
        # copy into current collection
        self.collection_current.remove()
        data = self.collection_all.find()
        if data.count() > 0:
            self.collection_current.insert_many(data)

    def add_to_current(self, keyword):
        self.collection_current.insert_many(self.collection_all.find(keyword))

    def get_top_url_from_current(self, limit = 10):
        data = self.collection_current.find()
        ids = []
        li = []
        for d in data.limit(limit):
            li.append([d['url'], d['company'], d['year'], d['form_type'], d['data_filed'].replace("-", "_"), d['cik']])
            ids.append(str(d['_id']))
        for i in ids:
            self.collection_current.delete_one({"_id":ObjectId(i)})
        return li

