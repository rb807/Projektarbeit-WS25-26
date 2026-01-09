# KALIBR

## Kalibrierung der Aufnahme überprüfen

Um die Kalibrierung der IMU-Sensoren und der Kamera Aufnahme zu überprüfen wird die Kalibr visual-inertial calibration toolbox (<https://github.com/ethz-asl/kalibr>) genutzt. Für die Installation von Kalibr bitte im derene Wiki nachlesen aber am besten den Docker container nutzen.

Nach der Installation, mit ffmpeg die Frames aus dem Video extrahieren.

Usage:

```bash
ffmpeg -i <source> -r <framerate> <output>
```

Example:

```bash
cd /path/to/recording
mkdir frames
ffmpeg -i recording.mov -r 30 frames/frame%d.png
```

Kalibr benötigt die Daten der Aufnahme in einem ROS bag. Kalibr stellt dafür ein `bagcreater` skript bereit.

Kalibr bagcreater erwartet:

```bash
data/
  cam0/
    1234567890123456789.png  ← Timestamp in filename
    1234567890456789012.png
    ...
  imu0.csv  ← Optional
```

IMU-Measurements.csv ist in
Die imu0.csv ist in omega_(x,y,z) (gyroskop daten) und alpha_(x,y,z) (Accelorometer daten) unterteilt. Um die Frames richtig zu bennenen und die imu daten zu überarbeiten `prepare_for_kalibr_bagcreater.py` nutzen.

Usage:

```bash
python3 prepare_for_kalibr_bagcreater.py <recording_folder> <output_folder>
```

Example:

```bash
python3 prepare_for_kalibr_bagcreater.py 2024-12-18_10-30-45 kalibr_data
```

Nach dem überarbeiten der Daten im Docker Container:
