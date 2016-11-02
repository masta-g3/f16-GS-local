#!/bin/sh

cd ../edgar
scrapy crawl edgar_spider -o /home/gs/files/json/output.json

