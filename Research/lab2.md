# Lab 2 - Proiect de cercetare

## Visualization-Oriented Logs for Debugging Distributed Systems

## Articole stiintifice selectate

### 1. **Debugging Distributed Systems**
**Autori:** Darren Dao, Jeannie Albrecht, Charles Killian, Amin Vahdat  
**Publicat in:** Compiler Construction (CC 2009), LNCS 5501, pp. 94-108, 2009

**Relevanta pentru proiect:**  
Articolul prezinta MaceODB, un tool pentru debugging online care verifica proprietati in timpul executiei sistemelor distribuite. Este relevant deoarece acopera capturarea starii runtime si verificarea proprietatilor, concepte fundamentale pentru log-urile orientate pe vizualizare.  

**Structura articolului:**
- **1. Introduction** - Provocari ale debugging-ului sistemelor distribuite  
- **2. Design of MaceODB** - Design-ul tool-ului (proprietati safety/liveness, evaluare centralizata/descentralizata, snapshots)  
- **3. Implementation** - Detalii de implementare  
- **4. Experiences Using MaceODB** - Cazuri practice (RandTree, Chord)  
- **5. Performance Evaluation** - Overhead si scalabilitate  
- **6. Related Work** - Comparatii cu alte tehnici  
- **7. Conclusions** - Contributii si rezultate  

**Referinte bibliografice:**  
17 referinte in stil IEEE/ACM. Format: autori, titlu, conferinta/jurnal, volum, pagini, an. Exemplu: "[1] C. E. Killian et al. Mace: Language support for building distributed systems. In PLDI, 2007."  

---

### 2. **Visual Debugging Techniques for Reactive Data Visualization**
**Autori:** Jane Hoffswell, Arvind Satyanarayan, Jeffrey Heer  
**Publicat in:** Computer Graphics Forum (Proc. EuroVis), Vol. 35, No. 3, 2016  

**Relevanta pentru proiect:**  
Descrie tehnici vizuale de debugging pentru vizualizari reactive (timeline view, replay, inspectie stari). Aceste tehnici sunt direct aplicabile pentru vizualizarea log-urilor sistemelor distribuite, oferind metode interactive de explorare a executiilor.  

**Structura articolului:**
- **1. Introduction** - Provocari debugging sisteme reactive  
- **2. Related Work** - Functional Reactive Programming, debuggers bazati pe timeline/replay, reprezentari vizuale  
- **3. Background: The Vega Visualization Grammar** - Prezentare sistem Vega  
- **4. Visual Debugging Techniques** - Timeline, annotations, data tables, linked highlighting  
- **5. Implementation** - Detalii tehnice  
- **6. Evaluation** - Studii cu utilizatori  
- **7. Discussion and Future Work** - Limitari si directii viitoare  
- **8. Conclusion** - Rezumat contributii  

**Referinte bibliografice:**  
17 referinte in format ACM. Structura: autori (initiala prenume), an, titlu, conferinta/jurnal, volume/pages, DOI optional. Exemplu: "Guo P. J. 2013. Online Python Tutor. In CHI '13, 579-584."  

---

### 3. **Debugging Distributed Systems: Challenges and Options for Validation and Debugging**
**Autori:** Ivan Beschastnikh, Patty Wang, Yuriy Brun, Michael D. Ernst  
**Publicat in:** ACM Queue, Vol. 14, No. 2, March-April 2016

**Relevanta pentru proiect:**  
Ofera un overview complet al provocarilor si metodelor de debugging pentru sisteme distribuite, incluzand log analysis si visualization. Esential pentru contextul teoretic al proiectului, acoperind atat aspecte fundamentale cat si solutii practice.

**Structura articolului:**
- **Introduction** - Overview provocari sisteme distribuite
- **Distributed-System Features and Challenges** - Heterogeneity, concurrency, distributed state, partial failures
- **Existing Approaches** - Testing, model checking, theorem proving, record/replay, tracing, log analysis, visualization
- **Visualizing Distributed System Executions** - ShiViz: time-space diagrams, happens-before relation, features interactive
- **Understanding Distributed-System Executions** - Event ordering, querying, comparing executions
- **Acknowledgments si References** - Multumiri si bibliografie

**Referinte bibliografice:**  
17 referinte, format ACM. Include: numar, autori (nume complet), an, titlu, publisher/conferinta, volume/pages, URL. Exemplu: "1. Bernstein, P., Hadzilacos, V., Goodman, N. 1986. Distributed recovery. In Concurrency Control and Recovery in Database Systems. Addison-Wesley."

---

### 4. **Visualizing Distributed System Executions**
**Autori:** Ivan Beschastnikh, Perry Liu, Albert Xing, Patty Wang, Yuriy Brun, Michael D. Ernst  
**Publicat in:** ACM Transactions on Software Engineering and Methodology, Vol. 29, No. 2, Article 9, March 2020

**Relevanta pentru proiect:**  
Prezinta ShiViz, platforma completa pentru vizualizare si debugging, bazata pe diagrame time-space si vector clocks. Ofera solutii concrete pentru capturarea si vizualizarea executiilor distribuite, concepte centrale pentru log-urile orientate pe vizualizare.

**Structura articolului:**
- **Abstract** - Rezumat contributii
- **1. Introduction** - Motivatie si provocari
- **2. Preliminaries** - Model asincron, distributed timestamps
- **3. Example Use Cases** - Trei scenarii practice
- **4. Support for Log Understanding** - Event ordering, graph queries, multi-execution comparison
- **5. Implementation** - XVector si ShiViz (logging happens-before, parsing, implementare)
- **6. Evaluation** - Studii cu 100+ dezvoltatori (understanding systems, development, overhead, scalability)
- **7. Threats to Validity** - Limitari studiu
- **8. Discussion** - Limitari si directii viitoare
- **9. Related Work** - Comparatie detaliata
- **10. Contributions** - Rezumat contributii
- **Acknowledgments si References** - 125 referinte

**Referinte bibliografice:**  
125 referinte in format ACM TOSEM. Structura: [numar] Autori (initiala prenume). An. Titlu. In: Conferinta/Jurnal. Volume(numar): pagini. DOI. Exemplu: "[10] Ivan Beschastnikh et al. 2014. Inferring models of concurrent systems from logs. In ICSE'14. 468-479."

---

### 5. **Fully-Distributed Debugging and Visualization of Distributed Systems in Anonymous Networks**
**Autori:** Jeremie Chalopin, Yves Metivier, Thomas Morsellino  
**Publicat in:** Proceedings of ICINCO 2011 (International Conference on Informatics in Control, Automation and Robotics)

**Relevanta pentru proiect:**  
Prezinta ViSiDiA, platforma pentru simulare, vizualizare si debugging al algoritmilor distribuiti in retele anonime. Relevant deoarece abordeaza debugging-ul complet distribuit fara identificatori sau sincronizare, oferind perspective teoretice si practice pentru vizualizare.

**Structura articolului:**
- **Abstract** - Overview contributii
- **1. Introduction** - Context si contributii principale
- **2. Preliminaries** - Model teoretic (asynchronous message passing, snapshots, global predicates)
- **3. The ViSiDiA Platform** - Arhitectura, network graph, procese, mesaje, simulare, monitoring/debugging, API
- **4. Debugging Distributed Algorithms** - Chandy-Lamport snapshot, termination detection, GPE algorithm, evaluare teoretica
- **5. Related Work** - Comparatie cu alte tool-uri
- **6. Conclusion** - Rezumat si directii viitoare
- **References** - Bibliografie

**Referinte bibliografice:**  
Aproximativ 30 referinte in format academic standard. Include: Autori (nume, initiale), (an), titlu, conferinta/jurnal, volume(numar), pagini, publisher. Exemplu: "Chandy, K. M. and Lamport, L. (1985). Distributed snapshots: Determining global states of distributed systems. ACM Trans. Comput. Syst., 3(1):63-75."

---

## Referinte bibliografice

[1] Dao, D., Albrecht, J., Killian, C., and Vahdat, A. (2009). Debugging distributed systems. In *Compiler Construction (CC 2009)*, Lecture Notes in Computer Science, vol. 5501, pp. 94-108. Springer-Verlag Berlin Heidelberg.

[2] Hoffswell, J., Satyanarayan, A., and Heer, J. (2016). Visual debugging techniques for reactive data visualization. *Computer Graphics Forum (Proceedings of EuroVis)*, 35(3), pp. 1-10. DOI: 10.1111/cgf.12903

[3] Beschastnikh, I., Wang, P., Brun, Y., and Ernst, M. D. (2016). Debugging distributed systems: Challenges and options for validation and debugging. *ACM Queue*, 14(2), pp. 32-37. DOI: 10.1145/2909480

[4] Beschastnikh, I., Liu, P., Xing, A., Wang, P., Brun, Y., and Ernst, M. D. (2020). Visualizing distributed system executions. *ACM Transactions on Software Engineering and Methodology*, 29(2), Article 9, pp. 9:1-9:38. DOI: 10.1145/3375633

[5] Chalopin, J., Metivier, Y., and Morsellino, T. (2011). Fully-distributed debugging and visualization of distributed systems in anonymous networks. In *Proceedings of the 8th International Conference on Informatics in Control, Automation and Robotics (ICINCO 2011)*, pp. 531-536.