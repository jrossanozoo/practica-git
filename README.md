# Práctica Git

Repositorio para práctica y demostración del trabajo con GIT.

## Descripción

Este repositorio está diseñado para aprender y practicar los conceptos fundamentales de Git y GitHub. Aquí encontrarás ejercicios, ejemplos y guías para dominar el control de versiones.

## Contenido

### Conceptos Básicos de Git

1. **Inicialización y Configuración**
   ```bash
   git config --global user.name "Tu Nombre"
   git config --global user.email "tu@email.com"
   git init
   ```

2. **Comandos Fundamentales**
   - `git add`: Agregar archivos al área de staging
   - `git commit`: Confirmar cambios en el repositorio
   - `git status`: Ver el estado actual del repositorio
   - `git log`: Ver el historial de commits

3. **Trabajo con Ramas (Branches)**
   ```bash
   git branch <nombre-rama>      # Crear una nueva rama
   git checkout <nombre-rama>    # Cambiar a una rama
   git checkout -b <nombre-rama> # Crear y cambiar a una rama
   git merge <nombre-rama>       # Fusionar una rama
   git branch -d <nombre-rama>   # Eliminar una rama
   ```

4. **Trabajo Remoto**
   ```bash
   git remote add origin <url>   # Agregar repositorio remoto
   git push origin <rama>         # Enviar cambios al remoto
   git pull origin <rama>         # Obtener cambios del remoto
   git clone <url>                # Clonar un repositorio
   ```

## Ejercicios Prácticos

### Ejercicio 1: Primer Commit
1. Clona este repositorio
2. Crea un nuevo archivo `hola.txt` con tu nombre
3. Agrega el archivo al staging area
4. Realiza tu primer commit

### Ejercicio 2: Trabajo con Ramas
1. Crea una nueva rama llamada `desarrollo`
2. Cambia a esa rama
3. Modifica algún archivo
4. Realiza un commit en la rama `desarrollo`
5. Vuelve a la rama principal y fusiona los cambios

### Ejercicio 3: Resolución de Conflictos
1. Crea dos ramas diferentes
2. Modifica el mismo archivo en ambas ramas
3. Intenta fusionar las ramas
4. Resuelve el conflicto manualmente

## Flujos de Trabajo (Workflows)

### Git Flow Básico
```
main (producción)
  └── develop (desarrollo)
       ├── feature/nueva-funcionalidad
       ├── feature/otra-funcionalidad
       └── hotfix/correccion-urgente
```

### Proceso de Contribución
1. Fork del repositorio
2. Crear una rama para tu funcionalidad
3. Realizar commits con mensajes descriptivos
4. Push a tu fork
5. Crear un Pull Request

## Buenas Prácticas

- **Commits frecuentes**: Realiza commits pequeños y frecuentes
- **Mensajes descriptivos**: Usa mensajes de commit claros y concisos
- **Ramas temáticas**: Crea ramas para cada funcionalidad o corrección
- **Pull antes de Push**: Siempre actualiza tu repositorio local antes de enviar cambios
- **Revisa antes de commit**: Usa `git diff` para revisar tus cambios

## Comandos Útiles

```bash
# Ver diferencias
git diff

# Ver historial gráfico
git log --graph --oneline --all

# Deshacer cambios
git checkout -- <archivo>
git reset HEAD <archivo>

# Ver ramas
git branch -a

# Guardar cambios temporalmente
git stash
git stash pop
```

## Recursos Adicionales

- [Documentación oficial de Git](https://git-scm.com/doc)
- [Pro Git Book (Español)](https://git-scm.com/book/es/v2)
- [GitHub Guides](https://guides.github.com/)

## Contribuir

¡Las contribuciones son bienvenidas! Si deseas agregar más ejercicios o ejemplos:

1. Haz fork del repositorio
2. Crea una rama para tu contribución
3. Realiza tus cambios
4. Envía un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.