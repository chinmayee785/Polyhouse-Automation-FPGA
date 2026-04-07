# 🌱 Smart Polyhouse Automation using FPGA

## 📌 Overview
This project focuses on designing a Smart Polyhouse Automation System using FPGA. The system monitors environmental parameters such as temperature, humidity, and soil moisture, and automatically controls actuators like fans and irrigation systems.

The design is implemented using Verilog HDL in Xilinx Vivado.

---

## ⚙️ Technologies & Hardware Used
- Verilog HDL
- Xilinx Vivado
- FPGA Board
- Sensors (Temperature, Humidity, Soil Moisture)
- ADC (Analog to Digital Converter)

---

## 🔍 Key Features
- 🌡️ Temperature monitoring and control
- 💧 Soil moisture-based automatic irrigation
- 🌫️ Humidity-based environmental adjustment
- ⚡ Real-time hardware-level decision making using FPGA
- 🔄 Continuous monitoring and control loop

---

## 🧠 Working Principle
The system takes analog input from sensors (temperature, humidity, soil moisture), which is converted into digital signals using an ADC.

These digital signals are processed by the FPGA using Verilog logic. Based on predefined conditions:
- Fan is activated when temperature exceeds threshold
- Water pump is triggered when soil moisture is low
- Other environmental controls are adjusted accordingly

---

## 📁 Project Structure
- `polyhouse.v` → Verilog source code
- `polyhouse.xdc` → Constraints file for FPGA pin configuration

---

## 🚀 Future Scope
- IoT integration for remote monitoring
- Machine Learning for predictive climate control
- Mobile app-based control system
- Advanced sensor integration

---

## 💡 Learning Outcomes
- Understanding of FPGA-based system design
- Verilog HDL programming
- Sensor interfacing concepts
- Real-world automation system design
