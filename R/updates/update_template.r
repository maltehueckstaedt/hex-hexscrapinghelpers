# Lade devtools
library(devtools)
library(janitor)

# 1. Setze das Arbeitsverzeichnis auf dein Paketverzeichnis
setwd("C:/Users/mhu/Documents/gitlab/hex-hexscrapinghelpers")
pkgload::load_all()

# 2. Aktualisiere die DESCRIPTION-Datei (z. B. Version erhöhen, Abhängigkeiten anpassen)

# Semantische Versionierung (MAJOR.MINOR.PATCH):
#
# major: Inkompatible Änderungen
#   → z. B. alte Funktionen entfernt oder stark geändert
#   → Beispiel: 2.3.1 → 3.0.0
#
# minor: Neue Funktionen, aber abwärtskompatibel
#   → z. B. neue Funktionen hinzugefügt
#   → Beispiel: 2.3.1 → 2.4.0
#
# patch: Fehlerbehebungen, kleine Änderungen
#   → z. B. Bugfix, Tippfehler korrigiert
#   → Beispiel: 2.3.1 → 2.3.2

usethis::use_version("major")
2
# 3. Führe Checks durch, um sicherzustellen, dass alles funktioniert
devtools::check()  # Oder check(document = TRUE) falls nötig

# 4. Dokumentiere Funktionen neu (generiert NAMESPACE und .Rd-Dateien)
devtools::document()

# 5. Erstelle das Paket neu
devtools::build()

# 6. Installiere die aktuelle Version lokal
devtools::install()

# Optional: Paket auf CRAN vorbereiten
# devtools::release()  # Nur verwenden, wenn tatsächlich ein CRAN-Release geplant ist
