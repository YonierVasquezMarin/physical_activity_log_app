# Inicialización del Proyecto Physical Activity Log

Este documento describe el proceso de inicialización del proyecto Flutter **Physical Activity Log**.

## Requisitos Previos

Antes de inicializar o trabajar con este proyecto, es necesario tener instalado lo siguiente:

- **Android Studio**: Necesario para la configuración inicial del proyecto Android y la descarga de dependencias de Gradle. Puedes descargarlo desde [developer.android.com/studio](https://developer.android.com/studio)

- **Extensión Flutter para VS Code**: Necesaria para el desarrollo y ejecución del proyecto desde Visual Studio Code. Puedes instalarla desde el marketplace de VS Code buscando "Flutter" o desde [marketplace.visualstudio.com](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)

> **Nota**: Aunque Android Studio es necesario para la primera configuración, el desarrollo diario se puede realizar desde VS Code una vez completada la inicialización.

## Comando de Inicialización

El proyecto fue creado utilizando el siguiente comando de Flutter:

```bash
flutter create . --project-name physical_activity_log_app --org com.company --platforms android,ios
```

## Explicación del Comando

### `flutter create`
Comando de Flutter CLI que genera la estructura base de un nuevo proyecto Flutter.

### `.` (punto)
Indica que el proyecto debe crearse en el directorio actual, en lugar de crear un nuevo directorio. Esto es útil cuando ya tienes un directorio preparado para el proyecto.

### `--project-name physical_activity_log_app`
Especifica el nombre interno del proyecto. Este nombre:
- Se utiliza como identificador del paquete Dart
- Aparece en el archivo `pubspec.yaml` como `name: physical_activity_log_app`
- Se usa para generar nombres de clases y archivos relacionados

### `--org com.company`
Define la organización o dominio inverso que se utilizará como prefijo del identificador del paquete:
- **Android**: El package name será `com.company.physical_activity_log_app`
  - Se refleja en: `android/app/src/main/kotlin/com/company/physical_activity_log_app/MainActivity.kt`
- **iOS**: El bundle identifier será `com.company.physicalActivityLogApp`
  - Se refleja en la configuración del proyecto Xcode

### `--platforms android,ios`
Especifica qué plataformas nativas deben incluirse en el proyecto:
- **android**: Genera la estructura del proyecto Android con Gradle
- **ios**: Genera la estructura del proyecto iOS con Xcode

Otras plataformas disponibles (no incluidas en este proyecto):
- `web`: Para aplicaciones web
- `windows`: Para aplicaciones de escritorio Windows
- `macos`: Para aplicaciones de escritorio macOS
- `linux`: Para aplicaciones de escritorio Linux

## Estructura Generada

El comando genera la siguiente estructura de directorios y archivos principales:

```
physical_activity_log_app/
├── android/          # Proyecto Android nativo
│   ├── app/
│   │   └── src/
│   │       └── main/
│   │           └── kotlin/
│   │               └── com/
│   │                   └── company/
│   │                       └── physical_activity_log_app/
│   │                           └── MainActivity.kt
│   └── build.gradle.kts
├── ios/              # Proyecto iOS nativo
│   └── Runner/
│       └── AppDelegate.swift
├── lib/              # Código fuente Dart/Flutter
│   └── main.dart     # Punto de entrada de la aplicación
├── test/             # Pruebas unitarias y de widgets
│   └── widget_test.dart
├── pubspec.yaml      # Configuración de dependencias y metadatos
└── README.md         # Documentación básica del proyecto
```

## Configuración del Proyecto

### Identificadores de Paquete

- **Dart Package**: `physical_activity_log_app`
- **Android Package**: `com.company.physical_activity_log_app`
- **iOS Bundle ID**: `com.company.physicalActivityLogApp`

### Plataformas Soportadas

- ✅ Android
- ✅ iOS

## Próximos Pasos

Después de la inicialización, los pasos típicos incluyen:

1. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

2. **Verificar la configuración**:
   ```bash
   flutter doctor
   ```

3. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

4. **Agregar dependencias** en `pubspec.yaml` según las necesidades del proyecto

## Notas Adicionales

- El proyecto utiliza el SDK de Dart `^3.10.7` (según `pubspec.yaml`)
- La aplicación está configurada para usar Material Design (`uses-material-design: true`)
- El proyecto está configurado como privado (`publish_to: 'none'`)

---

**Fecha de creación**: Documento creado durante la fase de inicialización del proyecto.
