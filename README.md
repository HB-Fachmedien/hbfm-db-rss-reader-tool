# hbfm-db-rss-reader-tool

## Install Bug
materialize-css hat noch einen Bug zur Zeit. Die Datei picker.js wird ins falsche Verzeichnis kopiert, siehe
https://github.com/Dogfalo/materialize/issues/3139

richtig wäre "cp node_modules/materialize-css/js/date_picker/picker.js node_modules/materialize-css/bin"

ich hoffe, der Bug wird bald bei materialize behoben

## Ausführbare exe Applikation bauen
```sh
$ npm run-script package
```
im /dist Ordner findet sich dann die Produktiv Version.
> **JEDOCH VORSICHT:**
> ich weiß nicht, ob ich die package.json fehlerhaft konfiguriert habe oder ob electron-packager gerade buggy ist, es der **node_modules** Ordner wird nicht komplett kopiert sowie saxon.jar und der xsl Ordner müssen noch in den Rootordner verschoben werden

--> ToDo

## To Use

...

**Build with Electron**
Learn more about Electron and its API in the [documentation](http://electron.atom.io/docs/latest).

## dev links:

https://beta.der-betrieb.de/dachportal/feed/?cat=11

https://beta.der-betrieb.de/dachportal/meldungen/test123/

https://www.der-betrieb.de/category/meldungen/feed/