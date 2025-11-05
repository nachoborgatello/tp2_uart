import serial
import threading
import sys
import time

PUERTO = 'COM5'
BAUD_RATE = 19200
TIMEOUT = 3.0

def receptor(ser: serial.Serial):
    """Hilo receptor: escucha continuamente los bytes que llegan por UART."""
    print("[INFO] Receptor UART iniciado. Escuchando datos...\n")
    while ser.is_open:
        try:
            dato = ser.read(1)
            if dato:
                valor = int.from_bytes(dato, byteorder='big')
                print(f"\n[RECIBIDO] Decimal: {valor:3d} | Binario: {bin(valor)[2:].zfill(8)} | Hex: {hex(valor)}")
                print(">>> ", end="", flush=True)
        except serial.SerialException:
            print("[ERROR] Fallo en la lectura del puerto serie.")
            break
        except Exception as e:
            print(f"[ERROR] Excepción inesperada en receptor: {e}")
            break


def transmisor(ser: serial.Serial):
    """Loop principal del transmisor: permite enviar datos manualmente desde consola."""
    print("[INFO] Transmisor listo. Escriba un número entre 0–255 o 'salir' para terminar.\n")

    while True:
        try:
            entrada = input(">>> ").strip()

            if entrada.lower() in ("salir", "exit", "q"):
                print("[INFO] Finalizando comunicación...")
                break

            if not entrada.isdigit():
                print("[WARN] Ingrese un número válido entre 0 y 255.\n")
                continue

            valor = int(entrada)
            if not 0 <= valor <= 255:
                print("[WARN] El valor debe estar entre 0 y 255.\n")
                continue

            ser.write(valor.to_bytes(1, byteorder='big'))
            print(f"[ENVIADO] Decimal: {valor:3d} | Binario: {bin(valor)[2:].zfill(8)} | Hex: {hex(valor)}")

        except KeyboardInterrupt:
            print("\n[INFO] Interrupción por teclado. Cerrando comunicación...")
            break
        except serial.SerialException as e:
            print(f"[ERROR] Fallo en transmisión: {e}")
            break
        except Exception as e:
            print(f"[ERROR] Excepción no controlada en transmisor: {e}")
            break


def main():
    try:
        with serial.Serial(port=PUERTO, baudrate=BAUD_RATE, timeout=TIMEOUT) as ser:
            print(f"[OK] Conectado a {PUERTO} @ {BAUD_RATE} baudios.\n")

            # Lanzar hilo receptor en modo demonio
            hilo_rx = threading.Thread(target=receptor, args=(ser,), daemon=True)
            hilo_rx.start()

            # Ejecutar transmisor en hilo principal
            transmisor(ser)

    except serial.SerialException as e:
        print(f"[ERROR] No se pudo abrir el puerto serie ({PUERTO}): {e}")
        sys.exit(1)
    except Exception as e:
        print(f"[ERROR] Excepción general: {e}")
        sys.exit(1)
    finally:
        print("[INFO] Comunicación finalizada. Cerrando puerto serie...")
        time.sleep(0.5)
        print("[OK] Puerto serie cerrado correctamente.")

if __name__ == "__main__":
    main()
