# Sandbox Project

Proyecto mínimo para demostrar el ciclo completo de un agente. Es deliberadamente simple y no depende de paquetes externos.

El archivo `src/text_stats.py` contiene un defecto intencional. Los tests describen el comportamiento correcto. La tarea exacta para el agente está en `TASK.md`.

```bash
python -m unittest discover -s tests -v
```

Antes de que el agente trabaje, una prueba debe fallar. Después de la corrección, ambas deben pasar y debe existir `AGENT_RESULT.md`.
