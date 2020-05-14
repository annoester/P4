# P4
Demo_files_all.mat contains ECG and SCG signals from eight subjects. 

Datasimulator.m is a MATLAB file used to simulate the ECG and SCG sensor by transferring the demo file data to the ESP32 of the peripheral unit via UART. 

PeripheralUnit.zip is uploaded to the ESP32 of the peripheral unit, and contains the AC-detection algorithm and the BLE server. 

Central_unit_ESP32.ino is uploaded on the ESP of the central unit, and contains the BLE client and transferral of the data to the GUI via UART. 

GUI.mlapp is a MATLAB app which receives the data from the ESP32 of the central unit, visualizes the signals and calculates the CRF. 


SPI_ADXL355.ino is used for testing the SPI communication between ADXL355 and ESP32, and is not included in the implemented system. 


Data_Record_HRM.ino is used for testing the AD8232 Heart Rate Monitor, and is not included in the implemented system. 
