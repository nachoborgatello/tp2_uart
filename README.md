# UART - Trabajo Práctico 2
---

## 📘 Descripción

Este proyecto implementa un **UART (Universal Asynchronous Receiver and Transmitter)** utilizando **Máquinas de Estado Finitas (FSM)** en **Verilog**.
El sistema permite la **comunicación serie** entre una placa FPGA y una PC, integrando además una **ALU** para procesar los datos recibidos.

---

## ⚙️ Componentes Principales

### 1. **Baud Rate Generator**

Genera la señal de temporización que define la velocidad de transmisión (por defecto: **19200 baudios**).
Implementado mediante un divisor de frecuencia basado en un contador.

### 2. **UART RX (Receptor)**

Recibe datos en serie detectando el bit de inicio, los bits de datos y el bit de parada.
Utiliza una FSM para capturar los bits de manera sincronizada.

### 3. **FIFO**

Memoria intermedia **First In, First Out**, utilizada para almacenar los datos recibidos antes de ser procesados o transmitidos.

### 4. **Módulo Antirrebotes (Debounce)**

Filtra las señales provenientes de pulsadores mecánicos, evitando falsos disparos durante la transmisión.

### 5. **ALU**

Unidad aritmético-lógica capaz de realizar operaciones básicas como **suma, resta, AND, OR, XOR, NOR, SRL, SRA**, etc.
Los resultados se muestran en los LEDs de la placa.

### 6. **UART TX (Transmisor)**

Envía los datos procesados por la ALU hacia la PC, respetando el formato estándar del protocolo UART.

---

## 💻 Comunicación con la PC

Se utilizó un **conversor USB-UART** para enlazar la FPGA con la computadora.
La comunicación se realiza mediante dos scripts en **Python**, usando la librería `pyserial`.

### Transmisor (`uart_tx.py`)

Envía un número (0–255) al UART de la FPGA.

```python
import serial

ser = serial.Serial('COM6', 19200, timeout=1)
print("Conexión establecida. Ingresa un número entre 0 y 255 o 'salir' para terminar.")

while True:
    dato = input("Número: ")
    if dato.lower() in ['salir', 'exit']:
        break
    if dato.isdigit() and 0 <= int(dato) <= 255:
        ser.write(int(dato).to_bytes(1, 'big'))
        print(f"Enviado: {dato}")
    else:
        print("Valor inválido.")
ser.close()
```

### Receptor (`uart_rx.py`)

Recibe bytes desde la FPGA y muestra su valor en distintos formatos.

```python
import serial

ser = serial.Serial('COM6', 19200, timeout=1)
print("Receptor UART iniciado. Esperando datos...")

while True:
    data = ser.read(1)
    if data:
        val = int.from_bytes(data, 'big')
        print(f"Decimal: {val} | Binario: {bin(val)} | Hex: {hex(val)}")
ser.close()
```

---

## 🧩 Integración

El sistema completo combina todos los módulos:

* Los datos enviados desde la PC se almacenan y procesan por la **ALU**.
* El resultado se muestra en los **LEDs de la placa**.
* También puede reenviarse el resultado a la PC mediante el **UART TX**.

---

## 🔌 Pines Principales (ejemplo en FPGA Basys 3)

| Señal     | Pin | Descripción       |
| :-------- | :-: | :---------------- |
| `clk`     |  W5 | Reloj del sistema |
| `rx`      | A14 | Entrada UART RX   |
| `tx`      | B15 | Salida UART TX    |
| `reset`   | U18 | Botón de reinicio |
| `rd_uart` | T18 | Lectura UART      |
| `wr_uart` | U17 | Escritura UART    |

---

## 📂 Estructura del Proyecto

```
├── src/
│   ├── baud_rate.v
│   ├── uart_rx.v
│   ├── uart_tx.v
│   ├── fifo.v
│   ├── debounce.v
│   ├── alu.v
│   └── top.v
├── python/
│   ├── uart_tx.py
│   └── uart_rx.py
├── constraints/
│   └── basys3.xdc
├── README.md
└── informe tp2-UART.pdf
```
