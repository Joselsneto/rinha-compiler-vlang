# Rinha de compiler Vlang

Não sei o que eu to fazendo, mas to fazendo. Nunca fiz um compiler, e nunca programei em Vlang, mas tá sendo divertido.

### Como executar

#### Com docker

```
docker build -t rinha .
docker run rinha
```

#### Sem docker
##### Requisitos
1. Vlang >= 0.4.1 instalado

```
v run src/main.v var/rinha/source.rinha.json
```

### Checklist
- [x] File
- [x] Location
- [x] Parameter
- [x] Var
- [x] Function
- [x] Call
- [x] Let
- [x] Str
- [x] Int
- [x] BinaryOp
- [x] Bool
- [x] If
- [x] Binary
- [x] Tuple
- [x] First
- [x] Second
- [x] Print
- [x] Term
