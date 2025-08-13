import asyncio
import websockets
import json
import asyncpg
import os

# Conexión inicial a la base de datos
async def connect_to_db():
    try:
        return await asyncpg.connect(
            user=os.getenv('DB_USER', 'root'),
            password=os.getenv('DB_PASSWORD', '$F3rr0m3x18$'),
            database=os.getenv('DB_NAME', 'tren_seguro'),
            host=os.getenv('DB_HOST', '10.10.32.121')
        )
    except Exception as e:
        print(f"Error connecting to the database: {e}")
        return None

# Función que obtiene los datos de la base de datos
async def fetch_train_data(conn):
    try:
        rows = await conn.fetch('SELECT Pending_Train_ID FROM train_pending')
        return [dict(row) for row in rows]
    except Exception as e:
        print(f"Error fetching train data: {e}")
        return []

# Función que maneja la comunicación WebSocket
async def train_data(websocket, path):
    conn = await connect_to_db()
    if conn is None:
        print("Connection to the database failed, closing WebSocket.")
        await websocket.close()
        return

    while True:
        try:
            trains = await fetch_train_data(conn)
            if trains:
                print(f"Fetched trains: {trains}")  # Depuración
                await websocket.send(json.dumps(trains))
                print(f"Sent trains: {trains}")  # Depuración
            else:
                print("No data to send.")
        except websockets.ConnectionClosed:
            print("WebSocket connection closed")
            break
        except Exception as e:
            print(f"Error sending data: {e}")
        await asyncio.sleep(20)  # Enviar cada 20 segundos

    await conn.close()  # Cerrar conexión al salir del ciclo

# Iniciar servidor WebSocket
start_server = websockets.serve(train_data, "localhost", 8765)

print("Servidor WebSocket iniciado en ws://localhost:8765")

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
