In questa cartella ci sono le prove per il prossimo incontro: 3 acc vs 1 acc

Ho rifatto i calcoli con accuracy, Precision, Recall, F1-measure

I file sono divisi in questa maniera:
	- Quelli con nome RateTotale sono con intervalli da 1 a 5 secondi ed overlap possibile da 0.5 a 4.5
	- Quelli con nome RateTotale1 sono con intervalli da 1 a 2.5 secondi ed overlap possibile da 0.5 a 2 (quindi quelli accettabili da noi)
	
Quello che si può dire è che le stime massime che si raggiungono sono simili, anche se con intervalli diversi, per cui si può usare benissimo un solo accelerometro.
Non c'è un intervallo che predomina sugli altri, ogni paziente, in base all'algoritmo, ha il suo migliore.

Possibile prova: fissiamo un intervallo preciso (tipo 2 secondi e 1 di overlap o 2 secondi e 0.5 overlap) e vediamo i risultati che si ottengono

Inoltre ho messo anche le prove per: 64 samples vs 32 samples vs 16

Ho rifatto i calcoli con accuracy, Precision, Recall, F1-measure

I file sono divisi in questa maniera:
	- Quelli con nome RateTotale_16 sono quelli campionati a 16 samples per secondo con intervalli da 1 a 5 secondi ed overlap possibile da 0.5 a 4.5
	- Quelli con nome RateTotale_32 sono quelli campionati a 32 samples per secondo con intervalli da 1 a 5 secondi ed overlap possibile da 0.5 a 4.5
	- Quelli con nome RateTotale1_16 sono quelli campionati a 16 samples per secondo con intervalli da 1 a 2.5 secondi ed overlap possibile da 0.5 a 2 (quindi quelli accettabili da noi)
	- Quelli con nome RateTotale1_32 sono quelli campionati a 32 samples per secondo con intervalli da 1 a 2.5 secondi ed overlap possibile da 0.5 a 2 (quindi quelli accettabili da noi)
	
Quello che si può dire è che le stime sono in media le stesse, anche se più abbasso il campionamento e meglio sembra