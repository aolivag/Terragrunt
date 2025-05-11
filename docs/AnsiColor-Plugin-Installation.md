# Instalación del Plugin AnsiColor en Jenkins

Si deseas tener una salida coloreada en los logs de Jenkins para mejor legibilidad, puedes instalar el plugin AnsiColor siguiendo estos pasos:

1. Accede a la interfaz web de Jenkins
2. Navega a "Administrar Jenkins" > "Administrar Plugins"
3. Haz clic en la pestaña "Disponibles"
4. Busca "AnsiColor" en el campo de búsqueda
5. Marca la casilla junto a "AnsiColor Plugin"
6. Haz clic en "Instalar sin reiniciar" o "Descargar ahora e instalar después de reiniciar"
7. Espera a que se complete la instalación

Una vez instalado el plugin, puedes volver a habilitar la opción en el Jenkinsfile cambiando:

```groovy
options {
    timeout(time: 30, unit: 'MINUTES')
    disableConcurrentBuilds()
    // Nota: Si deseas usar colores ANSI, necesitas instalar el plugin "AnsiColor" en Jenkins
}
```

por:

```groovy
options {
    timeout(time: 30, unit: 'MINUTES')
    disableConcurrentBuilds()
    ansiColor('xterm')
}
```

Esto hará que los logs en la consola de Jenkins muestren colores, facilitando la identificación de errores (en rojo) y éxitos (en verde).
