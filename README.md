# MIPS Team Battle Manager

Progetto universitario sviluppato in **Assembly MIPS** per il corso di **Architettura degli Elaboratori**.

L'applicazione implementa un sistema completo per la gestione di giocatori, squadre e partite tramite un menu interattivo, con particolare attenzione all'utilizzo delle principali tecniche di programmazione Assembly e delle strutture dati dinamiche.

> **Nota:** questo progetto è stato realizzato esclusivamente a scopo didattico come elaborato universitario.

---

## Funzionalità

Il programma permette di:

- Creare e gestire giocatori
- Creare e gestire squadre
- Assegnare giocatori alle squadre
- Visualizzare giocatori e squadre
- Ricercare giocatori tramite ID
- Ricercare squadre tramite nome
- Simulare duelli tra giocatori
- Simulare partite tra squadre
- Registrare lo storico delle partite
- Visualizzare la cronologia delle partite
- Generare la classifica dei giocatori
- Generare la classifica delle squadre
- Individuare il giocatore più forte
- Individuare la squadra più forte
- Visualizzare le partite vinte da una squadra
- Elencare i giocatori senza squadra
- Eliminazione logica di giocatori e squadre
- Ricerca ricorsiva di un giocatore all'interno del roster di una squadra

---

## Concetti implementati

Durante lo sviluppo sono stati utilizzati diversi argomenti trattati nel corso, tra cui:

- Programmazione Assembly MIPS
- Gestione dello stack
- Procedure e passaggio dei parametri
- Chiamate ricorsive
- Tabelle di salto (Jump Table)
- Gestione dinamica della memoria tramite syscall
- Implementazione di una struttura dati dinamica simile ad una `ArrayList`
- Ricerca lineare
- Ordinamento e classifiche
- Simulazione di eventi
- Eliminazione logica degli elementi

---

## Strutture dati

Il progetto utilizza tre strutture dati principali:

- **Giocatori**
- **Squadre**
- **Partite**

Tutte vengono memorizzate all'interno di ArrayList dinamiche implementate interamente in Assembly, che aumentano automaticamente la capacità quando necessario.

---

## Requisiti

Per eseguire il progetto è necessario utilizzare:

- **MARS (MIPS Assembler and Runtime Simulator)**

Il codice è compatibile con le syscall fornite da MARS.

---

## Avvio

1. Aprire il file Assembly in MARS.
2. Assemblare il progetto.
3. Avviare l'esecuzione.
4. Utilizzare il menu numerico per accedere alle varie funzionalità.

---

## Struttura del progetto

Il codice è organizzato in moduli dedicati alle diverse responsabilità dell'applicazione:

- gestione delle strutture dati
- gestione dei giocatori
- gestione delle squadre
- simulazione di duelli e partite
- funzioni di ricerca
- funzioni di stampa
- classifiche e statistiche
- menu principale

---

## Obiettivi didattici

Questo progetto è stato realizzato con l'obiettivo di applicare concretamente i principali concetti di Architettura degli Elaboratori, sviluppando un'applicazione non banale interamente in Assembly MIPS.

Particolare attenzione è stata dedicata a:

- modularità del codice;
- riutilizzo delle procedure;
- gestione della memoria;
- utilizzo della ricorsione;
- progettazione di strutture dati dinamiche.

---

## Tecnologie

- Assembly MIPS
- MARS Simulator

---

## Licenza

Questo repository viene pubblicato esclusivamente a scopo dimostrativo e didattico.

È consentito consultare il codice per fini di studio, ma se il progetto viene riutilizzato in un contesto accademico è responsabilità dell'utilizzatore rispettare il regolamento del proprio corso e le norme sul plagio.
