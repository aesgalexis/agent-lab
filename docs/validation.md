# Registro de validación

Fecha: 31-08-2026, zona horaria Europe/Madrid.

## Completado

| Comprobación | Resultado |
| --- | --- |
| Repositorio remoto | `origin=https://github.com/aesgalexis/agent-lab.git` |
| Git | 2.55.0 |
| Ollama nativo | 0.33.2, API limitada a `127.0.0.1:11434` |
| Modelo | `qwen2.5-coder:7b`, inventariado por `GET /v1/models` |
| Respuesta del modelo | `AGENT_LAB_MODEL_OK`, 6,8 s en primera medición y 7,5 s desde el script |
| Hardware de inferencia | CPU; AMD Radeon 740M descartada por controlador incompatible |
| Docker Desktop | 4.88.1, instalación por usuario |
| Docker CLI | 29.7.2 |
| Docker Compose | 5.4.0 |
| WSL | 2.7.12; kernel 6.18.33.2; versión predeterminada 2 |
| Compose del laboratorio | ambos contenedores activos; Ollama saludable; Canvas HTTP 200 |
| Agent Canvas / Agent Server | 1.16.0 / 1.44.0 |
| Red interna | Agent Canvas inventaría Qwen mediante `http://ollama:11434/v1/models` |
| Perfil OpenHands | `ollama-local`, validado mediante completion y activado por API |
| Scripts PowerShell | todos analizados por el parser sin errores |
| Exclusión de secretos/estado | `.env` y `.runtime/` confirmados mediante `git check-ignore` |
| Fixture del agente | dos tests fallan antes de la reparación, como se esperaba |
| Conversación E2E | `183f685c-c730-44d2-8838-554fd5c8f15c`, estado `finished`, 29 eventos |
| Uso del modelo por OpenHands | `openai/qwen2.5-coder:7b`, 32768 de contexto, coste registrado 0 |
| Herramientas observadas | terminal, editor de archivos y finalización estructurada |
| Resultado | 2 tests ejecutados tras la edición, 2 correctos; `AGENT_RESULT.md` creado |

## Resultado de la fase 1

La prueba OpenHands está completada. La primera conversación con llamadas nativas quedó registrada como diagnóstico; la segunda usó el conversor no nativo, ejecutó ocho acciones y completó el ciclo solicitado. El estado y las conversaciones permanecen en `.runtime/openhands`.
