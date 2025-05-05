Scrape HISone
================

## Einführung

`SVScrapeR` hilft, HISone-Seiten zu scrapen und ist im Kern ein Wrapper
verschiedener `RSelenium`-Funktionen. `SVScrapeR` soll im laufe der Zeit
jedoch zu einem nicht nur für HISone-Seiten optimierten Scraping-Paket
erweitert werden.

### Warum `SVScrapR`?

Bis Ende 2025 werden vermutlich \>50% der für HEX zu scrapenden
Universitäten auf HISone-Vorlesungsverzeichnisse umgestiegen sein.
HISone-Seiten sind nicht-statisch. Sie müssen daher mit einem
Selenium-Driver gescrapet werden. Das scraping von HISone-Seiten hat
sich dabei als nicht trivial erwiesen. Netzwerkprobleme (sowohl auf
Seite des SVs als auch auf der der Hoster) sowie lange Scrapingprozesse
erschweren die Datenerhebung und erfordern komplexe Funktionen, die
Scrapingskripte unübersichtlich, kontraintuitiv und schwer wartbar
machen.

Durch die Erstellung eines R-Pakets anstatt eines großen Skripts, wird
die prozessierbarkeit, Wiederverwendbarkeit und Wartbarkeit der
Scrapingcodes erheblich verbessert:

Scrapingskript Wuppertal: `827 Zeilen` Scrapingskript Tübingen:
`107 Zeilen`

Funktionen werden klar dokumentiert und können problemlos in
verschiedenen Scrapingprozessen genutzt werden. `SVScrapR` bietet so
eine effiziente Möglichkeit, Abhängigkeiten zu verwalten und die
Versionen des Codes zu kontrollieren, was eine stabile und konsistente
Nutzung gewährleistet.

## Exemplarische Anwendung

### Installation

Im folgenden wird `SVScrapeR` exemplarisch am *WUESTUDY* vorgeführt.
Prinzipiell sollte es aber für alle HISone-basierten
Vorlesungsverzeichnisse mit nur wenig Modifikation nutzbar sein.

In einem ersten Schritt laden wir das Paket in der aktuellen Version
`0.1.0` von Gitlab, installieren und laden es in R:

``` r
#install.packages("C:/Users/mhu/Downloads/hex-hexscrapinghelpers-0.1.0.tar.gz", repos = NULL, type = "source") 
library(SVScrapeR)
```

    ## Warning: package 'SVScrapeR' was built under R version 4.4.3

### Start einer Chromedriver-Instanz

In einem weiteren Schritt starten wir eine Chromedriver-Instanz und
maximieren das Browserfenster.

``` r
library(RSelenium)
driver <- rsDriver(
  browser = "chrome",
  chromever = "latest",
  port = 1234L
)
```

    ## checking Selenium Server versions:

    ## BEGIN: PREDOWNLOAD

    ## BEGIN: DOWNLOAD

    ## BEGIN: POSTDOWNLOAD

    ## checking chromedriver versions:

    ## BEGIN: PREDOWNLOAD

    ## BEGIN: DOWNLOAD

    ## BEGIN: POSTDOWNLOAD

    ## checking geckodriver versions:

    ## BEGIN: PREDOWNLOAD

    ## BEGIN: DOWNLOAD

    ## BEGIN: POSTDOWNLOAD

    ## checking phantomjs versions:

    ## BEGIN: PREDOWNLOAD

    ## BEGIN: DOWNLOAD

    ## BEGIN: POSTDOWNLOAD

    ## [1] "Connecting to remote server"
    ## $acceptInsecureCerts
    ## [1] FALSE
    ## 
    ## $browserName
    ## [1] "chrome"
    ## 
    ## $browserVersion
    ## [1] "134.0.6998.35"
    ## 
    ## $chrome
    ## $chrome$chromedriverVersion
    ## [1] "133.0.6943.141 (2a5d6da0d6165d7b107502095a937fe7704fcef6-refs/branch-heads/6943@{#1912})"
    ## 
    ## $chrome$userDataDir
    ## [1] "C:\\Users\\mhu\\AppData\\Local\\Temp\\scoped_dir4728_1664021823"
    ## 
    ## 
    ## $`fedcm:accounts`
    ## [1] TRUE
    ## 
    ## $`goog:chromeOptions`
    ## $`goog:chromeOptions`$debuggerAddress
    ## [1] "localhost:60314"
    ## 
    ## 
    ## $networkConnectionEnabled
    ## [1] FALSE
    ## 
    ## $pageLoadStrategy
    ## [1] "normal"
    ## 
    ## $platformName
    ## [1] "windows"
    ## 
    ## $proxy
    ## named list()
    ## 
    ## $setWindowRect
    ## [1] TRUE
    ## 
    ## $strictFileInteractability
    ## [1] FALSE
    ## 
    ## $timeouts
    ## $timeouts$implicit
    ## [1] 0
    ## 
    ## $timeouts$pageLoad
    ## [1] 300000
    ## 
    ## $timeouts$script
    ## [1] 30000
    ## 
    ## 
    ## $unhandledPromptBehavior
    ## [1] "dismiss and notify"
    ## 
    ## $`webauthn:extension:credBlob`
    ## [1] TRUE
    ## 
    ## $`webauthn:extension:largeBlob`
    ## [1] TRUE
    ## 
    ## $`webauthn:extension:minPinLength`
    ## [1] TRUE
    ## 
    ## $`webauthn:extension:prf`
    ## [1] TRUE
    ## 
    ## $`webauthn:virtualAuthenticators`
    ## [1] TRUE
    ## 
    ## $webdriver.remote.sessionid
    ## [1] "4f0770e6103e4d170f1ba9a918793d60"
    ## 
    ## $id
    ## [1] "4f0770e6103e4d170f1ba9a918793d60"

``` r
rmdr <- driver[["client"]]
rmdr$maxWindowSize()
```

Wir richten mit `select_semester_and_set_courses()` unsere
Ausgangssituation ein:

1.  Wir definieren mit `rmdr` den oben initialisierten Remotedriver.
2.  Wird definieren unsere `base_url`. Dies ist die Veranstaltungssuche
    der entsprechenden HIS-Site. Meist zu finden über
    `Landingpage > Veranstaltungen suchen`. Für die Uni-Würzburg ist
    dies
    (dieser)\[<https://wuestudy.zv.uni-wuerzburg.de/qisserver/pages/startFlow.xhtml?_flowId=searchCourseNonStaff-flow&_flowExecutionKey=e4s1>”\]
    Link.
3.  Wir definieren den CSS Selector des Dropdown-Menüs der
    Semesterauswahl `sem_dropdown`.
4.  Wir definieren `num_sem_selector`, der die Instanznummer des
    Selectors der Semester im Dropdown-Menü definiert. Hier das Semester
    `SS19`.
5.  Wir definieren mit `num_courses_selector`den Selector des Feldes, in
    dem die Anzahl der Kurse pro Übersichtsseite verändert werden kann.
6.  Wir definieren mit `num_courses`, wie viele Kurse pro
    Überssichtsseite angezeigt werden. Hier: 10 Einträge pro
    Übersichtsseite.
7.  Wir definieren den `css selector` des Suchfeldes, um eine leere
    Suche für ein spezifiziertes Semester ausführen zu können und so
    alle Kurse eines Semesters angezeigt zu bekommen.

``` r
rmdr <- rmdr
base_url <- "https://wuestudy.zv.uni-wuerzburg.de/qisserver/pages/startFlow.xhtml?_flowId=searchCourseNonStaff-flow&_flowExecutionKey=e4s1"
sem_dropdown <- "#genericSearchMask\\:search_e4ff321960e251186ac57567bec9f4ce\\:cm_exa_eventprocess_basic_data\\:fieldset\\:inputField_3_abb156a1126282e4cf40d48283b4e76d\\:idabb156a1126282e4cf40d48283b4e76d\\:termSelect_label"
num_sem_selector <- 12
num_courses_selector <- "#genSearchRes\\:id3df798d58b4bacd9\\:id3df798d58b4bacd9Navi2NumRowsInput"
num_courses <- "10"
search_field <- "#genericSearchMask\\:search_e4ff321960e251186ac57567bec9f4ce\\:cm_exa_eventprocess_basic_data\\:fieldset\\:inputField_0_1ad08e26bde39c9e4f1833e56dcce9b5\\:id1ad08e26bde39c9e4f1833e56dcce9b5"

SVScrapeR::select_semester_and_set_courses(
  rmdr,
  base_url,
  num_sem_selector,
  num_courses,
  sem_dropdown,
  search_field,
  num_courses_selector
)
```

### URL-Selektoren generieren

Wir definieren weiterhin das Muster der CSS Selektoren für die URLs der
Kurse. Der erste CSS Selektor einer Kurs-URL sollte etwas diese Form
annehmen:
`#genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:0\:tableRowAction`.
Wir ersetzen `\:0\` durch `\:%d\` um die fortlaufenden CSS-Selektoren
für das ganze Semester zu erzeugen. Nebenbemerkung: In R muss ein
Backslash mit einem zweiten Backslash *escaped* werden, da ansonsten der
einfache Backslash als Escape-Zeichen interpretiert wird.

Bei einer Darstellung der Hauptseite mit zehn Kursen pro Seite,
erstellen wir weiterhin 10er-Chunks, um nach dem Durchlauf durch die
Kurse einer Seite im Menüband auf `Weiter` zu klicken und dann mit den
URLs der nächsten Seite fortzufahren. Für die Vorführungszwecke werden
im folgenden nur der 1. Chunk mit 10 URLs durchlaufen.

``` r
css_selectors <- generate_url_selectors(rmdr, css_first_selector = "#genSearchRes\\:id3df798d58b4bacd9\\:id3df798d58b4bacd9Table\\:%d\\:tableRowAction")
chunks <- split(css_selectors, ceiling(seq_along(css_selectors) / 10))
chunks <- chunks[c("1")]
```

### Scraping starten

Wir starten das Scraping, in dem wir `scrape_his()` den Remotedriver,
die Chunks und die CSS Selektoren übergeben.

``` r
course_data_wuerzburg_ss19 <- scrape_his(chunks, rmdr, css_selectors)
```

    ## Versuch Kurs-URL zu betaetigen Nr.  1  von maximal  10  ...

    ## Kursseite erfolgreich betreten. Starte das Scraping des Kurses:  -

    ## Kurs-URL-Selector:  #genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:0\:tableRowAction

    ## Versuch Studiengaenge in Registerkarte >>Termine<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Termine<<

    ## [33m>> Titel <<[0m erfolgreich erhoben
    ## [33m>> Nummer <<[0m erfolgreich erhoben
    ## [33m>> Organisationseinheit <<[0m erfolgreich erhoben
    ## [33m>> Veranstaltungsart <<[0m erfolgreich erhoben
    ## [33m>> Angebotshäufigkeit <<[0m erfolgreich erhoben
    ## [33m>> Semesterwochenstunden <<[0m erfolgreich erhoben
    ## [33m>> Lehrsprache <<[0m erfolgreich erhoben
    ## [33m>> Verantwortliche/-r <<[0m erfolgreich erhoben

    ## Versuch Registerkarte >>Inhalte<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Inhalte<<

    ## Keine Container in der Registerkarte >>Inhalte<< gefunden

    ## Versuch Module in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Module/Studiengaenge<<

    ## 
    ## Selenium message:no such element: Unable to locate element: {"method":"css selector","selector":"#detailViewData\:tabContainer\:term-planning-container\:modules\:moduleAssignments"}
    ##   (Session info: chrome=134.0.6998.35)
    ## For documentation on this error, please visit: https://www.seleniumhq.org/exceptions/no_such_element.html
    ## Build info: version: '4.0.0-alpha-2', revision: 'f148142cf8', time: '2019-07-01T21:30:10'
    ## System info: host: 'SL-SV-073', ip: '192.168.178.90', os.name: 'Windows 10', os.arch: 'amd64', os.version: '10.0', java.version: '21.0.4'
    ## Driver info: driver.version: unknown

    ## Keine Module gefunden. Rueckgabe eines leeren Tibbles.

    ## Versuch Studiengaenge in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping des HTML-Tables >>Studiengaenge<<

    ## [33m>> standardtext <<[0m erfolgreich erhoben
    ## [33m>> typ <<[0m erfolgreich erhoben
    ## [33m>> abschluss <<[0m erfolgreich erhoben
    ## [33m>> fach <<[0m erfolgreich erhoben
    ## [33m>> vertiefung <<[0m erfolgreich erhoben
    ## [33m>> schwerpunkt <<[0m erfolgreich erhoben
    ## [33m>> fachkennzeichen <<[0m erfolgreich erhoben
    ## [33m>> prufungsordnungsversion <<[0m erfolgreich erhoben
    ## [33m>> studienform <<[0m erfolgreich erhoben
    ## [33m>> studienort <<[0m erfolgreich erhoben
    ## [33m>> studienart <<[0m erfolgreich erhoben

    ## Versuche >>zurueck<<-Button zu finden Nr.  1  von maximal  10  ...

    ## Zurueck zur uebersicht...

    ## Versuch Kurs-URL zu betaetigen Nr.  1  von maximal  10  ...

    ## Kursseite erfolgreich betreten. Starte das Scraping des Kurses:  04000271

    ## Kurs-URL-Selector:  #genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:1\:tableRowAction

    ## Versuch Studiengaenge in Registerkarte >>Termine<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Termine<<

    ## [33m>> Titel <<[0m erfolgreich erhoben
    ## [33m>> Veranstaltungsart <<[0m erfolgreich erhoben
    ## [33m>> Angebotshäufigkeit <<[0m erfolgreich erhoben

    ## Versuch Registerkarte >>Inhalte<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Inhalte<<

    ## Keine Container in der Registerkarte >>Inhalte<< gefunden

    ## Versuch Module in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Module/Studiengaenge<<

    ## 
    ## Selenium message:no such element: Unable to locate element: {"method":"css selector","selector":"#detailViewData\:tabContainer\:term-planning-container\:modules\:moduleAssignments"}
    ##   (Session info: chrome=134.0.6998.35)
    ## For documentation on this error, please visit: https://www.seleniumhq.org/exceptions/no_such_element.html
    ## Build info: version: '4.0.0-alpha-2', revision: 'f148142cf8', time: '2019-07-01T21:30:10'
    ## System info: host: 'SL-SV-073', ip: '192.168.178.90', os.name: 'Windows 10', os.arch: 'amd64', os.version: '10.0', java.version: '21.0.4'
    ## Driver info: driver.version: unknown

    ## Keine Module gefunden. Rueckgabe eines leeren Tibbles.

    ## Versuch Studiengaenge in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping des HTML-Tables >>Studiengaenge<<

    ## [33m>> standardtext <<[0m erfolgreich erhoben
    ## [33m>> typ <<[0m erfolgreich erhoben
    ## [33m>> abschluss <<[0m erfolgreich erhoben
    ## [33m>> fach <<[0m erfolgreich erhoben
    ## [33m>> vertiefung <<[0m erfolgreich erhoben
    ## [33m>> schwerpunkt <<[0m erfolgreich erhoben
    ## [33m>> fachkennzeichen <<[0m erfolgreich erhoben
    ## [33m>> prufungsordnungsversion <<[0m erfolgreich erhoben
    ## [33m>> studienform <<[0m erfolgreich erhoben
    ## [33m>> studienort <<[0m erfolgreich erhoben
    ## [33m>> studienart <<[0m erfolgreich erhoben

    ## Versuche >>zurueck<<-Button zu finden Nr.  1  von maximal  10  ...

    ## Zurueck zur uebersicht...

    ## Versuch Kurs-URL zu betaetigen Nr.  1  von maximal  10  ...

    ## Kursseite erfolgreich betreten. Starte das Scraping des Kurses:  04104430

    ## Kurs-URL-Selector:  #genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:2\:tableRowAction

    ## Versuch Studiengaenge in Registerkarte >>Termine<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Termine<<

    ## [33m>> Titel <<[0m erfolgreich erhoben
    ## [33m>> Organisationseinheit <<[0m erfolgreich erhoben
    ## [33m>> Veranstaltungsart <<[0m erfolgreich erhoben
    ## [33m>> Angebotshäufigkeit <<[0m erfolgreich erhoben

    ## Versuch Registerkarte >>Inhalte<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Inhalte<<

    ## Keine Container in der Registerkarte >>Inhalte<< gefunden

    ## Versuch Module in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Module/Studiengaenge<<

    ## 
    ## Selenium message:no such element: Unable to locate element: {"method":"css selector","selector":"#detailViewData\:tabContainer\:term-planning-container\:modules\:moduleAssignments"}
    ##   (Session info: chrome=134.0.6998.35)
    ## For documentation on this error, please visit: https://www.seleniumhq.org/exceptions/no_such_element.html
    ## Build info: version: '4.0.0-alpha-2', revision: 'f148142cf8', time: '2019-07-01T21:30:10'
    ## System info: host: 'SL-SV-073', ip: '192.168.178.90', os.name: 'Windows 10', os.arch: 'amd64', os.version: '10.0', java.version: '21.0.4'
    ## Driver info: driver.version: unknown

    ## Keine Module gefunden. Rueckgabe eines leeren Tibbles.

    ## Versuch Studiengaenge in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping des HTML-Tables >>Studiengaenge<<

    ## [33m>> standardtext <<[0m erfolgreich erhoben
    ## [33m>> typ <<[0m erfolgreich erhoben
    ## [33m>> abschluss <<[0m erfolgreich erhoben
    ## [33m>> fach <<[0m erfolgreich erhoben
    ## [33m>> vertiefung <<[0m erfolgreich erhoben
    ## [33m>> schwerpunkt <<[0m erfolgreich erhoben
    ## [33m>> fachkennzeichen <<[0m erfolgreich erhoben
    ## [33m>> prufungsordnungsversion <<[0m erfolgreich erhoben
    ## [33m>> studienform <<[0m erfolgreich erhoben
    ## [33m>> studienort <<[0m erfolgreich erhoben
    ## [33m>> studienart <<[0m erfolgreich erhoben

    ## Versuche >>zurueck<<-Button zu finden Nr.  1  von maximal  10  ...

    ## Zurueck zur uebersicht...

    ## Versuch Kurs-URL zu betaetigen Nr.  1  von maximal  10  ...

    ## Kursseite erfolgreich betreten. Starte das Scraping des Kurses:  04-VS Einführung ins Studium der Vergleichenden Indogermanischen Sprachwissenschaft

    ## Kurs-URL-Selector:  #genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:3\:tableRowAction

    ## Versuch Studiengaenge in Registerkarte >>Termine<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Termine<<

    ## [33m>> Titel <<[0m erfolgreich erhoben
    ## [33m>> Kurztext <<[0m erfolgreich erhoben
    ## [33m>> Nummer <<[0m erfolgreich erhoben
    ## [33m>> Organisationseinheit <<[0m erfolgreich erhoben
    ## [33m>> Veranstaltungsart <<[0m erfolgreich erhoben
    ## [33m>> Angebotshäufigkeit <<[0m erfolgreich erhoben
    ## [33m>> Semesterwochenstunden <<[0m erfolgreich erhoben
    ## [33m>> Lehrsprache <<[0m erfolgreich erhoben
    ## [33m>> Verantwortliche/-r <<[0m erfolgreich erhoben

    ## Versuch Registerkarte >>Inhalte<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Inhalte<<

    ## Anzahl gefundener Container in der Registerkarte >>Inhalte<<: 2

    ## [33m>> inhalte <<[0m erfolgreich erhoben
    ## [33m>> zielgruppe <<[0m erfolgreich erhoben

    ## Versuch Module in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Module/Studiengaenge<<

    ## 
    ## Selenium message:no such element: Unable to locate element: {"method":"css selector","selector":"#detailViewData\:tabContainer\:term-planning-container\:modules\:moduleAssignments"}
    ##   (Session info: chrome=134.0.6998.35)
    ## For documentation on this error, please visit: https://www.seleniumhq.org/exceptions/no_such_element.html
    ## Build info: version: '4.0.0-alpha-2', revision: 'f148142cf8', time: '2019-07-01T21:30:10'
    ## System info: host: 'SL-SV-073', ip: '192.168.178.90', os.name: 'Windows 10', os.arch: 'amd64', os.version: '10.0', java.version: '21.0.4'
    ## Driver info: driver.version: unknown

    ## Keine Module gefunden. Rueckgabe eines leeren Tibbles.

    ## Versuch Studiengaenge in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping des HTML-Tables >>Studiengaenge<<

    ## [33m>> standardtext <<[0m erfolgreich erhoben
    ## [33m>> typ <<[0m erfolgreich erhoben
    ## [33m>> abschluss <<[0m erfolgreich erhoben
    ## [33m>> fach <<[0m erfolgreich erhoben
    ## [33m>> vertiefung <<[0m erfolgreich erhoben
    ## [33m>> schwerpunkt <<[0m erfolgreich erhoben
    ## [33m>> fachkennzeichen <<[0m erfolgreich erhoben
    ## [33m>> prufungsordnungsversion <<[0m erfolgreich erhoben
    ## [33m>> studienform <<[0m erfolgreich erhoben
    ## [33m>> studienort <<[0m erfolgreich erhoben
    ## [33m>> studienart <<[0m erfolgreich erhoben

    ## Versuche >>zurueck<<-Button zu finden Nr.  1  von maximal  10  ...

    ## Zurueck zur uebersicht...

    ## Versuch Kurs-URL zu betaetigen Nr.  1  von maximal  10  ...

    ## Kursseite erfolgreich betreten. Starte das Scraping des Kurses:  05049381

    ## Kurs-URL-Selector:  #genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:4\:tableRowAction

    ## Versuch Studiengaenge in Registerkarte >>Termine<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Termine<<

    ## [33m>> Titel <<[0m erfolgreich erhoben
    ## [33m>> Organisationseinheit <<[0m erfolgreich erhoben
    ## [33m>> Veranstaltungsart <<[0m erfolgreich erhoben
    ## [33m>> Angebotshäufigkeit <<[0m erfolgreich erhoben
    ## [33m>> Semesterwochenstunden <<[0m erfolgreich erhoben

    ## Versuch Registerkarte >>Inhalte<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Inhalte<<

    ## Keine Container in der Registerkarte >>Inhalte<< gefunden

    ## Versuch Module in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Module/Studiengaenge<<

    ## 
    ## Selenium message:no such element: Unable to locate element: {"method":"css selector","selector":"#detailViewData\:tabContainer\:term-planning-container\:modules\:moduleAssignments"}
    ##   (Session info: chrome=134.0.6998.35)
    ## For documentation on this error, please visit: https://www.seleniumhq.org/exceptions/no_such_element.html
    ## Build info: version: '4.0.0-alpha-2', revision: 'f148142cf8', time: '2019-07-01T21:30:10'
    ## System info: host: 'SL-SV-073', ip: '192.168.178.90', os.name: 'Windows 10', os.arch: 'amd64', os.version: '10.0', java.version: '21.0.4'
    ## Driver info: driver.version: unknown

    ## Keine Module gefunden. Rueckgabe eines leeren Tibbles.

    ## Versuch Studiengaenge in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping des HTML-Tables >>Studiengaenge<<

    ## [33m>> standardtext <<[0m erfolgreich erhoben
    ## [33m>> typ <<[0m erfolgreich erhoben
    ## [33m>> abschluss <<[0m erfolgreich erhoben
    ## [33m>> fach <<[0m erfolgreich erhoben
    ## [33m>> vertiefung <<[0m erfolgreich erhoben
    ## [33m>> schwerpunkt <<[0m erfolgreich erhoben
    ## [33m>> fachkennzeichen <<[0m erfolgreich erhoben
    ## [33m>> prufungsordnungsversion <<[0m erfolgreich erhoben
    ## [33m>> studienform <<[0m erfolgreich erhoben
    ## [33m>> studienort <<[0m erfolgreich erhoben
    ## [33m>> studienart <<[0m erfolgreich erhoben

    ## Versuche >>zurueck<<-Button zu finden Nr.  1  von maximal  10  ...

    ## Zurueck zur uebersicht...

    ## Versuch Kurs-URL zu betaetigen Nr.  1  von maximal  10  ...

    ## Kursseite erfolgreich betreten. Starte das Scraping des Kurses:  09-HG-MSc-FPrax1-1 Forschungspraktikum im Ausland / Partneruniversität für Studierende der Geographie / 04-Geo-FPrax Forschungspraktikum im Ausland / Partneruniversität für Studierende der Angewandten Humangeographie

    ## Kurs-URL-Selector:  #genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:5\:tableRowAction

    ## Versuch Studiengaenge in Registerkarte >>Termine<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Termine<<

    ## [33m>> Titel <<[0m erfolgreich erhoben
    ## [33m>> Nummer <<[0m erfolgreich erhoben
    ## [33m>> Organisationseinheit <<[0m erfolgreich erhoben
    ## [33m>> Veranstaltungsart <<[0m erfolgreich erhoben
    ## [33m>> Angebotshäufigkeit <<[0m erfolgreich erhoben
    ## [33m>> Semesterwochenstunden <<[0m erfolgreich erhoben
    ## [33m>> Lehrsprache <<[0m erfolgreich erhoben
    ## [33m>> Verantwortliche/-r <<[0m erfolgreich erhoben

    ## Versuch Registerkarte >>Inhalte<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Inhalte<<

    ## Keine Container in der Registerkarte >>Inhalte<< gefunden

    ## Versuch Module in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Module/Studiengaenge<<

    ## Module gefunden...

    ## [33m>> modulnummer <<[0m erfolgreich erhoben
    ## [33m>> modulname_kurztext <<[0m erfolgreich erhoben
    ## [33m>> modulname_aufwarts_sortieren <<[0m erfolgreich erhoben
    ## [33m>> angebotshaufigkeit <<[0m erfolgreich erhoben
    ## [33m>> aktionen <<[0m erfolgreich erhoben

    ## Versuch Studiengaenge in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping des HTML-Tables >>Studiengaenge<<

    ## [33m>> standardtext <<[0m erfolgreich erhoben
    ## [33m>> typ <<[0m erfolgreich erhoben
    ## [33m>> abschluss <<[0m erfolgreich erhoben
    ## [33m>> fach <<[0m erfolgreich erhoben
    ## [33m>> vertiefung <<[0m erfolgreich erhoben
    ## [33m>> schwerpunkt <<[0m erfolgreich erhoben
    ## [33m>> fachkennzeichen <<[0m erfolgreich erhoben
    ## [33m>> prufungsordnungsversion <<[0m erfolgreich erhoben
    ## [33m>> studienform <<[0m erfolgreich erhoben
    ## [33m>> studienort <<[0m erfolgreich erhoben
    ## [33m>> studienart <<[0m erfolgreich erhoben

    ## Versuche >>zurueck<<-Button zu finden Nr.  1  von maximal  10  ...

    ## Zurueck zur uebersicht...

    ## Versuch Kurs-URL zu betaetigen Nr.  1  von maximal  10  ...

    ## Kursseite erfolgreich betreten. Starte das Scraping des Kurses:  1

    ## Kurs-URL-Selector:  #genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:6\:tableRowAction

    ## Versuch Studiengaenge in Registerkarte >>Termine<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Termine<<

    ## [33m>> Titel <<[0m erfolgreich erhoben
    ## [33m>> Organisationseinheit <<[0m erfolgreich erhoben
    ## [33m>> Veranstaltungsart <<[0m erfolgreich erhoben
    ## [33m>> Angebotshäufigkeit <<[0m erfolgreich erhoben

    ## Versuch Registerkarte >>Inhalte<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Inhalte<<

    ## Keine Container in der Registerkarte >>Inhalte<< gefunden

    ## Versuch Module in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Module/Studiengaenge<<

    ## 
    ## Selenium message:no such element: Unable to locate element: {"method":"css selector","selector":"#detailViewData\:tabContainer\:term-planning-container\:modules\:moduleAssignments"}
    ##   (Session info: chrome=134.0.6998.35)
    ## For documentation on this error, please visit: https://www.seleniumhq.org/exceptions/no_such_element.html
    ## Build info: version: '4.0.0-alpha-2', revision: 'f148142cf8', time: '2019-07-01T21:30:10'
    ## System info: host: 'SL-SV-073', ip: '192.168.178.90', os.name: 'Windows 10', os.arch: 'amd64', os.version: '10.0', java.version: '21.0.4'
    ## Driver info: driver.version: unknown

    ## Keine Module gefunden. Rueckgabe eines leeren Tibbles.

    ## Versuch Studiengaenge in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping des HTML-Tables >>Studiengaenge<<

    ## [33m>> standardtext <<[0m erfolgreich erhoben
    ## [33m>> typ <<[0m erfolgreich erhoben
    ## [33m>> abschluss <<[0m erfolgreich erhoben
    ## [33m>> fach <<[0m erfolgreich erhoben
    ## [33m>> vertiefung <<[0m erfolgreich erhoben
    ## [33m>> schwerpunkt <<[0m erfolgreich erhoben
    ## [33m>> fachkennzeichen <<[0m erfolgreich erhoben
    ## [33m>> prufungsordnungsversion <<[0m erfolgreich erhoben
    ## [33m>> studienform <<[0m erfolgreich erhoben
    ## [33m>> studienort <<[0m erfolgreich erhoben
    ## [33m>> studienart <<[0m erfolgreich erhoben

    ## Versuche >>zurueck<<-Button zu finden Nr.  1  von maximal  10  ...

    ## Zurueck zur uebersicht...

    ## Versuch Kurs-URL zu betaetigen Nr.  1  von maximal  10  ...

    ## Kursseite erfolgreich betreten. Starte das Scraping des Kurses:  1. Sitzung Berufungsausschuss W3-Professur für NDL I

    ## Kurs-URL-Selector:  #genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:7\:tableRowAction

    ## Versuch Studiengaenge in Registerkarte >>Termine<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Termine<<

    ## [33m>> Titel <<[0m erfolgreich erhoben
    ## [33m>> Organisationseinheit <<[0m erfolgreich erhoben
    ## [33m>> Veranstaltungsart <<[0m erfolgreich erhoben
    ## [33m>> Angebotshäufigkeit <<[0m erfolgreich erhoben

    ## Versuch Registerkarte >>Inhalte<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Inhalte<<

    ## Keine Container in der Registerkarte >>Inhalte<< gefunden

    ## Versuch Module in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Module/Studiengaenge<<

    ## 
    ## Selenium message:no such element: Unable to locate element: {"method":"css selector","selector":"#detailViewData\:tabContainer\:term-planning-container\:modules\:moduleAssignments"}
    ##   (Session info: chrome=134.0.6998.35)
    ## For documentation on this error, please visit: https://www.seleniumhq.org/exceptions/no_such_element.html
    ## Build info: version: '4.0.0-alpha-2', revision: 'f148142cf8', time: '2019-07-01T21:30:10'
    ## System info: host: 'SL-SV-073', ip: '192.168.178.90', os.name: 'Windows 10', os.arch: 'amd64', os.version: '10.0', java.version: '21.0.4'
    ## Driver info: driver.version: unknown

    ## Keine Module gefunden. Rueckgabe eines leeren Tibbles.

    ## Versuch Studiengaenge in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping des HTML-Tables >>Studiengaenge<<

    ## [33m>> standardtext <<[0m erfolgreich erhoben
    ## [33m>> typ <<[0m erfolgreich erhoben
    ## [33m>> abschluss <<[0m erfolgreich erhoben
    ## [33m>> fach <<[0m erfolgreich erhoben
    ## [33m>> vertiefung <<[0m erfolgreich erhoben
    ## [33m>> schwerpunkt <<[0m erfolgreich erhoben
    ## [33m>> fachkennzeichen <<[0m erfolgreich erhoben
    ## [33m>> prufungsordnungsversion <<[0m erfolgreich erhoben
    ## [33m>> studienform <<[0m erfolgreich erhoben
    ## [33m>> studienort <<[0m erfolgreich erhoben
    ## [33m>> studienart <<[0m erfolgreich erhoben

    ## Versuche >>zurueck<<-Button zu finden Nr.  1  von maximal  10  ...

    ## Zurueck zur uebersicht...

    ## Versuch Kurs-URL zu betaetigen Nr.  1  von maximal  10  ...

    ## Kursseite erfolgreich betreten. Starte das Scraping des Kurses:  1. Sitzung Berufungsausschuss W3-Professur für NDL II

    ## Kurs-URL-Selector:  #genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:8\:tableRowAction

    ## Versuch Studiengaenge in Registerkarte >>Termine<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Termine<<

    ## [33m>> Titel <<[0m erfolgreich erhoben
    ## [33m>> Organisationseinheit <<[0m erfolgreich erhoben
    ## [33m>> Veranstaltungsart <<[0m erfolgreich erhoben
    ## [33m>> Angebotshäufigkeit <<[0m erfolgreich erhoben

    ## Versuch Registerkarte >>Inhalte<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Inhalte<<

    ## Keine Container in der Registerkarte >>Inhalte<< gefunden

    ## Versuch Module in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Module/Studiengaenge<<

    ## 
    ## Selenium message:no such element: Unable to locate element: {"method":"css selector","selector":"#detailViewData\:tabContainer\:term-planning-container\:modules\:moduleAssignments"}
    ##   (Session info: chrome=134.0.6998.35)
    ## For documentation on this error, please visit: https://www.seleniumhq.org/exceptions/no_such_element.html
    ## Build info: version: '4.0.0-alpha-2', revision: 'f148142cf8', time: '2019-07-01T21:30:10'
    ## System info: host: 'SL-SV-073', ip: '192.168.178.90', os.name: 'Windows 10', os.arch: 'amd64', os.version: '10.0', java.version: '21.0.4'
    ## Driver info: driver.version: unknown

    ## Keine Module gefunden. Rueckgabe eines leeren Tibbles.

    ## Versuch Studiengaenge in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping des HTML-Tables >>Studiengaenge<<

    ## [33m>> standardtext <<[0m erfolgreich erhoben
    ## [33m>> typ <<[0m erfolgreich erhoben
    ## [33m>> abschluss <<[0m erfolgreich erhoben
    ## [33m>> fach <<[0m erfolgreich erhoben
    ## [33m>> vertiefung <<[0m erfolgreich erhoben
    ## [33m>> schwerpunkt <<[0m erfolgreich erhoben
    ## [33m>> fachkennzeichen <<[0m erfolgreich erhoben
    ## [33m>> prufungsordnungsversion <<[0m erfolgreich erhoben
    ## [33m>> studienform <<[0m erfolgreich erhoben
    ## [33m>> studienort <<[0m erfolgreich erhoben
    ## [33m>> studienart <<[0m erfolgreich erhoben

    ## Versuche >>zurueck<<-Button zu finden Nr.  1  von maximal  10  ...

    ## Zurueck zur uebersicht...

    ## Versuch Kurs-URL zu betaetigen Nr.  1  von maximal  10  ...

    ## Kursseite erfolgreich betreten. Starte das Scraping des Kurses:  20.9. Virtual Exchange: Erwerb interkultureller Kompetenz durch virtuellen Austausch

    ## Kurs-URL-Selector:  #genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:9\:tableRowAction

    ## Versuch Studiengaenge in Registerkarte >>Termine<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Termine<<

    ## [33m>> Titel <<[0m erfolgreich erhoben
    ## [33m>> Nummer <<[0m erfolgreich erhoben
    ## [33m>> Organisationseinheit <<[0m erfolgreich erhoben
    ## [33m>> Veranstaltungsart <<[0m erfolgreich erhoben
    ## [33m>> Angebotshäufigkeit <<[0m erfolgreich erhoben
    ## [33m>> Maximale Anzahl Teilnehmer/-innen <<[0m erfolgreich erhoben

    ## Versuch Registerkarte >>Inhalte<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Inhalte<<

    ## Anzahl gefundener Container in der Registerkarte >>Inhalte<<: 3

    ## [33m>> empfehlung <<[0m erfolgreich erhoben
    ## [33m>> inhalte <<[0m erfolgreich erhoben
    ## [33m>> qualifikationsziel <<[0m erfolgreich erhoben

    ## Versuch Module in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping der Registerkarte >>Module/Studiengaenge<<

    ## 
    ## Selenium message:no such element: Unable to locate element: {"method":"css selector","selector":"#detailViewData\:tabContainer\:term-planning-container\:modules\:moduleAssignments"}
    ##   (Session info: chrome=134.0.6998.35)
    ## For documentation on this error, please visit: https://www.seleniumhq.org/exceptions/no_such_element.html
    ## Build info: version: '4.0.0-alpha-2', revision: 'f148142cf8', time: '2019-07-01T21:30:10'
    ## System info: host: 'SL-SV-073', ip: '192.168.178.90', os.name: 'Windows 10', os.arch: 'amd64', os.version: '10.0', java.version: '21.0.4'
    ## Driver info: driver.version: unknown

    ## Keine Module gefunden. Rueckgabe eines leeren Tibbles.

    ## Versuch Studiengaenge in Registerkarte >>Module/Studiengaenge<< zu finden Nr.  1  von maximal  10  ...

    ## Starte das Scraping des HTML-Tables >>Studiengaenge<<

    ## [33m>> standardtext <<[0m erfolgreich erhoben
    ## [33m>> typ <<[0m erfolgreich erhoben
    ## [33m>> abschluss <<[0m erfolgreich erhoben
    ## [33m>> fach <<[0m erfolgreich erhoben
    ## [33m>> vertiefung <<[0m erfolgreich erhoben
    ## [33m>> schwerpunkt <<[0m erfolgreich erhoben
    ## [33m>> fachkennzeichen <<[0m erfolgreich erhoben
    ## [33m>> prufungsordnungsversion <<[0m erfolgreich erhoben
    ## [33m>> studienform <<[0m erfolgreich erhoben
    ## [33m>> studienort <<[0m erfolgreich erhoben
    ## [33m>> studienart <<[0m erfolgreich erhoben

    ## Versuche >>zurueck<<-Button zu finden Nr.  1  von maximal  10  ...

    ## Zurueck zur uebersicht...

    ## Scrapingprozess erfolgreich beendet

### Beende Prozess

Wir schließen den Remotedriver und beenden den entsprechenden
Java-Prozess.

``` r
rmdr$close()
system("taskkill /im java.exe /f", intern = FALSE, ignore.stdout = FALSE)
```

    ## [1] 0

### Bekannte Probleme

#### Abbruch des Scraping und Wiederaufnahme

Trotz aller Mühe, scrapet das Funktionspaket i.d.R. nicht \>6000 Kurse
ohne absturz durch. Noch ist es unklar, warum weiterhin abstürze
geschehen. Sollten Abstürze passieren, kann im Terminal der Selector des
letzten Kurses gesucht werden, der nicht mehr erfolgreich gescrapet
wurde. Dieser könnte Beispielsweise so aussehen:
`#genSearchRes\:id3df798d58b4bacd9\:id3df798d58b4bacd9Table\:156\:tableRowAction`.
Da es recht müheselig ist, den Chromdriver wieder auf die
Übersichtsseite manuel zu bewegen, auf der der letze Kurs nicht mehr
erfolgreich gescrapet wurde, wurde die Funktion
`go_to_last_active_page()` geschrieben. Ihr muss nur die Instanznummer
des Selectors übergeben werden. Anschließend navigiert die Funktion den
Driver zur entsprechenden Übersichtsseite und zündet ein Signalton bei
Fertigstellung.

``` r
library(RSelenium)
driver <- rsDriver(
  browser = "chrome",
  chromever = "latest",
  port = 1234L
)
```

    ## checking Selenium Server versions:

    ## BEGIN: PREDOWNLOAD

    ## BEGIN: DOWNLOAD

    ## BEGIN: POSTDOWNLOAD

    ## checking chromedriver versions:

    ## BEGIN: PREDOWNLOAD

    ## BEGIN: DOWNLOAD

    ## BEGIN: POSTDOWNLOAD

    ## checking geckodriver versions:

    ## BEGIN: PREDOWNLOAD

    ## BEGIN: DOWNLOAD

    ## BEGIN: POSTDOWNLOAD

    ## checking phantomjs versions:

    ## BEGIN: PREDOWNLOAD

    ## BEGIN: DOWNLOAD

    ## BEGIN: POSTDOWNLOAD

    ## [1] "Connecting to remote server"
    ## $acceptInsecureCerts
    ## [1] FALSE
    ## 
    ## $browserName
    ## [1] "chrome"
    ## 
    ## $browserVersion
    ## [1] "134.0.6998.35"
    ## 
    ## $chrome
    ## $chrome$chromedriverVersion
    ## [1] "133.0.6943.141 (2a5d6da0d6165d7b107502095a937fe7704fcef6-refs/branch-heads/6943@{#1912})"
    ## 
    ## $chrome$userDataDir
    ## [1] "C:\\Users\\mhu\\AppData\\Local\\Temp\\scoped_dir20536_967687731"
    ## 
    ## 
    ## $`fedcm:accounts`
    ## [1] TRUE
    ## 
    ## $`goog:chromeOptions`
    ## $`goog:chromeOptions`$debuggerAddress
    ## [1] "localhost:62278"
    ## 
    ## 
    ## $networkConnectionEnabled
    ## [1] FALSE
    ## 
    ## $pageLoadStrategy
    ## [1] "normal"
    ## 
    ## $platformName
    ## [1] "windows"
    ## 
    ## $proxy
    ## named list()
    ## 
    ## $setWindowRect
    ## [1] TRUE
    ## 
    ## $strictFileInteractability
    ## [1] FALSE
    ## 
    ## $timeouts
    ## $timeouts$implicit
    ## [1] 0
    ## 
    ## $timeouts$pageLoad
    ## [1] 300000
    ## 
    ## $timeouts$script
    ## [1] 30000
    ## 
    ## 
    ## $unhandledPromptBehavior
    ## [1] "dismiss and notify"
    ## 
    ## $`webauthn:extension:credBlob`
    ## [1] TRUE
    ## 
    ## $`webauthn:extension:largeBlob`
    ## [1] TRUE
    ## 
    ## $`webauthn:extension:minPinLength`
    ## [1] TRUE
    ## 
    ## $`webauthn:extension:prf`
    ## [1] TRUE
    ## 
    ## $`webauthn:virtualAuthenticators`
    ## [1] TRUE
    ## 
    ## $webdriver.remote.sessionid
    ## [1] "9fc7d97a932747fd329c7c72ff42cbdb"
    ## 
    ## $id
    ## [1] "9fc7d97a932747fd329c7c72ff42cbdb"

``` r
rmdr <- driver[["client"]]
rmdr$maxWindowSize()

SVScrapeR::select_semester_and_set_courses(
  rmdr,
  base_url,
  num_sem_selector,
  num_courses,
  sem_dropdown,
  search_field,
  num_courses_selector
)

Sys.sleep(3)

go_to_last_active_page(rmdr, 126)
```

    ## Zielseite des spezifizierten Selectors: Seite 13.

    ## Seite wird angesteuert...

    ## clicke zehn Seiten weiter...

    ## Springe zu Seite 10

    ## Versuche >>weiter<<-Button zu finden Nr.  1  von maximal  10  ...

    ## >>weiter<<-Button gefunden. Zeige die naechste uebersichtsseite an...

    ## Naechste uebersichtseite erfolgreich angesteuert!

    ## Weiter zu Seite 12

    ## Versuche >>weiter<<-Button zu finden Nr.  1  von maximal  10  ...

    ## >>weiter<<-Button gefunden. Zeige die naechste uebersichtsseite an...

    ## Naechste uebersichtseite erfolgreich angesteuert!

    ## Weiter zu Seite 13

    ## Ziel (Seite  13 ) fuer Selector 126 erreicht

#### Beende Prozess

Wir schließen den Remotedriver und beenden den entsprechenden
Java-Prozess.

``` r
rmdr$close()
system("taskkill /im java.exe /f", intern = FALSE, ignore.stdout = FALSE)
```

    ## [1] 0
