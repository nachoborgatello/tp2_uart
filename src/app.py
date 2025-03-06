import tkinter as tk
from tkinter import ttk, messagebox
import serial
import time

# Configurar el puerto serie (ajusta el nombre del puerto según tu sistema)
SERIAL_PORT = "COM3"
BAUD_RATE = 9600

def connect_serial():
    """Intenta abrir la conexión serial."""
    try:
        return serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    except serial.SerialException:
        messagebox.showerror("Error", "No se pudo abrir el puerto serie. Verifica la conexión.")
        return None

ser = connect_serial()

# Diccionario de operaciones con sus códigos binarios
operations = {
    "ADD": "100000",
    "SUB": "100010",
    "AND": "100100",
    "OR": "100101",
    "XOR": "100110",
    "SRA": "000011",
    "SRL": "000010",
    "NOR": "100111"
}

def send_data():
    """Envía datos al puerto serie."""
    if ser is None or not ser.is_open:
        result_label.config(text="Error: No hay conexión con el puerto serie")
        return
    
    data_type = data_type_combobox.get()
    
    if data_type == "Número (0-255)":
        try:
            decimal_number = int(decimal_entry.get().strip())
            if not (0 <= decimal_number <= 255):
                result_label.config(text="Número fuera de rango. Usa un número entre 0 y 255.")
                return
            # Convertir el número decimal a binario de 8 bits
            data_to_send = f"{decimal_number:08b}\n"
        except ValueError:
            result_label.config(text="Número inválido. Usa un valor entre 0 y 255.")
            return
    else:
        operation = operation_combobox.get()
        if operation not in operations:
            result_label.config(text="Selecciona una operación válida.")
            return
        data_to_send = f"{operations[operation]}\n"
    
    try:
        ser.write(data_to_send.encode())
        time.sleep(0.1)
        received_data = ser.readline().decode().strip()
        result_label.config(text=f"Resultado: {received_data}")
    except serial.SerialException:
        result_label.config(text="Error al enviar datos")

def toggle_inputs(event):
    """Habilita o deshabilita los campos según el tipo de dato seleccionado."""
    if data_type_combobox.get() == "Número (0-255)":
        decimal_entry.config(state="normal")
        operation_combobox.config(state="disabled")
    else:
        decimal_entry.config(state="disabled")
        operation_combobox.config(state="normal")

# Configuración de la interfaz gráfica
root = tk.Tk()
root.title("Interfaz Serie")
root.geometry("500x400")
root.config(bg="#f4f4f9")  # Color de fondo para toda la ventana

# Crear un frame con un fondo bonito
frame = ttk.Frame(root, padding=20)
frame.pack(fill="both", expand=True)

# Etiquetas y campos con bordes redondeados y colores agradables
ttk.Label(frame, text="Selecciona el tipo de dato a enviar:", font=("Arial", 10, "bold"), background="#f4f4f9").grid(row=0, column=0, sticky="w", padx=5, pady=10)
data_type_combobox = ttk.Combobox(frame, values=["Número (0-255)", "Op-code"], state="readonly", font=("Arial", 10))
data_type_combobox.grid(row=0, column=1, padx=5, pady=10)
data_type_combobox.set("Número (0-255)")
data_type_combobox.bind("<<ComboboxSelected>>", toggle_inputs)

ttk.Label(frame, text="Número (0-255):", font=("Arial", 10), background="#f4f4f9").grid(row=1, column=0, sticky="w", padx=5, pady=10)
decimal_entry = ttk.Entry(frame, font=("Arial", 10), width=15, justify="center")
decimal_entry.grid(row=1, column=1, padx=5, pady=10)

ttk.Label(frame, text="Operación:", font=("Arial", 10), background="#f4f4f9").grid(row=2, column=0, sticky="w", padx=5, pady=10)
operation_combobox = ttk.Combobox(frame, values=list(operations.keys()), state="readonly", font=("Arial", 10))
operation_combobox.grid(row=2, column=1, padx=5, pady=10)
operation_combobox.set("ADD")
operation_combobox.config(state="disabled")

# Botón con estilo moderno
ttk.Button(frame, text="Enviar", command=send_data, style="TButton").grid(row=3, column=0, columnspan=2, pady=20)

# Etiqueta de resultado con estilo personalizado
result_label = ttk.Label(frame, text="Resultado: ", font=("Arial", 10, "bold"), background="#f4f4f9")
result_label.grid(row=4, column=0, columnspan=2)

# Estilos personalizados
style = ttk.Style()
style.configure("TButton",
                font=("Arial", 12, "bold"),
                padding=10,
                relief="flat",
                background="#4CAF50",
                foreground="white")
style.map("TButton", background=[('active', '#45a049')])

# Iniciar la interfaz
root.mainloop()

if ser:
    ser.close()
