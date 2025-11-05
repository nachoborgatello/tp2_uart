import serial
import threading
import sys
import time

PUERTO = 'COM10'       # Cambia según tu sistema
BAUD_RATE = 19200
TIMEOUT = 1

def receptor(ser):
    """Hilo que lee continuamente los bytes recibidos"""
    print("📡 Receptor UART iniciado (escuchando datos)...\n")
    while True:
        try:
            dato = ser.read(1)
            if dato:
                valor = int.from_bytes(dato, byteorder='big')
                print(f"\n📥 Recibido -> Decimal: {valor:3d} | Binario: {bin(valor)[2:].zfill(8)} | Hex: {hex(valor)}")
                print("👉 ", end="", flush=True)  # mantener el prompt visible
        except serial.SerialException:
            print("❌ Error en la lectura del puerto serie.")
            break
        except Exception as e:
            print(f"⚠️ Error inesperado: {e}")
            break

def transmisor(ser):
    """Loop principal para enviar datos manualmente"""
    print("🟢 Transmisor listo. Escribe un número entre 0–255, o 'salir' para terminar.\n")
    while True:
        try:
            dato_uart = input("👉 ").strip()
            if dato_uart.lower() in ["salir", "exit"]:
                print("Cerrando comunicación...")
                break

            if not dato_uart.isdigit():
                print("⚠️ Debes ingresar un número válido.\n")
                continue

            valor = int(dato_uart)
            if 0 <= valor <= 255:
                ser.write(valor.to_bytes(1, byteorder='big'))
                print(f"📤 Enviado -> Decimal: {valor:3d} | Binario: {bin(valor)[2:].zfill(8)} | Hex: {hex(valor)}")
            else:
                print("⚠️ El número debe estar entre 0 y 255.\n")

        except KeyboardInterrupt:
            print("\nInterrupción por teclado. Cerrando...")
            break
        except serial.SerialException as e:
            print(f"❌ Error en transmisión: {e}")
            break


def main():
    try:
        ser = serial.Serial(port=PUERTO, baudrate=BAUD_RATE, timeout=TIMEOUT)
        print(f"✅ Conectado a {PUERTO} a {BAUD_RATE} baudios.\n")

        # Iniciar hilo receptor
        hilo_rx = threading.Thread(target=receptor, args=(ser,), daemon=True)
        hilo_rx.start()

        # Iniciar transmisor (en el hilo principal)
        transmisor(ser)

    except serial.SerialException as e:
        print(f"❌ Error al abrir el puerto serie: {e}")
        sys.exit(1)
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print("🔒 Puerto serie cerrado correctamente.")


if __name__ == "__main__":
    main()
