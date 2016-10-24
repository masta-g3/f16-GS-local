# -*- coding: utf-8 -*-
import scrapy
import re
from edgar.items import edgarItem

import datetime
import time
#from scrapy.xlib.pydispatch import dispatcher
from scrapy import signals

class edgarSpiderSpider(scrapy.Spider):
    name = "edgar_spider_old"
    allowed_domains = ["https://www.sec.gov"]
    start_urls = ['https://www.sec.gov/Archives/edgar/data/1065280/000106528016000047/nflx201510k.htm']

    def __init__(self,node=1,rep=1,*args,**kwargs):
        # Node indicates # of server
        # Rep indicates the number of repetitions one wants to perform in each scrape
        #self.rep = int(rep)
        #self.node = int(node)

        #keep track of date
        self.date = datetime.datetime.today().date()

    def start_requests(self):
        for url in self.start_urls:
            yield scrapy.Request(url, callback=self.parse_document)

    def parse_document(self, response):
        ## Get all links that are in tables.
        links = set(response.xpath("//table/descendant::a/@href").extract())
        while len(links) > 0:
            link = links.pop()[1:].encode('utf-8')
            ## Get number and title of element.
            section = response.xpath("//a[@name='"+link+"']")
            header = section.xpath("following-sibling::table[1]/descendant::font/text()").extract()
            if len(header) == 2:
                ## Check that we collected the relevant sections.
                if 'Item' in header[0].encode('utf-8'):
                    item = edgarItem()
                    ## Section number and title.
                    item['number'] = header[0][:-1]
                    item['title'] =  header[1]
                    ## Start parsing subsections and their pararaphs. Some things we need to implement here:
                    ## 1) Limit scope so that we only pick up elements between the current section and the next (ref: https://goo.gl/DW7ITY).
                    ## 2) Not all sections have subsections (i.e. font with 'bold'). Make an if statement to handle both cases.
                    ## 3) For subsections, pick up all paragraphs that are on it (and not on the following subsection).
                    subsection = section.xpath("following-sibling::div/font[contains(@style,'font-weight:bold')]/text()").extract()
                    paragraph = section.xpath("following-sibling::div/font[not(contains(@style,'font-weight:bold'))]/text()").extract()
                    if len(subsection) > 0:
                        item['content'] = {}
                        item['content'][subsection[0]] = paragraph[0]
                    yield item
