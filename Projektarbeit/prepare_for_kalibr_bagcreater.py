#!/usr/bin/env python3
"""
prepare_for_kalibr_bagcreater.py
Bereitet iPhone Daten für Kalibr bagcreater vor

Kalibr bagcreater erwartet:
  data/
    cam0/
      1234567890123456789.png  ← Timestamp in filename!
      1234567890456789012.png
    imu0.csv  ← Optional

Usage:
    python3 prepare_for_kalibr_bagcreater.py <recording_folder> <output_folder>
    
Example:
    python3 prepare_for_kalibr_bagcreater.py 2024-12-18_10-30-45 kalibr_data
"""

import pandas as pd
import shutil
from pathlib import Path
import sys

def prepare_for_kalibr(recording_dir, output_dir):
    """Bereitet Daten für kalibr_bagcreater vor"""
    
    rec_path = Path(recording_dir)
    out_path = Path(output_dir)
    
    # Create output structure
    cam0_path = out_path / "cam0"
    cam0_path.mkdir(parents=True, exist_ok=True)
    
    print(f"Preparing data from {recording_dir} for Kalibr bagcreater...")
    
    # 1. Process frames
    frames_dir = rec_path / "frames"
    timestamps_file = rec_path / "frame_timestamps.csv"
    
    if not frames_dir.exists():
        print(f"ERROR: {frames_dir} not found!")
        print("Run: ffmpeg -i recording.mov -vf \"select='not(mod(n\\,3))'\" -vsync 0 frames/frame_%06d.png")
        return False
    
    if not timestamps_file.exists():
        print(f"ERROR: {timestamps_file} not found!")
        return False
    
    print("\n1. Processing frames...")
    df = pd.read_csv(timestamps_file)
    frames = sorted(frames_dir.glob("frame_*.png"))
    
    print(f"   Found {len(frames)} frames")
    print(f"   Found {len(df)} timestamps")
    
    if len(frames) != len(df):
        print(f"   ⚠️  WARNING: Count mismatch!")
    
    # Copy and rename frames
    for idx, (frame_file, (_, row)) in enumerate(zip(frames, df.iterrows())):
        # Convert to nanoseconds
        timestamp_nsec = int(row['timestamp'] * 1e9)
        
        # New filename with timestamp
        new_name = f"{timestamp_nsec}.png"
        new_path = cam0_path / new_name
        
        shutil.copy2(frame_file, new_path)
        
        if idx % 50 == 0:
            print(f"   Copying: {idx}/{len(frames)}", end='\r')
    
    print(f"\n   ✅ Copied {len(frames)} frames to cam0/")
    
    # 2. Process IMU (optional)
    imu_file = rec_path / "IMU-measurements.csv"
    
    if imu_file.exists():
        print("\n2. Processing IMU...")
        imu_df = pd.read_csv(imu_file)
        
        # Convert to Kalibr format with nanosecond timestamps
        kalibr_imu = pd.DataFrame({
            'timestamp': (imu_df['timestamp'] * 1e9).astype(int),
            'omega_x': imu_df['gyro_x'],
            'omega_y': imu_df['gyro_y'],
            'omega_z': imu_df['gyro_z'],
            'alpha_x': imu_df['accel_x'],
            'alpha_y': imu_df['accel_y'],
            'alpha_z': imu_df['accel_z']
        })
        
        # Save without header
        imu_output = out_path / "imu0.csv"
        kalibr_imu.to_csv(imu_output, index=False, header=False)
        
        print(f"   ✅ Created imu0.csv with {len(kalibr_imu)} samples")
    else:
        print("\n2. No IMU file found (skipping)")
    
    # 3. Summary
    print("\n" + "="*50)
    print("✅ Ready for kalibr_bagcreater!")
    print("="*50)
    print(f"\nOutput structure:")
    print(f"  {output_dir}/")
    print(f"    cam0/")
    print(f"      {sorted(cam0_path.glob('*.png'))[0].name}")
    print(f"      ...")
    if imu_file.exists():
        print(f"    imu0.csv")
    
    print(f"\nNext steps:")
    print(f"1. In Docker container:")
    if imu_file.exists():
        print(f"   kalibr_bagcreater --folder /data/{output_dir} --output-bag /data/calibration.bag --imu /data/{output_dir}/imu0.csv")
    else:
        print(f"   kalibr_bagcreater --folder /data/{output_dir} --output-bag /data/calibration.bag")
    
    print(f"\n2. Verify:")
    print(f"   rosbag info /data/calibration.bag")
    
    return True

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 prepare_for_kalibr_bagcreater.py <recording_folder> <output_folder>")
        print("\nExample:")
        print("  python3 prepare_for_kalibr_bagcreater.py 2024-12-18_10-30-45 kalibr_data")
        sys.exit(1)
    
    recording_dir = sys.argv[1]
    output_dir = sys.argv[2]
    
    success = prepare_for_kalibr(recording_dir, output_dir)
    sys.exit(0 if success else 1)
