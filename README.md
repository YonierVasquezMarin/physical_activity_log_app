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

## Conexión con el Backend

La aplicación se comunica con una API REST alojada en **Render** mediante peticiones **HTTPS** en formato **JSON**.

| Aspecto | Detalle |
|---------|---------|
| **Protocolo** | REST sobre HTTPS |
| **Cliente HTTP** | Paquete [`http`](https://pub.dev/packages/http), encapsulado en `lib/services/http_service.dart` |
| **URL base** | `https://physical-activity-log-api.onrender.com/api/v1` (definida en `lib/constants/api_constants.dart`) |
| **Autenticación** | Bearer Token (JWT). Tras iniciar sesión, el token se envía en el encabezado `Authorization: Bearer <token>` en los endpoints protegidos |
| **Persistencia de sesión** | `shared_preferences` guarda la sesión localmente para restaurarla al abrir la app |
| **Estado global** | `provider` gestiona autenticación y datos de cada módulo |

### Flujo de autenticación

1. El usuario se **registra** (`POST /auth/register`) o **inicia sesión** (`POST /auth/login`).
2. El backend devuelve un token JWT junto con su tipo (`token`, `tokenType`, `expiresIn`).
3. La app consulta el perfil del usuario (`GET /auth/me`) y guarda la sesión localmente.
4. Las operaciones de categorías, metas, actividades, sesiones de entrenamiento y reportes incluyen el encabezado `Authorization`.

> **Nota**: El backend en Render puede tardar unos segundos en responder si estuvo inactivo (arranque en frío). Si la primera petición falla, espera un momento e inténtalo de nuevo.

## URLs del Backend

**URL base de la API:**

```
https://physical-activity-log-api.onrender.com/api/v1
```

### Autenticación

| Método | Endpoint | Autenticación | Descripción |
|--------|----------|---------------|-------------|
| `POST` | `/auth/register` | No | Registro de usuario (`name`, `email`, `password`) |
| `POST` | `/auth/login` | No | Inicio de sesión (`email`, `password`) |
| `GET` | `/auth/me` | Bearer Token | Obtiene el usuario autenticado |

### Categorías

| Método | Endpoint | Autenticación |
|--------|----------|---------------|
| `GET` | `/categories` | Bearer Token |
| `POST` | `/categories` | Bearer Token |
| `PUT` | `/categories/{id}` | Bearer Token |
| `DELETE` | `/categories/{id}` | Bearer Token |

### Metas

| Método | Endpoint | Autenticación |
|--------|----------|---------------|
| `GET` | `/goals` | Bearer Token |
| `POST` | `/goals` | Bearer Token |
| `PUT` | `/goals/{id}` | Bearer Token |
| `DELETE` | `/goals/{id}` | Bearer Token |

### Actividades y sesiones de entrenamiento

| Método | Endpoint | Autenticación |
|--------|----------|---------------|
| `POST` | `/activities` | Bearer Token |
| `GET` | `/training-sessions` | Bearer Token |
| `POST` | `/training-sessions` | Bearer Token |
| `PUT` | `/training-sessions/{id}` | Bearer Token |
| `DELETE` | `/training-sessions/{id}` | Bearer Token |

### Reportes

| Método | Endpoint | Autenticación |
|--------|----------|---------------|
| `GET` | `/reports/summary?from={fecha}&to={fecha}&topActivitiesLimit={n}` | Bearer Token |

Las fechas del reporte deben enviarse en formato UTC con sufijo `Z` (por ejemplo: `2026-01-01T00:00:00.000Z`).

### Ejemplo de prueba con cURL

**Registro de usuario:**

```bash
curl -X POST https://physical-activity-log-api.onrender.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Usuario Prueba","email":"prueba@ejemplo.com","password":"MiPassword123"}'
```

**Inicio de sesión:**

```bash
curl -X POST https://physical-activity-log-api.onrender.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"prueba@ejemplo.com","password":"MiPassword123"}'
```

**Consultar categorías (reemplaza `<TOKEN>` por el token obtenido en el login):**

```bash
curl https://physical-activity-log-api.onrender.com/api/v1/categories \
  -H "Authorization: Bearer <TOKEN>"
```

## Ejecución y Pruebas de la Aplicación

### Requisitos

- Flutter SDK instalado y configurado (`flutter doctor` sin errores críticos)
- Un emulador Android/iOS o un dispositivo físico conectado
- Conexión a internet (la app consume la API en Render)

### Instalación y ejecución

1. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

2. **Verificar el entorno**:
   ```bash
   flutter doctor
   ```

3. **Listar dispositivos disponibles**:
   ```bash
   flutter devices
   ```

4. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

   También puedes ejecutarla desde VS Code con la extensión de Flutter (F5) o seleccionando un dispositivo en la barra inferior.

5. **Compilar APK de release** (opcional):
   ```bash
   flutter build apk --target-platform android-arm64 --release
   ```

### Prueba manual en la app

1. Abre la app; si no hay sesión guardada, verás la pantalla de **inicio de sesión**.
2. Crea una cuenta con **Registrarse** o inicia sesión con credenciales existentes.
3. Navega por las pestañas principales:
   - **Sesiones**: crear, editar y eliminar sesiones de entrenamiento.
   - **Categorías**: administrar categorías de actividades.
   - **Metas**: definir y gestionar metas con fechas de inicio y fin.
   - **Reportes**: consultar resumen de actividad por rango de fechas (7, 30 o 90 días).
   - **Cuenta**: ver datos del usuario y cerrar sesión.
4. Usa **pull-to-refresh** en las listas para recargar datos desde el backend.

### Pruebas automatizadas

```bash
flutter test
```

> Actualmente el proyecto no incluye pruebas unitarias o de widgets. El comando anterior sirve como referencia para cuando se agreguen archivos en el directorio `test/`.

## Notas Adicionales

- El proyecto utiliza el SDK de Dart `^3.10.7` (según `pubspec.yaml`)
- La aplicación está configurada para usar Material Design (`uses-material-design: true`)
- El proyecto está configurado como privado (`publish_to: 'none'`)

---

**Fecha de creación**: Documento creado durante la fase de inicialización del proyecto.
