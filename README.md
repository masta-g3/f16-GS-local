# f16-GS

### New Scraper
The scrapy-based web scraper has been dropped as the unstructured and inconsistent format of HTML documents make it inefficient and unreliable. The new scraper generates 3 files. It can also be run as a Jupyter notebook.

`python new_scraper.py urls.txt`

1. **errors.csv**: Dataframe with error logs.
2. **logs.csv**: Dataframe with summary statistics of parsed data.
3. **content.json:** JSON with data.

The structure of the JSON is the following:

```
{'(docid_year)': [{
  section_num :[
    'Netflix, Inc. (“Netflix”, “the Company”, “we”, or “us”) is the world’s leading Internet television network...',
    'The Company has three reportable segments: Domestic streaming, International streaming and...'
    ]
 }]}
 ```
