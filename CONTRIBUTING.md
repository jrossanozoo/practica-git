# Guía de Contribución

¡Gracias por tu interés en contribuir a este repositorio de práctica Git!

## Cómo Contribuir

### 1. Fork y Clone
```bash
# Haz fork del repositorio en GitHub
# Luego clona tu fork
git clone https://github.com/TU_USUARIO/practica-git.git
cd practica-git
```

### 2. Configura el Upstream
```bash
git remote add upstream https://github.com/jrossanozoo/practica-git.git
git fetch upstream
```

### 3. Crea una Rama
```bash
git checkout -b feature/nombre-descriptivo
```

### 4. Realiza tus Cambios
- Escribe código claro y bien documentado
- Sigue las convenciones de estilo del proyecto
- Agrega ejemplos prácticos cuando sea posible

### 5. Commit tus Cambios
```bash
git add .
git commit -m "Descripción clara de los cambios"
```

### Formato de Mensajes de Commit
- Usa el imperativo: "Agrega" en lugar de "Agregado"
- Primera línea: resumen breve (máximo 50 caracteres)
- Línea en blanco
- Descripción detallada si es necesario

Ejemplos:
```
Agrega ejercicio de resolución de conflictos

Incluye un nuevo ejercicio que ayuda a los estudiantes
a practicar la resolución de conflictos en Git.
```

### 6. Push y Pull Request
```bash
git push origin feature/nombre-descriptivo
```

Luego crea un Pull Request en GitHub desde tu rama hacia `main`.

## Tipos de Contribuciones

- **Nuevos ejercicios**: Agrega ejercicios prácticos para aprender Git
- **Mejoras a la documentación**: Clarifica o expande la documentación existente
- **Corrección de errores**: Reporta o corrige errores en los ejemplos
- **Traducciones**: Ayuda a traducir el contenido a otros idiomas

## Código de Conducta

- Sé respetuoso con otros contribuyentes
- Acepta críticas constructivas
- Enfócate en lo mejor para la comunidad de aprendizaje

## ¿Preguntas?

Si tienes preguntas, abre un issue en el repositorio.
