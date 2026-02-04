#!/bin/bash
# Script de ejemplo para demostrar Git con un proyecto simple

echo "=== Inicializando repositorio de práctica ==="
echo ""

# Crear estructura de directorios
echo "Creando estructura de directorios..."
mkdir -p proyecto-practica
cd proyecto-practica

# Inicializar Git
echo "Inicializando repositorio Git..."
git init

# Crear archivo README
echo "Creando README.md..."
echo "# Proyecto de Práctica" > README.md
echo "" >> README.md
echo "Este es un proyecto de ejemplo para practicar Git." >> README.md

# Primer commit
echo "Realizando primer commit..."
git add README.md
git commit -m "Initial commit: Add README"

# Crear rama de desarrollo
echo "Creando rama de desarrollo..."
git checkout -b desarrollo

# Agregar más contenido
echo "Agregando más archivos..."
echo "console.log('Hola Mundo');" > app.js
git add app.js
git commit -m "Add JavaScript file"

# Volver a main y fusionar
echo "Fusionando cambios a main..."
git checkout main
git merge desarrollo

echo ""
echo "=== Repositorio de práctica creado exitosamente ==="
echo "Ubicación: $(pwd)"
echo ""
echo "Comandos útiles:"
echo "  git log --oneline --graph --all"
echo "  git status"
echo "  git branch"
