# Projektarbeit WS-25/36

## ## Entwicklung einer iPhone-App zur Aufzeichnung von Kamera- und Sensordaten

### Beschreibung

In unserem Forschungsprojekt "Neuronale 3D-Repräsentation für dynamische Szenen mit passiven Multi-Kamera Systemen" (NeRDy) wird zusammen mit der Arbeitsgruppe RobotVision unter Prof. Niklas Zeller zusammen gearbeitet.

Im weiteren Umfeld des Projekts soll im Rahmen dieser Projektarbeit eine iOS-App entwickelt werden, die Kamera- sowie Sensordaten eines Smartphones synchron erfasst und speichert. Dabei werden insbesondere IMU-Daten (Accelerometer, Gyroskop, Magnetometer) sowie GPS-Daten aufgezeichnet, um sie für Anwendungen im Bereich _Simultaneous Localization and Mapping (SLAM)_ sowie _Structure from Motion (SfM)_ nutzbar zu machen. Ziel ist die Erstellung eines zuverlässigen Tools, das mithilfe der vorhandenen Hardware (iPhone und MacBook) konsistente und qualitativ hochwertige Datensätze liefert. So entsteht eine praxisnahe Grundlage für Forschung und Entwicklung im Bereich Computer Vision und Robotik.

Projektmeetings voraussichtlich immer Freitags um 13:30 Uhr in der Westhochschule, etwa zweiwöchiger Rhythmus. Kick-Off am 10.10.2025

### Roadmap

- Wie komme ich an die Sensordaten eines iPhones?
    - CMMotionManager() Klasse nutzen um verschiedene Bewegungssensoren zu starten 
    - Jeder Sensor lässt sich einzeln starten 
    - CMDeviceMotion() gibt alle IMU Daten verarbeitet um Umwelteinflüsse zu beheben 
- Welche Sensoren stehen zur verfügung?
    - Beschleunigungsmesser 
        - gibt die Rate der Beschleunigung entlang drei Achsen (x,y,z)
        - 1.0 entspricht einer Geschwindigkeit von 9.8 m/s 
    - Gyroskop
        - gibt die Rate der Beschleunigung um drei Achsen (x,y,z)
        - 1.0 entspricht einer Geschwindigkeit von 9.8 m/s
    - Höhensensor
    - Magnetometer
- Wie nehme ich Videos auf?
- Wie komme ich an Sensordaten der Kamera?
- Wie speichere ich Daten ab?
    - mit write(to:) lassen sich strings in eine file schreiben
        - Frage: Wo am besten abspeichern?
    - Erste Idee Daten in einer .csv Datei speichern
- Wie kann ich alles Synchron laufen lassen?
