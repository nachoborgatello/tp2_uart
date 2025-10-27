import serial
import sys
import time

def main():
    # Configuración del puerto serie
    PUERTO = 'COM6'          # Cambia esto según tu sistema (Windows: COMx, Linux: /dev/ttyUSBx o /dev/ttySx)
    BAUD_RATE = 19200        # Velocidad en baudios
    TIMEOUT = 1              # Tiempo máximo de espera (en segundos)

    try:
        # Intentar abrir el puerto serie
        ser = serial.Serial(port=PUERTO, baudrate=BAUD_RATE, timeout=TIMEOUT)
        print(f"\nReceptor UART iniciado en {PUERTO} a {BAUD_RATE} baudios.")
        print("Esperando datos...\n")

        while True:
            dato_recibido = ser.read(1)  # Leer 1 byte

            if dato_recibido:
                valor = int.from_bytes(dato_recibido, byteorder='big')
                
                print(f"Byte recibido: {dato_recibido}")
                print(f"Decimal: {valor}")
                print(f"Binario: {bin(valor)[2:].zfill(8)}")
                print(f"Hexadecimal: {hex(valor)}")
                print("-" * 40)
            else:
                # Si no se reciben datos dentro del timeout
                print("No se recibieron datos en el tiempo de espera.")
                time.sleep(0.5)

    except serial.SerialException as e:
        print(f"Error al abrir o comunicar con el puerto serie: {e}")
        sys.exit(1)

    except KeyboardInterrupt:
        print("\nInterrupción por teclado. Cerrando el puerto...")

    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print("Puerto serie cerrado correctamente.")

if __name__ == "__main__":
    main()
