from flask import Flask, jsonify, request
import pymysql

app = Flask(__name__)

def get_con():
    return pymysql.connect(
        host="localhost", user="root", password="0123456",
        database="delgado_abogados", port=3306,
        cursorclass=pymysql.cursors.DictCursor
    )

# ── EXPEDIENTES ────────────────────────────────
@app.route("/api/expedientes", methods=["GET"])
def get_expedientes():
    con = get_con()
    cur = con.cursor()
    cur.execute("SELECT * FROM v_expedientes_completos")
    datos = cur.fetchall()
    con.close()
    return jsonify(datos)

@app.route("/api/expedientes/<int:id>", methods=["GET"])
def get_expediente(id):
    con = get_con()
    cur = con.cursor()
    cur.execute("SELECT * FROM v_expedientes_completos WHERE id = %s", (id,))
    dato = cur.fetchone()
    con.close()
    if dato:
        return jsonify(dato)
    return jsonify({"error": "No encontrado"}), 404

@app.route("/api/expedientes", methods=["POST"])
def crear_expediente():
    b = request.get_json()
    con = get_con()
    cur = con.cursor()
    cur.execute("""
        INSERT INTO expedientes
        (numero_caso, conductor, aseguradora_id, tipo_caso_id, abogado_id, juzgado_id, estado, fecha_inicio, fecha_fin)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """, (b.get("numero_caso"), b.get("conductor"), b.get("aseguradora_id"),
          b.get("tipo_caso_id"), b.get("abogado_id"), b.get("juzgado_id"),
          b.get("estado","Pendiente"), b.get("fecha_inicio"), b.get("fecha_fin")))
    con.commit()
    nuevo_id = cur.lastrowid
    con.close()
    return jsonify({"mensaje": "Expediente creado", "id": nuevo_id}), 201

# ── ASEGURADORAS ───────────────────────────────
@app.route("/api/aseguradoras", methods=["GET"])
def get_aseguradoras():
    con = get_con()
    cur = con.cursor()
    cur.execute("SELECT * FROM aseguradoras")
    datos = cur.fetchall()
    con.close()
    return jsonify(datos)

@app.route("/api/aseguradoras", methods=["POST"])
def crear_aseguradora():
    b = request.get_json()
    con = get_con()
    cur = con.cursor()
    cur.execute("INSERT INTO aseguradoras (nombre) VALUES (%s)", (b.get("nombre"),))
    con.commit()
    con.close()
    return jsonify({"mensaje": "Aseguradora creada"}), 201

# ── ABOGADOS ───────────────────────────────────
@app.route("/api/abogados", methods=["GET"])
def get_abogados():
    con = get_con()
    cur = con.cursor()
    cur.execute("SELECT * FROM abogados")
    datos = cur.fetchall()
    con.close()
    return jsonify(datos)

@app.route("/api/abogados", methods=["POST"])
def crear_abogado():
    b = request.get_json()
    con = get_con()
    cur = con.cursor()
    cur.execute("INSERT INTO abogados (nombre) VALUES (%s)", (b.get("nombre"),))
    con.commit()
    con.close()
    return jsonify({"mensaje": "Abogado creado"}), 201

# ── TIPOS DE CASO ──────────────────────────────
@app.route("/api/tipos_caso", methods=["GET"])
def get_tipos_caso():
    con = get_con()
    cur = con.cursor()
    cur.execute("SELECT * FROM tipos_caso")
    datos = cur.fetchall()
    con.close()
    return jsonify(datos)

# ── DASHBOARD ──────────────────────────────────
@app.route("/api/dashboard", methods=["GET"])
def dashboard():
    con = get_con()
    cur = con.cursor()
    cur.execute("SELECT * FROM v_resumen_estados")
    estados = cur.fetchall()
    cur.execute("SELECT * FROM v_expedientes_por_abogado")
    abogados = cur.fetchall()
    con.close()
    return jsonify({"estados": estados, "por_abogado": abogados})

if __name__ == "__main__":
    app.run(debug=True)
