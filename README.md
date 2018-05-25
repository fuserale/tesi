#tesi

Nella cartella 2 cluster:
  - Dataset
  - Script per FOG+NOFOG
  -  interval_2cl contiene i dati sperimentali divisi per pazienti 
  
Nelle cartelle 3Cluster-Caviglia/Ginocchio/Schiena:
  - Dataset
  - Script per FOG+NOFOG+PREFOG
  - interval_3cl contiene i dati sperimentali divisi per pazienti e accelerometro usato
  
Nella cartella 3Cluster:
  - Dataset
  - Script per FOG+NOFOG+PREFOG
  - interval_3cl contiene i dati sperimentali divisi per pazienti usando tutti gli accelerometri
  
Nella cartella 3ClusterReduce:
  - Dataset
  - Script per FOG+NOFOG+PREFOG con dimensionalità dei dati ridotta
  - interval_3cl contiene i dati sperimentali divisi per pazienti usando tutti gli accelerometri
  
Nella cartella 3Cluster_16/32samples:
  - Dataset
  - Script per FOG+NOFOG+PREFOG prendendo frequenze di campionamento diverse
  - interval_3cl contiene i dati sperimentali divisi per pazienti usando tutti gli accelerometri
  
Le cartelle Alessandro Fuser, Articoli, tex_tesi contengono articoli vari

Le cartelle Prossimo incontro e Test_Florenc si potrebbero anche eliminare, sono test temporanei che avevo fatto per i nostri incontri

La cartella 3ClusterReduce - copia si può anche eliminare in quanto conviene test di prove diverse ma che non han no portato a dei risultati utili

Le FeatureFusion:
  - Script e dati con LDA
  - Script e dati (ridotti in dimensionalità[Reduce]) con LDA
  - Script e dati (con classi unite[NOFOG_FOG & PREFOG_FOG]) con LDA
  
Nella cartella Dynamics:
  - Dataset & Plot
  - Script con intervalli dinamici
  - rate contiene i risultati sperimentali ad intervalli dinamici
  
La sequenza generale di lancio dei file di script del clustering dentro ogni cartella è:
  1) [do_3cluster.m] per creare o togliere le etichette di PREFOG (3)
  2) extract_feature per creare le tabelle di feature
  3) clutering_corporate_bonds per applicare gli algoritmi di clustering
  4) rate per trovare quanto ho indovinato per ogni algoritmo
  5) max_rate per torvare il miglior algoritmo
  
Per le cartelle di FeatureFusion, ogni file è a se stante e può essere lanciato singolarmente in base alla necessità di quello che si vuole
