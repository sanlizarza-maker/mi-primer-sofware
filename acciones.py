"""
Fórmulas de inversión rentables en ACCIONES (bolsa)
===================================================

Cinco fórmulas clave para analizar y valorar acciones, y decidir si una
inversión es rentable. Las tasas se expresan en decimal (8% = 0.08).

Ejecuta este archivo para ver una demostración:

    python acciones.py
"""

from __future__ import annotations


# ---------------------------------------------------------------------------
# 1. Rentabilidad total de una acción
# ---------------------------------------------------------------------------
def rentabilidad_total(precio_compra: float, precio_venta: float,
                       dividendos: float = 0.0) -> float:
    """Rentabilidad total de una acción en porcentaje.

    Suma la ganancia por revalorización del precio y los dividendos cobrados.

    Fórmula:  R = ((Pventa - Pcompra + Dividendos) / Pcompra) * 100

    Args:
        precio_compra: Precio al que compraste la acción.
        precio_venta: Precio actual o de venta de la acción.
        dividendos: Dividendos totales cobrados por acción en el periodo.

    Returns:
        La rentabilidad total en porcentaje (positivo = ganancia).
    """
    if precio_compra == 0:
        raise ValueError("El precio de compra no puede ser cero.")
    return ((precio_venta - precio_compra + dividendos) / precio_compra) * 100


# ---------------------------------------------------------------------------
# 2. CAGR (rentabilidad anualizada)
# ---------------------------------------------------------------------------
def cagr(precio_inicial: float, precio_final: float, anios: float) -> float:
    """Tasa de crecimiento anual compuesta (CAGR) de una acción, en porcentaje.

    Indica la rentabilidad media anualizada a lo largo de varios años.

    Fórmula:  CAGR = ((Pfinal / Pinicial) ** (1 / años) - 1) * 100

    Args:
        precio_inicial: Precio al inicio del periodo.
        precio_final: Precio al final del periodo.
        anios: Número de años transcurridos.

    Returns:
        La rentabilidad anualizada en porcentaje.
    """
    if precio_inicial <= 0 or anios <= 0:
        raise ValueError("Precio inicial y años deben ser mayores que cero.")
    return ((precio_final / precio_inicial) ** (1 / anios) - 1) * 100


# ---------------------------------------------------------------------------
# 3. PER (Price / Earnings Ratio)
# ---------------------------------------------------------------------------
def per(precio_accion: float, bpa: float) -> float:
    """Ratio Precio/Beneficio (PER) de una acción.

    Indica cuántos años de beneficios pagas por la acción. Un PER bajo
    frente a su sector suele indicar que la acción está "barata".

    Fórmula:  PER = Precio de la acción / BPA

    Args:
        precio_accion: Precio de cotización de la acción.
        bpa: Beneficio por acción (EPS) = Beneficio neto / nº de acciones.

    Returns:
        El PER (número de veces que el precio contiene el beneficio anual).
    """
    if bpa == 0:
        raise ValueError("El beneficio por acción (BPA) no puede ser cero.")
    return precio_accion / bpa


# ---------------------------------------------------------------------------
# 4. Rentabilidad por dividendo (Dividend Yield)
# ---------------------------------------------------------------------------
def rentabilidad_dividendo(dividendo_anual: float, precio_accion: float) -> float:
    """Rentabilidad por dividendo de una acción, en porcentaje.

    Mide cuánto cobras en dividendos respecto al precio que pagas.

    Fórmula:  Yield = (Dividendo anual por acción / Precio) * 100

    Args:
        dividendo_anual: Dividendo anual pagado por acción.
        precio_accion: Precio actual de la acción.

    Returns:
        La rentabilidad por dividendo en porcentaje.
    """
    if precio_accion == 0:
        raise ValueError("El precio de la acción no puede ser cero.")
    return (dividendo_anual / precio_accion) * 100


# ---------------------------------------------------------------------------
# 5. Modelo de Gordon (valor intrínseco por dividendos)
# ---------------------------------------------------------------------------
def modelo_gordon(dividendo_proximo: float, rentabilidad_exigida: float,
                  crecimiento_dividendo: float) -> float:
    """Valor intrínseco de una acción según el Modelo de Gordon-Shapiro.

    Valora la acción como el descuento de sus dividendos futuros que crecen
    a una tasa constante. Si el valor calculado es mayor que el precio de
    mercado, la acción podría estar infravalorada (oportunidad de compra).

    Fórmula:  Valor = D1 / (k - g)

    Args:
        dividendo_proximo: Dividendo esperado del próximo año (D1).
        rentabilidad_exigida: Rentabilidad exigida por el inversor (k), en decimal.
        crecimiento_dividendo: Tasa de crecimiento del dividendo (g), en decimal.

    Returns:
        El valor intrínseco estimado de la acción.
    """
    if rentabilidad_exigida <= crecimiento_dividendo:
        raise ValueError("La rentabilidad exigida (k) debe ser mayor que el "
                         "crecimiento del dividendo (g).")
    return dividendo_proximo / (rentabilidad_exigida - crecimiento_dividendo)


# ---------------------------------------------------------------------------
# Demostración
# ---------------------------------------------------------------------------
def _demo() -> None:
    print("=" * 64)
    print("  5 FÓRMULAS DE INVERSIÓN RENTABLES EN ACCIONES")
    print("=" * 64)

    print("\n1) Rentabilidad total de una acción")
    r = rentabilidad_total(precio_compra=100, precio_venta=130, dividendos=5)
    print(f"   Compra 100, vende 130, +5 dividendos -> {r:.2f}%")

    print("\n2) CAGR (rentabilidad anualizada)")
    r = cagr(precio_inicial=100, precio_final=200, anios=7)
    print(f"   De 100 a 200 en 7 años -> {r:.2f}% anual")

    print("\n3) PER (Price / Earnings)")
    p = per(precio_accion=50, bpa=2.5)
    print(f"   Precio 50, BPA 2.5 -> PER = {p:.1f}x")

    print("\n4) Rentabilidad por dividendo")
    y = rentabilidad_dividendo(dividendo_anual=3, precio_accion=60)
    print(f"   Dividendo 3, precio 60 -> {y:.2f}%")

    print("\n5) Modelo de Gordon (valor intrínseco)")
    v = modelo_gordon(dividendo_proximo=4, rentabilidad_exigida=0.10,
                      crecimiento_dividendo=0.04)
    print(f"   D1=4, k=10%, g=4% -> valor intrínseco = {v:,.2f}")

    print("\n" + "=" * 64)


if __name__ == "__main__":
    _demo()
