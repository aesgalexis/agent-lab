# Problemas encontrados y soluciones

## WSL no está instalado

`wsl --install --no-distribution` devolvió que WSL no estaba instalado, y DISM desde la sesión no elevada devolvió el error 740. Solución: ejecutar los dos comandos DISM de [`windows-setup.md`](windows-setup.md) en PowerShell como administrador y reiniciar.

## El instalador de Docker Desktop no terminaba

La instalación por usuario extrajo correctamente Docker Desktop 4.88.1, añadió la CLI al PATH y dejó Docker/Compose operativos, pero sus procesos bootstrap no finalizaron mientras WSL seguía ausente. Tras verificar los binarios y el manifiesto firmado, se detuvieron esos procesos. No se debe iniciar el engine hasta habilitar WSL 2 y reiniciar.

## La aplicación de bandeja de Ollama no mantenía la API

Ollama 0.33.2 se instaló correctamente, pero la GUI agotó el tiempo de espera y dejó `server.log` vacío. El binario `ollama serve` sí funcionó. Los scripts del repositorio gestionan el servidor nativo explícitamente y guardan sus logs en `.runtime/logs`, evitando depender del estado de la bandeja.

## Ollama no usa la GPU AMD

Los logs indican que el controlador AMD es demasiado antiguo para ROCm y que la Radeon 740M integrada se descarta. La prueba se ejecutó en CPU y respondió en 6,8 segundos para una salida corta. Actualizar el controlador AMD puede mejorar compatibilidad; no se fuerza `HSA_OVERRIDE_GFX_VERSION` porque falsear la arquitectura de GPU es frágil.

Docker Desktop en Windows sólo documenta passthrough de GPU NVIDIA para contenedores WSL 2. Por eso la fase 1 asume CPU en el contenedor. Para modelos mayores, la opción limpia es inferencia remota o hardware compatible.

## Contexto insuficiente

El valor predeterminado detectado fue 4096. OpenHands advierte que su prompt de sistema requiere al menos 22000 tokens. El laboratorio fija `OLLAMA_CONTEXT_LENGTH=32768`. Si aparecen errores de memoria en este equipo de 16 GB, cierra aplicaciones pesadas; reducirlo por debajo de 22000 degradará o impedirá el funcionamiento del agente.

## El puerto 11434 está ocupado

El Ollama nativo y el contenedor no pueden publicar el mismo puerto simultáneamente. Ejecuta:

```powershell
.\scripts\stop-native-ollama.ps1
.\scripts\start.ps1
```

## Agent Canvas no valida el perfil

Comprueba desde el punto de vista del backend:

```powershell
docker compose exec agent-canvas python -c "import urllib.request; print(urllib.request.urlopen('http://ollama:11434/v1/models').read().decode())"
```

El modelo debe incluir el prefijo `openai/` en Agent Canvas, pero no en el inventario de Ollama. La URL debe ser `http://ollama:11434/v1`, nunca `127.0.0.1`, porque el backend vive en otro contenedor.
