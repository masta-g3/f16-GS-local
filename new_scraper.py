from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import json
import urllib2
import re
import argparse

######ARGPARSE PART########
parser = argparse.ArgumentParser(
    description='Scrape 10-K documents from htmls provided as txt.',
    epilog = 'Example usage: >> python scraper.py path_to/urls.txt'
)
parser.add_argument('filename', type=str)
args = parser.parse_args()
#####END ARGPARSE##########

f = open(args.filename, 'r')
htmls = f.readlines()

def visible(element):
    if element.parent.name in ['style', 'script', '[document]', 'head', 'title']:
        return False
    elif re.match('<!--.*-->', (element).encode('utf-8')):
        return False
    return True
    
errors = pd.DataFrame(columns=['id', 'year', 'section', 'severity', 'comment', 'url'])
logs = pd.DataFrame(columns=['id', 'year', 'section', 'pre_length', 'length', 'pct_length' ,'url'])

all_docs = {}

for html in htmls:
    all_sections = {}
    soup = BeautifulSoup(urllib2.urlopen(html).read(), 'html.parser')
    
    ## Extract visible text.
    texts = soup.findAll(text=True)
    visible_texts = filter(visible, texts)
    len_total = len(visible_texts)
    
    ## Extract year and id.
    doc_id = html.split('/')[6]
    pattern_year = re.compile('\d{2}, \d{4}.*')
    year = [line for line in visible_texts if pattern_year.findall(line)][0].split(',')[-1].strip()
    
    ## Log error and skip document if year is wrong.
    if len(year) != 4:
        #print 'Year incorrectly defined! Skipping document.'
        errors.loc[len(errors)] = [doc_id, year, 'all', 'error','invalid year format', html]
        continue
    
    ## List all available sections.
    sections = ['1', '1A', '1B', '2', '3', '4', '5', '6', '7', '7A', \
                '8', '9', '9A', '9B', '10', '11', '12', '13', '14', '15']
    
    for i in range(len(sections)-1):
        ## Starting and ending lines for section.
        pattern_start = re.compile("(\s)?Item[(\\xa0)|(\s)]?" + sections[i] + "\.", re.I)
        pattern_end = re.compile("(\s)?Item[(\\xa0)|(\s)]?" + sections[i+1] + "\.", re.I)

        ## Get the start and end headers, and make sure they are exactly 2.
        start = [[s,line] for s,line in enumerate(visible_texts) if pattern_start.match(line)]
        end = [[e,line] for e,line in enumerate(visible_texts) if pattern_end.match(line)]
        
        ## If we extracted more than 1 item for each header, ignore the TOC one.
        if len(start) >1 and len(end) > 1:
            start = [start[1]]
            end = [end[1]]
            
        ## If either of the sections has zero length, report an error.
        if len(start) == 0 or len(end) == 0:
            #print 'Section %s incorrectly defined! Skipping...' %sections[i]
            errors.loc[len(errors)] = [doc_id, year, 'all', 'error', 'headers not defined', html]
            continue
        
        ## Extract section counter, and remove small text.
        content = visible_texts[start[0][0]:end[0][0]]
        len_pre = len(content)
        content_valid = [item for item in content if len(item) > 50]
        
        ## Checks for section length.
        len_content = len(content_valid)
        len_ratio = len_content / float(len_total)

        if len_ratio == 0:
            errors.loc[len(errors)] = [doc_id, year, sections[i], 'warning','length zero', html]
            #print 'Section %s on year %s has zero length!!!' %(sections[i], year)
            
        elif len_ratio > 0.8:
            errors.loc[len(errors)] = [doc_id, year, sections[i], 'warning','length 80% of document', html]
            #print 'Section %s on year %s is more than 80% of the document.'
        ## Add section to dictionary and log.
        logs.loc[len(logs)] = [doc_id, year, sections[i], len_pre, len_content, len_ratio, html]
        all_sections[sections[i]] = content_valid
    all_docs[str(doc_id + '_' + year)] = all_sections

## Write JSON and csv files.
with open('content.json', 'w') as outfile:
    json.dump(all_docs, outfile)

errors.to_csv('errors.csv', index=False)
logs.to_csv('logs.csv', index=False)