In questa cartella ci sono le prove per il prossimo incontro: 3 acc vs 1 acc

Ho rifatto i calcoli con accuracy, Precision, Recall, F1-measure

I file sono divisi in questa maniera:
	- Quelli con nome RateTotale sono con intervalli da 1 a 5 secondi ed overlap possibile da 0.5 a 4.5
	- Quelli con nome RateTotale1 sono con intervalli da 1 a 2.5 secondi ed overlap possibile da 0.5 a 2 (quindi quelli accettabili da noi)
	
Quello che si può dire è che le stime massime che si raggiungono sono simili, anche se con intervalli diversi, per cui si può usare benissimo un solo accelerometro.
Non c'è un intervallo che predomina sugli altri, ogni paziente, in base all'algoritmo, ha il suo migliore.
Esempio con distanza euclidea e RateTotale1
Quelle rappresentate sono le medie tra le 4 misure

Tutti		|Caviglia		|Ginocchio		|Schiena
--------------------------------------------------------------
0.61		|0.57			|0.47			|0.64
0.55		|0.43			|0.55			|0.55
0.68		|0.53			|0.63			|0.62
0.33		|0.33			|0.33			|0.33
0.50		|0.46			|0.5			|0.5
0.47		|0.5			|0.46			|0.51
0.47		|0.52			|0.47			|0.53
0.51		|0.45			|0.51			|0.51
0.55		|0.55			|0.54			|0.55
0.33		|0.33			|0.33			|0.3
--------------------------------------------------------------
0.5			|0.47			|0.51			|0.51

Possibile prova: fissiamo un intervallo preciso (tipo 2 secondi e 1 di overlap o 2 secondi e 0.5 overlap) e vediamo i risultati che si ottengono

Inoltre ho messo anche le prove per: 64 samples vs 32 samples vs 16

Ho rifatto i calcoli con accuracy, Precision, Recall, F1-measure

I file sono divisi in questa maniera:
	- Quelli con nome RateTotale_16 sono quelli campionati a 16 samples per secondo con intervalli da 1 a 5 secondi ed overlap possibile da 0.5 a 4.5
	- Quelli con nome RateTotale_32 sono quelli campionati a 32 samples per secondo con intervalli da 1 a 5 secondi ed overlap possibile da 0.5 a 4.5
	- Quelli con nome RateTotale1_16 sono quelli campionati a 16 samples per secondo con intervalli da 1 a 2.5 secondi ed overlap possibile da 0.5 a 2 (quindi quelli accettabili da noi)
	- Quelli con nome RateTotale1_32 sono quelli campionati a 32 samples per secondo con intervalli da 1 a 2.5 secondi ed overlap possibile da 0.5 a 2 (quindi quelli accettabili da noi)
	
Quello che si può dire è che le stime sono in media le stesse
Esempi con distanza euclidea e RateTotale prima, poir RateTotale1

64				|32				|16		
--------------------------------------------			
0.61/2.44		|0.71/2.82		|0.59/2.37
0.56/2.24		|0.57/2.29		|0.59/2.37
0.68/2.71		|0.70/2.78		|0.63/2.51
0.33/1.33		|0.33/1.33		|0.33/1.33
0.5/2			|0.61/2.42		|0.64/2.56
0.58/2.33		|0.47/1.89		|0.60/2.41
0.53/2.12		|0.61/2.45		|0.60/2.41
0.51/2.04		|0.57/2.26		|0.45/1.8
0.59/2.39		|0.56/2.23		|0.66/2.63
0.33/1.33		|0.33/1.33		|0.33/1.33
--------------------------------------------
0.522			|0.546			|0.542

64				|32				|16
--------------------------------------------
0.61/2.44		|0.59/2.34		|0.59/2.34
0.55/2.21		|0.57/2.29		|0.67/2.67
0.68/2.71		|0.53/2.12		|0.63/2.51
0.33/1.33		|0.33/1.33		|0.33/1.33
0.5/2			|0.51/2.03		|0.55/2.21
0.47/1.86		|0.47/1.89		|0.60/2.41
0.47/1.88		|0.48/1.92		|0.48/1.92
0.51/2.03		|0.56/2.24		|0.45/1.80
0.55/2.18		|0.56/2.24		|0.66/2.64
0.33/1.33		|0.33/1.33		|0.33/1.33
--------------------------------------------
0.5				|0.493			|0.529

