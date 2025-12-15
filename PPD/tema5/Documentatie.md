# Documentatie Laborator 5

## Rezultate

### Configurație Test
- **Studenți:** 500
- **Readers (p_r):** 4 (fix)
- **Workers (p_w):** 2, 4, 8
- **Queue capacity:** 100
- **Minimum note per proiect:** 80
- **Probabilitate copiere:** 5%

### Timpi de Execuție

```
Sequential:           0.014425 seconds
Parallel p_r=4 p_w=2: 0.060693 seconds
Parallel p_r=4 p_w=4: 0.021206 seconds
Parallel p_r=4 p_w=8: 0.023040 seconds
```

### Analiza Performanței

| Configurație | Time (s) | Speedup vs Seq | Workers |
|--------------|----------|----------------|---------|
| Sequential | 0.014425 | 1.00x | - |
| Parallel p_w=2 | 0.060693 | 0.24x | 2 |
| Parallel p_w=4 | 0.021206 | 0.68x | 4 |
| Parallel p_w=8 | 0.023040 | 0.63x | 8 |

### Observații

1. **Overhead-ul paralelismului la dataset-uri mici**

   La 500 de studenți, overhead-ul creat de:
   - Crearea și managementul threadurilor
   - Sincronizare (locks, condition variables, synchronized blocks)
   - Context switching între threaduri
   - Comunicare prin BoundedQueue

   **Depașește** beneficiile paralelizarii. Secvențialul e mai rapid.

2. **Sweet spot: p_w=4**

   Configurația cu 4 workers ofera cea mai buna performanța paralela:
   - p_w=2: prea puțini workers, unii stau idle
   - p_w=4: balans optim între paralelism și overhead ✅
   - p_w=8: prea mulți workers se bat pe locks


3. **Când ar deveni paralelul mai rapid?**

   La dataset-uri mai mari (5000+ studenți, 100+ proiecte):
   - Timpul de procesare a datelor crește
   - Overhead-ul threadurilor devine neglijabil relativ
   - Fine-grain locking permite paralelism real
   - Expect: speedup liniar pâna la p_w=numar de core-uri


## Corectitudine

Verificare rezultate identice:
```bash
sort data/rezultate_sequential.txt > /tmp/seq.txt
sort data/rezultate_parallel_pr4_pw4.txt > /tmp/par.txt
diff /tmp/seq.txt /tmp/par.txt
```