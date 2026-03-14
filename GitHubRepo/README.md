# 🪐 Efemérides Planetarias — VSOP87B

App iOS de alta precisión para calcular posiciones planetarias.
Motor VSOP87B + correcciones de nutación, aberración y tiempo de luz.

---

## ⚡ Pasos para obtener tu .ipa (sin Mac)

### Paso 1 — Crear cuenta en GitHub
Ve a **github.com** y crea una cuenta gratis si no tienes.

### Paso 2 — Crear el repositorio
1. Pulsa el botón verde **"New"** (o ve a github.com/new)
2. Nombre del repo: `efemerides-planetarias`
3. Déjalo en **Public** (necesario para runners gratis)
4. Pulsa **"Create repository"**

### Paso 3 — Subir estos archivos
Tienes dos opciones:

**Opción A — Desde el navegador (más fácil):**
1. En tu repo recién creado, pulsa **"uploading an existing file"**
2. Arrastra TODA la carpeta descomprimida del zip
3. Escribe un mensaje de commit: `Initial commit`
4. Pulsa **"Commit changes"**

**Opción B — Con Git en tu PC:**
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/efemerides-planetarias.git
git push -u origin main
```

### Paso 4 — Ver el build automático
1. Ve a tu repo → pestaña **"Actions"**
2. Verás el workflow **"Build Unsigned IPA"** ejecutándose (tarda ~5-10 min)
3. Espera a que el círculo se ponga ✅ verde

### Paso 5 — Descargar el .ipa
1. Pulsa sobre el workflow completado
2. Baja hasta la sección **"Artifacts"**
3. Pulsa **"PlanetaryApp-unsigned-IPA"** para descargar el .zip
4. Descomprímelo → tienes tu `PlanetaryApp_unsigned.ipa`

---

## 📱 Cómo instalar el .ipa en tu iPhone (sin Mac)

### Opción A — AltStore (recomendado, gratis)
1. Instala **AltServer** en tu PC Windows: altstore.io
2. Conecta tu iPhone por USB
3. En AltServer → "Install AltStore" en tu iPhone
4. Una vez AltStore instalado, abre AltStore en el iPhone
5. Ve a **My Apps** → **+** → selecciona el `.ipa`

### Opción B — Sideloadly (Windows/Mac)
1. Descarga Sideloadly en sideloadly.io
2. Arrastra el `.ipa` a Sideloadly
3. Escribe tu Apple ID (gratis)
4. Pulsa "Start"

### Opción C — TrollStore (sin PC, si tu iOS es compatible)
- Compatible: iOS 14.0 – 16.6.1 y algunos iOS 17.x
- Ve a github.com/opa334/TrollStore para instrucciones

---

## 🔄 Cada vez que quieras recompilar
Basta con ir a **Actions → "Build Unsigned IPA" → "Run workflow"** → pulsar el botón verde.

---

## 📊 Funcionalidades

| Pestaña | Descripción |
|---------|-------------|
| ☉ Posiciones | Longitudes planetarias para cualquier fecha/hora con precisión de 6 decimales |
| → Recorrido | Grados recorridos entre dos fechas (directo + retrógrado separados) |
| ∠ Ángulos | Todos los pares planetarios (28 combinaciones) con aspectos astrológicos |
| 🔍 Búsqueda | Encuentra cuándo un planeta estará en un grado exacto (±hh:mm) |

## 🎯 Precisión

| Planeta | Error típico |
|---------|-------------|
| Sol, Mercurio, Venus, Marte | < 1" (segundo de arco) |
| Júpiter, Saturno | < 3" |
| Urano, Neptuno | < 5" |

Fuente: VSOP87B (Bretagnon & Francou 1987) + Meeus "Astronomical Algorithms"
