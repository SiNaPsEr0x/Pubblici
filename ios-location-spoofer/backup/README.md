# ios-location-spoofer backup

Backup pubblico del progetto originale `SiNaPsEr0x/ios-location-spoofer`.

- Baseline originale: `bfb44fa3b00e2cc8820536fb58e375d7269ef90a`
- Revisione rolling Release verificata: `9dfc64786539b627efe41d023c55caa864b1e4b5`
- Workflow storico: `original/build.yml`
- File personalizzati ripristinabili: `customized/`

La configurazione corrente mantiene una sola GitHub Release con tag stabile `latest`, una sola IPA non firmata e nessun artifact IPA storico nelle Actions. Il versioning è `ISO-year.ISO-week.ISO-weekday` in fuso `Europe/Rome`.

Il backup è volutamente fuori da `.github/workflows/` di questa repository e non può quindi essere eseguito come workflow di `Pubblici`.

Per il recupero, confrontare sempre il progetto aggiornato con i file salvati qui e ripristinare solo ciò che serve. Non fare reset completo della repository originale.

## Runtime fix verificato

La build verificata `1edb09f33fddd204dab1c1d48c1bb28e714d7560` passa le coordinate direttamente al Packet Tunnel tramite start options. Questo evita che l'attivazione dipenda dalla sincronizzazione App Group/UserDefaults tra app ed estensione. L'IPC `getCoords` resta solo diagnostico.
