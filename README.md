# f16-GS

### General Scrapy Instructions
The following commands have to be run on the edgar directory.
- To interactively scrape a website from the terminal: `scrapy shell %url%`.
- To run the scraper script: `scrapy crawl edgar_spider -o netflix.json`.

To edit the scraper script, the main files are items.py (defines structure of output file) and edgar_spider.py.

This is how I envision the first section (Item 1) will look like once we parse it.

```
{'number': 'Item 1',
 'title': 'Business',
 'content': [{
    'ABOUT US': 'Netflix, Inc. (“Netflix”, “the Company”, “we”, or “us”) is the world’s leading Internet television network...',
    'BUSINESS SEGMENTS': 'The Company has three reportable segments: Domestic streaming, International streaming and...'
 }]}
 ```
