# Projektarbeit WS-25/36

## Entwicklung einer iPhone-App zur Aufzeichnung von Kamera- und Sensordaten

### Beschreibung

In unserem Forschungsprojekt "Neuronale 3D-Repräsentation für dynamische Szenen mit passiven Multi-Kamera Systemen" (NeRDy) wird zusammen mit der Arbeitsgruppe RobotVision unter Prof. Niklas Zeller zusammen gearbeitet.

Im weiteren Umfeld des Projekts soll im Rahmen dieser Projektarbeit eine iOS-App entwickelt werden, die Kamera- sowie Sensordaten eines Smartphones synchron erfasst und speichert. Dabei werden insbesondere IMU-Daten (Accelerometer, Gyroskop, Magnetometer) sowie GPS-Daten aufgezeichnet, um sie für Anwendungen im Bereich _Simultaneous Localization and Mapping (SLAM)_ sowie _Structure from Motion (SfM)_ nutzbar zu machen. Ziel ist die Erstellung eines zuverlässigen Tools, das mithilfe der vorhandenen Hardware (iPhone und MacBook) konsistente und qualitativ hochwertige Datensätze liefert. So entsteht eine praxisnahe Grundlage für Forschung und Entwicklung im Bereich Computer Vision und Robotik.

Projektmeetings voraussichtlich immer Freitags um 13:30 Uhr in der Westhochschule, etwa zweiwöchiger Rhythmus. Kick-Off am 10.10.2025

### Implementierte Features 

- [x] Aufnahme von Sensordaten (Beschleunigungsdaten des Nutzers, Lage-, Rotations-, Magnetfelddaten usw.)
- [x] Speichern von Sensordaten in einer .csv Datei
- [x] Live video feed 

### Roadmap

- [ ] Video Aufnahme
- [ ] GPS Daten sammeln
- [ ] Synchronität sichern

- Welche Sensoren stehen zur Verfügung?
    - Beschleunigungsmesser 
    - Gyroskop
    - Höhensensor
    - Umgebungsdrucksensor
    - Magnetometer
- Wie komme ich an die Sensordaten eines iPhones?
    - Swift besitzt das Core Motion Framework um bewegungs- und umgebungsbezogene Daten zu messen
    - Core Motion gibt die CMMotionManager() Klasse nutzen um die verschiedenen Sensoren zu starten und auszulesen
    - CMDeviceMotion() gibt Beschleunigungsdaten des Nutzers, Lage-, Rotations- und Magnetfelddaten sowie die Stellung des iPhones
    - Um and die komplett unverarbeiteten Daten zu kommen lassen sich auch alle Sensoren einzeln auslesen
    - Die Timestamps der Daten beziehen sich jedoch auf die vergangene Zeit seit dem letzten boot des iPhones nicht wann die messungen gemacht wurden
- Wie sehen die Daten aus?
    - Beschleunigungsmesser gibt Daten in der form 1.0 : 9.8/ms entlang der x,y,z Achsen des iPhones
    - Gyroskop gibt Daten in der form 1.0 : 9.8/ms um die x,y,z Achsen des iPhones
    - Höhensensor 
        - Änderung der höhe im vergleich zum Start in m
        - Druck, in kilopascals
        - Nur iPhone 12 und höher:
            - Absolute höhe im vergleich zum Meeresspiegel
            - Die geschätzte Unsicherheit des Höhenmessers in Metern, basierend auf einer Standardabweichung
            - Die empfohlene Auflösung für die Höhe in Metern
    - Magnetometer 
- Wie speichere ich Daten ab?
    - Swift bietet die Swift Data und Core Data Frameworks um App Daten zu speichern
    - mit write(to:) lassen sich strings in eine file schreiben
        - Erste Idee Daten als strings in einer .csv Datei speichern
- Wie nehme ich Videos auf?
- Wie komme ich an Sensordaten der Kamera/Gibt es überhaupt Sensordaten?
- Wie Synchron kann die Kamera mit den Messwerten aufnehmen?
- Wie füge ich die gesammelten Daten in Kalibr ein?
