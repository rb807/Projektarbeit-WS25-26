# Projektarbeit WS-25/36

## Entwicklung einer iPhone-App zur Aufzeichnung von Kamera- und Sensordaten

### Beschreibung

Im Rahmen dieser Projektarbeit soll eine iOS-App entwickelt werden, die Kamera- sowie 
Sensordaten eines Smartphones synchron
erfasst und speichert. Dabei werden insbesondere IMU-Daten (Accelerometer,
Gyroskop, Magnetometer) sowie GPS-Daten aufgezeichnet, um sie für Anwendungen im
Bereich _Simultaneous Localization and Mapping (SLAM)_ sowie _Structure from
Motion (SfM)_ nutzbar zu machen. Ziel ist die Erstellung eines zuverlässigen
Tools, das mithilfe der vorhandenen Hardware (iPhone und MacBook) konsistente
und qualitativ hochwertige Datensätze liefert. So entsteht eine praxisnahe
Grundlage für Forschung und Entwicklung im Bereich Computer Vision und Robotik.

### Implementierte Features

- [x] Auslesen der Sensordaten (Beschleunigungs-, Lage-,
  Rotations-, Magnetfelddaten usw.)
- [x] Speichern von Sensordaten
- [x] Live video feed
- [X] Video Aufnahme
- [X] Gleichzeitiges aufnehemen von Sensordaten und Video
- [X] Standort Daten auslesen
- [X] Speichern von Standort Daten
- [X] Speichern von Daten während der Aufnahme
- [X] Gleichzeitiges aufnehemen von Sensor- und Standort Daten und Video

### Roadmap

- [ ] Ansicht aller Aufnahmen innerhalb der App
- [ ] Exportieren der Files vom internen App File System in das File System des iPhones
- [ ] Synchronität der Aufnahmen überprüfen mit kalibr
- [ ] Zeitanzeige für die Aufnahme

--- 

## Installation

1. **Projekt in Xcode öffnen**  
   Öffne die Projektdatei (`.xcodeproj` oder `.xcworkspace`) in **Xcode**.

2. **iPhone per Kabel verbinden**  
   Schließe dein iPhone **über ein USB-Kabel** an den Mac an.

3. **Entwicklermodus aktivieren**  
   Aktiviere auf dem iPhone den Entwicklermodus unter  
   `Einstellungen > Datenschutz & Sicherheit > Entwicklermodus`.

4. **iPhone als Run Destination einrichten**  
   In Xcode:  
   `Product > Destination > Manage Run Destinations…`  
   → Klicke unten rechts auf das **Plus-Symbol (+)**, wähle dein Gerät aus und
   folge den angezeigten Anweisungen.

5. **App starten und installieren**  
   Wähle in der oberen Leiste von Xcode dein Gerät als **Run Destination** aus.  
   Starte das Projekt mit `⌘ + R`.  
   Die App wird automatisch auf dem angeschlossenen iPhone installiert und
   ausgeführt.

---

## Fehlerbehebung und Tipps

### Entwicklermodus wird auf dem iPhone nicht angezeigt

Das iPhone muss mindestens **einmal per Kabel** mit einem Mac verbunden werden,  
auf dem **Xcode installiert** ist.  
Erst danach erscheint die Option _Entwicklermodus_ unter  
`Einstellungen > Datenschutz & Sicherheit`.

### iPhone wird in Xcode nicht als Gerät erkannt

- Stelle sicher, dass das iPhone **angeschlossen und entsperrt** ist.  
- Sollte das Gerät trotzdem nicht erscheinen, überprüfe, ob  
  unter `Einstellungen > Allgemein > Übertragungen oder Zurücksetzen > Vertrauen
  diesem Computer`  
  dem Mac vertraut wurde.

### Kabelloses Debugging (optional)

Nachdem das iPhone **einmal erfolgreich per Kabel** eingerichtet wurde,  
kann die Verbindung zukünftig auch **drahtlos über WLAN** erfolgen, wenn:

- Mac und iPhone sich im **selben WLAN-Netzwerk** befinden,  
- auf dem Mac in den **Systemeinstellungen > Netzwerk > Firewall > Optionen…**  
  **eingehende Verbindungen für Xcode erlaubt** sind,  
- und der **Entwicklermodus** auf dem iPhone aktiviert bleibt.
