import serial
import sys

def main():
    # Configuración del puerto serie
    PUERTO = 'COM3'      # Cambia esto al puerto correcto
    BAUD_RATE = 19200     # Ajusta según tu configuración
    TIMEOUT = 1           # Tiempo máximo de espera

    try:
        ser = serial.Serial(PUERTO, BAUD_RATE, timeout=TIMEOUT)
        print(f"Conexión establecida en {PUERTO} a {BAUD_RATE} baudios.")
        print("Escribe un número entre 0 y 255 para enviar, o 'salir' para terminar.\n")

        while True:
            dato_uart = input("Ingresa un número (0-255): ").strip()

            if dato_uart.lower() in ["salir", "exit"]:
                print("Saliendo del programa...")
                break

            if not dato_uart.isdigit():
                print("Error: Debes ingresar un número válido.\n")
                continue

            valor_numerico = int(dato_uart)

            if 0 <= valor_numerico <= 255:
                dato_byte = valor_numerico.to_bytes(1, byteorder='big')

                # Mostrar información
                print(f"Valor numérico: {valor_numerico}")
                print(f"Valor binario (8 bits): {bin(valor_numerico)[2:].zfill(8)}")

                # Enviar por UART
                ser.write(dato_byte)
                print(f"Enviado a la ALU: {dato_byte}\n")
            else:
                print("Error: El número debe estar en el rango 0-255.\n")

    except serial.SerialException as e:
        print(f"Error al abrir el puerto serie: {e}")
        sys.exit(1)

    except KeyboardInterrupt:
        print("\nInterrupción por teclado. Cerrando el programa...")

    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print("Puerto serie cerrado correctamente.")

if __name__ == "__main__":
    main()
