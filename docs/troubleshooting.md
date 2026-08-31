# Problemas encontrados y soluciones

## WSL no estaba instalado

`wsl --install --no-distribution` devolvió que WSL no estaba instalado, y DISM desde la sesión no elevada devolvió el error 740. Se habilitaron `Microsoft-Windows-Subsystem-Linux` y `VirtualMachinePlatform` desde PowerShell elevado. DISM devolvió 3010, que significa éxito pendiente de reinicio, no fallo. Tras reiniciar quedaron activos WSL 2.7.12 y kernel 6.18.33.2.

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

## Qwen devuelve la herramienta como JSON de texto

Con `native_tool_calling=true`, `qwen2.5-coder:7b` devolvió `{"name":"task_tracker",...}` como un mensaje normal y OpenHands terminó sin ejecutar la herramienta. El perfil reproducible fija `native_tool_calling=false`; así el SDK inyecta su formato de herramientas y produjo `TerminalAction` y `FileEditorAction` válidas. Esta opción es deliberada para este modelo, no una configuración legacy de la interfaz.

## Primera iteración lenta

El prompt inicial de OpenHands fue de aproximadamente 7.700 tokens y, usando CPU, tardó varios minutos en procesarse. Ollama mostró uso de unos seis núcleos y cerca de 5,9 GiB. No era un bloqueo: después de crear la caché, las acciones posteriores tardaron decenas de segundos. Para mayor velocidad o modelos mayores, conserva la arquitectura y mueve sólo el endpoint de inferencia a hardware remoto.

## Git detecta propiedad dudosa en el montaje

Git dentro del contenedor detectó distinta identidad de propietario para el bind mount de Windows. Compose establece `safe.directory=/projects/sandbox-project` mediante variables `GIT_CONFIG_*`; el permiso queda limitado a este único workspace y no modifica la configuración Git del host.
