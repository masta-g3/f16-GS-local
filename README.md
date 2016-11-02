# f16-GS

### New Scraper
The scrapy-based web scraper has been dropped as the unstructured and inconsistent format of HTML documents make it inefficient and unreliable. The new scraper generates 3 data structures:

1. Dataframe with error logs.
2. Dataframe with summary statistics of parsed data.
3. JSON with data.

```
{'(doc_id, year)': [{
  section_num :[
    'Netflix, Inc. (“Netflix”, “the Company”, “we”, or “us”) is the world’s leading Internet television network...',
    'The Company has three reportable segments: Domestic streaming, International streaming and...'
    ]
 }]}
 ```
