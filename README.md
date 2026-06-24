# mi-primer-sofware

## Fórmulas de inversión rentables en acciones

`acciones.py` contiene 5 fórmulas para analizar y valorar acciones de bolsa:

| # | Fórmula | Para qué sirve |
|---|---------|----------------|
| 1 | **Rentabilidad total** | Ganancia por precio + dividendos |
| 2 | **CAGR** | Rentabilidad media anualizada |
| 3 | **PER** | Saber si la acción está cara o barata |
| 4 | **Rentabilidad por dividendo** | Cuánto cobras en dividendos |
| 5 | **Modelo de Gordon** | Valor intrínseco de la acción |

### Uso

```bash
python acciones.py
```

O importa las funciones en tu propio código:

```python
from acciones import rentabilidad_total, cagr, per, rentabilidad_dividendo, modelo_gordon

print(cagr(precio_inicial=100, precio_final=200, anios=7))  # 10.41 % anual
```
