# AGENTS.md

## Scopo della repository
Questa repository è un contenitore pubblico generico per file, configurazioni, backup e materiali riutilizzabili relativi a progetti diversi. Non è dedicata a un singolo progetto.

## Regole di organizzazione
- Leggere questo file prima di modificare la repository e rispettare eventuali `AGENTS.md` più specifici nelle sottocartelle.
- Il `README.md` nella root deve restare generico e non deve contenere informazioni, stato, cronologia o istruzioni specifiche di singoli progetti.
- Ogni progetto o sorgente originale deve avere una propria cartella di primo livello con un nome riconoscibile, preferibilmente uguale al progetto originale.
- Backup, workflow, configurazioni e istruzioni specifiche vanno sotto la cartella del relativo progetto, normalmente in `<progetto>/backup/`.
- Le regole e la storia specifiche di un progetto vanno in `<progetto>/AGENTS.md` e, se serve, in `<progetto>/backup/README.md`.
- Non creare cartelle di backup globali che mescolano progetti diversi quando il backup appartiene chiaramente a un progetto specifico.
- Preservare sempre file e cartelle non correlati alla modifica richiesta.

## Sicurezza
- Non salvare token, password, chiavi private, certificati di firma, provisioning profile o altri segreti.
- I backup di GitHub Actions devono restare fuori da `.github/workflows/` di questa repository, così non possono essere eseguiti accidentalmente.
- Prima di ripristinare un backup sopra un progetto aggiornato, confrontare le differenze e ripristinare solo i file ancora necessari.

## Manutenzione
Quando viene aggiunto o aggiornato un progetto, mantenere aggiornato il relativo `AGENTS.md` locale. La root deve continuare a descrivere soltanto lo scopo generale e le regole comuni della repository.
