# Activitate saptamana 6 - tema 2

## Definirea originala a automatului

```python
class FiniteAutomaton:
    def __init__(self, filename=None):
        self.filename = filename    # filename to read from
        self.states = set()         # Q
        self.alphabet = set()       # sigma
        self.initial_state = None     # q0
        self.final_states = set()  # F
        self.transitions = {}       # delta

        if self.filename is not None:
            self.load_from_file(self.filename)
        else:
            self.load_from_console()

        print("FA loaded")
    ...
```

## Tipurile fieldurilor

```yaml
FiniteAutomaton:
    filename: str
    states: set[str]      # am putea avea un obiect state
    alphabet: set[str]
    initial_state: str
    final_states: set[str]
    transitions: map[tuple[str, str], List[str]]
```


## Code review

**nitpicks**
1.
```python 
if self.filename is not None:
    ...
```
could be
```python 
if self.filename:
    ...
```
2.
In
```python 
self.load_from_file(self.filename)
```
we dont need to pass the filename, the object already has it. 
Now he is passing the filename to himself

3.
the whole load logic could be only one method, where we read from filename when it's not
null, and we read from stdin when it is null
