# -*- coding: utf-8 -*-
import scrapy
import re
from edgar.items import edgarItem
from collections import OrderedDict

import datetime
import time
import sys
#from scrapy.xlib.pydispatch import dispatcher
from scrapy import signals
from scrapy.exceptions import CloseSpider

class edgarSpiderSpider(scrapy.Spider):
    name = "edgar_spider"
    allowed_domains = ["https://www.sec.gov"]
    start_urls = ['https://www.sec.gov/Archives/edgar/data/1018724/000101872416000172/amzn-20151231x10k.htm', #Amazon
                  'https://www.sec.gov/Archives/edgar/data/51143/000104746916010329/a2226548z10-k.htm', #IBM
                  'https://www.sec.gov/Archives/edgar/data/37996/000003799616000092/f1231201510-k.htm', #Ford
                  'https://www.sec.gov/Archives/edgar/data/895421/000119312516473553/d48186d10k.htm', #Morgan Stanley
                  'https://www.sec.gov/Archives/edgar/data/1065280/000119312510036181/d10k.htm', #Netflix
                  'https://www.sec.gov/Archives/edgar/data/1326801/000132680116000043/fb-12312015x10k.htm', #Facebook
                  'https://www.sec.gov/Archives/edgar/data/320193/000119312513416534/d590790d10k.htm' #Apple
                  ]

    def __init__(self,node=1,rep=1,*args,**kwargs):
        # Node indicates # of server
        # Rep indicates the number of repetitions one wants to perform in each scrape
        #self.rep = int(rep)
        #self.node = int(node)

        #keep track of date
        self.date = datetime.datetime.today().date()

    def start_requests(self):
        for url in self.start_urls:
            request = scrapy.Request(url, callback=self.parse_document)
            request.meta['url'] = url
            yield request

    def parse_document(self, response):
        ## Define sections to extract.
        sections = ['1', '1A', '1B', '2', '3', '4', '5', '6', '7', '7A', \
        '8', '9', '9A', '9B', '10', '11', '12', '13', '14', '15']

        ## Get company name and year.
        company = response.meta['url'].split('/')[6]
        year = response.xpath("//text()[re:test(.,'For the (fiscal )?year')]").extract()[0].split(',')[-1]

        if(len(company) < 0 or len(year) < 0):
            raise CloseSpider('Error extracting year of the document.')

        ## If data is valid, proceed.
        print 'Processing %s on year %s' %(company, year)

        ## Initialize document item.
        item = edgarItem()
        item['company'] = company
        item['year'] = year
        item['content'] = {}

        for i in range(len(sections)-1):
            #print 'Getting company %s, section %s.' %(company, sections[i])
            ## Define start and ending paths. The problem is that many documents have different CSS formats...
            start = "(preceding::font[re:test(text(),'ITEM\s" + sections[i] + "\. ')] | preceding::b[re:test(text(),'Item\s" + sections[i] + "\.')] | preceding::font[contains(@style,'font-weight:bold') and re:test(text(),'Item\s" + sections[i] + "\.')])"

            end = "(following::font[re:test(text(),'ITEM\s" + sections[i+1] + "\. ')] | following::b[re:test(text(),'Item\s" + sections[i+1] + "\.')] | following::font[contains(@style,'font-weight:bold') and re:test(text(),'Item\s" + sections[i+1] + "\.')])"

            content = response.xpath("//text()[string-length() > 50 and " + start  + " and " + end + "]").extract()

            #start = "(b[contains(text(), 'Item') and contains(text(), '" + sections[i] + ".') and text()[string-length() < 7 + " + str(len(sections[i])) + "]] | \
            #         //font[contains(@style, 'weight:bold') and (text() = 'Item " + sections[i] + ".' or text() = 'ITEM " + sections[i] + ". ')])"
            #end = "(b[contains(text(), 'Item') and contains(text(), '" + sections[i+1] + ".') and text()[string-length() < 7 + " + str(len(sections[i+1])) + "]] | \
            #         //font[contains(@style, 'weight:bold') and (text() = 'Item " + sections[i+1] + ".' or text() = 'ITEM " + sections[i+1] + ".  ')])"

            ## Extract all non-table data.
            print 'Length of section %s of company %s on %s.: %i' %(sections[i], company, year, len(content))
            block = '\n'.join(content)

            ## Store into content dictionary.
            item['content'][sections[i]] = block
        yield item

'''
for the fiscal year ended

Amazon
https://www.sec.gov/Archives/edgar/data/1018724/000101872416000172/amzn-20151231x10k.htm
"Item&nbsp;1."
/html/body/document/type/sequence/filename/description/text/p[52]/font/b[1]/text()
=======
Apple
"Item&nbsp;1."
/html/body/document/type/sequence/filename/description/text/table[6]/tbody/tr/td[1]/b/text()
=======
IBM
https://www.sec.gov/Archives/edgar/data/51143/000104746916010329/a2226548z10-k.htm
" Item 1. Business:  "
/html/body/document/type/sequence/filename/description/text/p[27]/font/b
=======
Ford
https://www.sec.gov/Archives/edgar/data/37996/000003799616000092/f1231201510-k.htm
"ITEM 1. "
/html/body/document/type/sequence/filename/description/text/div[371]/font[1]
=======
Morgan Stanley
https://www.sec.gov/Archives/edgar/data/895421/000119312516473553/d48186d10k.htm
"Item&nbsp;1.&nbsp;&nbsp;&nbsp;&nbsp;Business. "
/html/body/document/type/sequence/filename/description/text/p[58]/font/b/text()
=======
Netflix
https://www.sec.gov/Archives/edgar/data/1065280/000119312510036181/d10k.htm
"Item 1."
/html/body/document/type/sequence/filename/description/text/table[1]/tbody/tr[2]/td[1]/div/font
=======
Verizon
https://www.sec.gov/Archives/edgar/data/732712/000119312510041685/d10k.htm
"Item 1. "
/html/body/document/type/sequence/filename/description/text/p[52]/font/b[1]/text()
========
Facebook
https://www.sec.gov/Archives/edgar/data/1326801/000132680116000043/fb-12312015x10k.htm
========

sections = ['1', '1A', '1B', '2', '3', '4', '5', '6', '7', '7A', \
'8', '9', '9A', '9B', '10', '11', '12', '13', '14', '15']

i = 0


content[0]
content[-1]
'''
