# Documentatie Laborator 5

## Rezultate

### Configuratie Test
- **Studenti:** 500
- **Readers (p_r):** 4 (fix)
- **Workers (p_w):** 2, 4, 8
- **Queue capacity:** 100
- **Minimum note per proiect:** 80
- **Probabilitate copiere:** 5%

### Timpi de Executie

```
Sequential:           0.014425 seconds
Parallel p_r=4 p_w=2: 0.060693 seconds
Parallel p_r=4 p_w=4: 0.021206 seconds
Parallel p_r=4 p_w=8: 0.023040 seconds
```

### Analiza Performantei

| Configuratie | Time (s) | Speedup vs Seq | Workers |
|--------------|----------|----------------|---------|
| Sequential | 0.014425 | 1.00x | - |
| Parallel p_w=2 | 0.060693 | 0.24x | 2 |
| Parallel p_w=4 | 0.021206 | 0.68x | 4 |
| Parallel p_w=8 | 0.023040 | 0.63x | 8 |

### Observatii

1. **Overhead-ul paralelismului la dataset-uri mici**

   La 500 de studenti, overhead-ul creat de:
   - Crearea si managementul threadurilor
   - Sincronizare (locks, condition variables, synchronized blocks)
   - Context switching intre threaduri
   - Comunicare prin BoundedQueue

   **Depaseste** beneficiile paralelizarii. Secventialul e mai rapid.

2. **Sweet spot: p_w=4**

   Configuratia cu 4 workers ofera cea mai buna performanta paralela:
   - p_w=2: prea putini workers, unii stau idle
   - p_w=4: optim
   - p_w=8: prea multi workers se bat pe locks


3. **Cand ar deveni paralelul mai rapid?**

La dataset-uri mai mari overhead-ul threadurilor devine neglijabil relativ


## Verificare

```bash
sort data/rezultate_sequential.txt > /tmp/seq.txt
sort data/rezultate_parallel_pr4_pw4.txt > /tmp/par.txt
diff /tmp/seq.txt /tmp/par.txt
```
