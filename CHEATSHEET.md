# Git Cheat Sheet - Hoja de Referencia Rápida

## Configuración Inicial
```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
git config --list                          # Ver configuración
```

## Crear Repositorios
```bash
git init                                   # Inicializar nuevo repositorio
git clone <url>                            # Clonar repositorio existente
```

## Cambios Básicos
```bash
git status                                 # Ver estado actual
git add <archivo>                          # Agregar archivo específico
git add .                                  # Agregar todos los archivos
git commit -m "mensaje"                    # Confirmar cambios
git commit -am "mensaje"                   # Add + commit de archivos modificados
```

## Historial
```bash
git log                                    # Ver historial completo
git log --oneline                          # Historial resumido
git log --graph --all --oneline            # Historial gráfico
git show <commit>                          # Ver detalles de un commit
```

## Ramas (Branches)
```bash
git branch                                 # Listar ramas locales
git branch -a                              # Listar todas las ramas
git branch <nombre>                        # Crear nueva rama
git checkout <nombre>                      # Cambiar a una rama
git checkout -b <nombre>                   # Crear y cambiar a nueva rama
git merge <nombre>                         # Fusionar rama
git branch -d <nombre>                     # Eliminar rama (fusionada)
git branch -D <nombre>                     # Forzar eliminación de rama
```

## Remotos
```bash
git remote -v                              # Ver remotos configurados
git remote add origin <url>                # Agregar remoto
git push origin <rama>                     # Enviar cambios
git push -u origin <rama>                  # Enviar y establecer upstream
git pull origin <rama>                     # Obtener cambios
git fetch                                  # Descargar cambios sin fusionar
```

## Deshacer Cambios
```bash
git checkout -- <archivo>                  # Descartar cambios en archivo
git reset HEAD <archivo>                   # Quitar archivo del staging
git reset --soft HEAD~1                    # Deshacer último commit (mantener cambios)
git reset --hard HEAD~1                    # Deshacer último commit (eliminar cambios)
git revert <commit>                        # Crear commit que deshace otro commit
```

## Diferencias
```bash
git diff                                   # Ver cambios no staged
git diff --staged                          # Ver cambios staged
git diff <rama1> <rama2>                   # Comparar ramas
```

## Stash (Guardar Temporalmente)
```bash
git stash                                  # Guardar cambios temporalmente
git stash list                             # Ver lista de stashes
git stash apply                            # Aplicar último stash
git stash pop                              # Aplicar y eliminar último stash
git stash drop                             # Eliminar último stash
```

## Tags (Etiquetas)
```bash
git tag                                    # Listar tags
git tag <nombre>                           # Crear tag ligero
git tag -a <nombre> -m "mensaje"           # Crear tag anotado
git push origin <tag>                      # Enviar tag
git push origin --tags                     # Enviar todos los tags
```

## Otros Comandos Útiles
```bash
git clean -fd                              # Eliminar archivos no rastreados
git cherry-pick <commit>                   # Aplicar commit específico
git blame <archivo>                        # Ver quién modificó cada línea
git reflog                                 # Ver historial de referencias
```

## Alias Útiles
```bash
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual 'log --graph --oneline --all'
```

## Flujo de Trabajo Típico
```bash
# 1. Actualizar repositorio local
git pull origin main

# 2. Crear rama para nueva funcionalidad
git checkout -b feature/nueva-funcionalidad

# 3. Realizar cambios y commits
git add .
git commit -m "Agrega nueva funcionalidad"

# 4. Enviar rama al remoto
git push origin feature/nueva-funcionalidad

# 5. Crear Pull Request en GitHub

# 6. Después de aprobar, fusionar y actualizar local
git checkout main
git pull origin main
git branch -d feature/nueva-funcionalidad
```
