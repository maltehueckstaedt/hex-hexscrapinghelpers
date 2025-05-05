# SVScrapeR <img src="img/SVScrapeR.svg" align="right" height="200" /></a>

## Beschreibung  
`SVScrapeR` ist ein Funktionspaket, das den Scrapingprozess für HEX standardisieren und dadurch einfacher reproduzierbar und wartbar machen soll. In der aktuellen Version [`1.0.0`](http://srv-data01:30080/hex/hex-hexscrapinghelpers/-/releases/1.0.0) enthält `SVScrapeR` lediglich Rselenium-Wrapper zum Scrapen von HISone-Seiten, die voraussichtlich ab Ende 2025 mehr als 50 % der Vorlesungsverzeichnisse staatlicher deutscher Universitäten bereitstellen werden. Mit `SVScrapeR` sollten diese Universitäten mit nur wenigen Anpassungen von CSS-Selektoren problemlos gescraped werden können.

## Installation

`SVScrapeR 1.0.0` kann [hier](http://srv-data01:30080/hex/hex-hexscrapinghelpers/-/archive/1.0.0/hex-hexscrapinghelpers-1.0.0.tar.gz) geladen werden und folgendermaßen installiert werden:

```r
install.packages("C:/Users/DEIN_BENUTZERNAME/Downloads/hex-hexscrapinghelpers-1.0.0.tar.gz", repos = NULL, type = "source") 
library(SVScrapeR)
```

## Nutzung

Siehe für eine beispielhafte Anwendung [diese](http://srv-data01:30080/hex/hex-hexscrapinghelpers/-/blob/main/md_vignettes/scrape_his.md?ref_type=heads) Vignette.

## Support

Bei Problemen oder Anregungen bitte das Issue-System des Repos nutzen. Bei akuten Problemen gern zusätzlich an Malte Hückstädt oder (Backup) Eike Schröder wenden. 

## Roadmap

`SVScrapeR` soll künftig für das Scraping von HIS-Seiten weiter optimiert werden. Weiterhin sollen weitere Funktion appliziert werden, die das allgemeine Scraping erleichtern und stärker standardisieren. 

## Projektstatus

Das Projekt wird fortlaufend aktualisiert (Stand: März 2025)


