import urllib2
import lxml.html
import setting

def get_actual_url(index_url):
    url = index_url
    request = urllib2.urlopen(url)
    html = unicode(request.read(), 'utf-8')
    dom = lxml.html.fromstring(html)
    return setting.Setting.edgar_base_url + dom[1][12][5][0][1][1][2][0].get('href')

if __name__ == "__main__":
    print setting.Setting.edgar_base_url + get_actual_url("https://www.sec.gov/Archives/edgar/data/1606163/0001144204-15-015101-index.htm")

