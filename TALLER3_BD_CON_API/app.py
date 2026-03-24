from flask import Flask, jsonify, request
import mysql.connector

app = Flask(__name__)

# CONEXION A LA BASE DE DATOS
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        port=3307,
        user="root",
        password="1234",
        database="sistema_juzgado"
    )

# RUTA PRINCIPAL
@app.route("/")
def home():
    return jsonify({"mensaje": "API funcionando correctamente"})

# ====== READ (GET) =======

@app.route("/expedientes", methods=["GET"])
def obtener_expedientes():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM expedientes")
    data = cursor.fetchall()

    conn.close()
    return jsonify(data)

@app.route("/agenda", methods=["GET"])
def obtener_agenda():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM agenda")
    data = cursor.fetchall()

    conn.close()
    return jsonify(data)

@app.route("/aseguradoras", methods=["GET"])
def obtener_aseguradoras():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM aseguradoras")
    data = cursor.fetchall()

    conn.close()
    return jsonify(data)

# ===== CREATE (POST) =====

@app.route("/expedientes", methods=["POST"])
def crear_expediente():
    datos = request.json

    conn = get_db_connection()
    cursor = conn.cursor()

    sql = """
    INSERT INTO expedientes (id_aseguradora, numero_expediente, descripcion, estado)
    VALUES (%s, %s, %s, %s)
    """

    valores = (
        datos["id_aseguradora"],
        datos["numero_expediente"],
        datos["descripcion"],
        datos["estado"]
    )

    cursor.execute(sql, valores)
    conn.commit()

    conn.close()

    return jsonify({"mensaje": "Expediente creado correctamente"})

# ===== UPDATE (PUT) ======

@app.route("/expedientes/<int:id>", methods=["PUT"])
def actualizar_expediente(id):
    datos = request.json

    conn = get_db_connection()
    cursor = conn.cursor()

    sql = """
    UPDATE expedientes
    SET descripcion=%s, estado=%s
    WHERE id_expediente=%s
    """

    valores = (
        datos["descripcion"],
        datos["estado"],
        id
    )

    cursor.execute(sql, valores)
    conn.commit()

    conn.close()

    return jsonify({"mensaje": "Expediente actualizado correctamente"})

# ===== DELETE ============

@app.route("/expedientes/<int:id>", methods=["DELETE"])
def eliminar_expediente(id):
    conn = get_db_connection()
    cursor = conn.cursor()

    sql = "DELETE FROM expedientes WHERE id_expediente=%s"

    cursor.execute(sql, (id,))
    conn.commit()

    conn.close()

    return jsonify({"mensaje": "Expediente eliminado correctamente"})

# ===== RUN SERVER ========

if __name__ == "__main__":
    app.run(debug=True)