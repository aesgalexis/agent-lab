# Preparación de Windows

## Inventario observado el 31-08-2026

- Windows Pro, build 26200, 16 GB de RAM.
- GPU integrada AMD Radeon 740M, controlador `32.0.21030.5005`.
- Git 2.55.0 instalado.
- Ollama 0.33.2 instalado; `qwen2.5-coder:7b` ocupa aproximadamente 4,7 GB.
- WSL, Docker, Node, npm y Python no estaban instalados.
- Node, npm y Python no son requisitos del host para la arquitectura elegida.

## Paso manual con administrador

Abre **PowerShell como administrador** y ejecuta exactamente:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
Restart-Computer
```

El reinicio es necesario para activar el hipervisor y WSL 2. Si Windows informa que la virtualización está deshabilitada, actívala en BIOS/UEFI antes de continuar.

Después del reinicio, abre PowerShell normal:

```powershell
wsl --install --no-distribution
wsl --update
wsl --version
```

WSL debe ser 2.1.5 o posterior. No hace falta instalar Ubuntu: Docker Desktop mantiene sus propias distribuciones internas.

## Docker Desktop

Instala Docker Desktop en modo por usuario con backend WSL 2. Es el modo recomendado actual y no añade soporte innecesario para contenedores Windows ni el servicio privilegiado permanente.

Después de descargar el instalador oficial:

```powershell
Start-Process '.\Docker Desktop Installer.exe' -Wait -ArgumentList 'install', '--user', '--backend=wsl-2', '--no-windows-containers'
```

Inicia Docker Desktop una vez, acepta sus términos si son compatibles con tu uso y espera a que indique que el engine está listo. Para uso personal, educativo, open source no comercial y pequeñas empresas Docker Desktop es gratuito; organizaciones mayores deben revisar su licencia.

Comprueba:

```powershell
docker --version
docker compose version
docker info
```

## Ollama nativo y Ollama en Compose

El preflight instaló Ollama nativo y verificó el modelo. El stack completo usa el contenedor Ollama para mantener la API accesible a Agent Canvas sin exponerla a la LAN. Ambos reutilizan `%USERPROFILE%/.ollama`, pero no deben ejecutarse al mismo tiempo.

Antes de arrancar Compose, detén la aplicación nativa:

```powershell
.\scripts\stop-native-ollama.ps1
```
Para una prueba directa sin Docker:

```powershell
.\scripts\start-native-ollama.ps1
.\scripts\test-model.ps1
.\scripts\stop-native-ollama.ps1
```
