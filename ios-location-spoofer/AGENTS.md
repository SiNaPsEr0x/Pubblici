# AGENTS.md

## Ambito
Queste regole valgono solo per la cartella `ios-location-spoofer/` dentro `SiNaPsEr0x/Pubblici`.

## Scopo
Conservare copie pubbliche di sicurezza e configurazioni utili del progetto originale `SiNaPsEr0x/ios-location-spoofer`, senza trasformare la root di `Pubblici` in documentazione specifica del progetto.

## Struttura
- `backup/original/`: configurazioni storiche precedenti alle personalizzazioni.
- `backup/customized/`: configurazioni e script correnti da poter ripristinare.
- `backup/manifest.json`: stato verificato, commit e dettagli tecnici del backup.
- `backup/README.md`: istruzioni di recupero specifiche del progetto.

## Regole
- Mantenere sincronizzati workflow, `project.yml` e script di build quando la CI del progetto originale cambia.
- Non salvare certificati, provisioning profile, token o altri segreti.
- Il workflow salvato qui deve restare fuori da `.github/workflows/` di `Pubblici`.
- Il progetto originale usa una sola Release rolling con tag `latest`, una sola IPA e versioning `ISO-year.ISO-week.ISO-weekday` in fuso Europe/Rome.
- Prima di ripristinare file dopo un aggiornamento upstream, confrontare le differenze e non sovrascrivere indiscriminatamente il progetto.

## Ultima verifica runtime
- Commit sorgente verificato: `1edb09f33fddd204dab1c1d48c1bb28e714d7560`.
- Run GitHub Actions: `35914949898`, conclusione `success`.
- Correzione importante: le coordinate vengono passate direttamente nelle start options del Packet Tunnel; l'IPC di conferma è solo diagnostico e non blocca più l'attivazione.

## iOS 27 persistent VPN
- Commit verificato: `bdea353c758c3f44f5bacca7a182bfa0d19f1377`, run `35916907202` conclusa con successo.
- Il tunnel è proxy-only e non dichiara più una default route IP senza packetFlow.
- Il proxy HTTP/S usa `matchDomains = [""]`; il DNS custom è stato rimosso.
- La VPN resta attiva dopo il tutorial, usa Connect On Demand e viene riattivata automaticamente all'apertura dell'app o dopo una disconnessione inattesa.
- I file runtime personalizzati sono salvati anche sotto `backup/customized/App/` e `backup/customized/Tunnel/`.
