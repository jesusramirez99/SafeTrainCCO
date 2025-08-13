from flask import request
from flask import Flask, jsonify
from flask_cors import CORS
from flask_mysqldb import MySQL

app = Flask(__name__)
CORS(app)

# Asignar valores a las variables para la conexion a la DB
app.config['MYSQL_HOST'] = "10.10.32.121"
app.config['MYSQL_USER'] = "root"
app.config['MYSQL_PASSWORD'] = "$F3rr0m3x18$"
app.config['MYSQL_DB'] = "tren_seguro"

mysql = MySQL(app)

# CONSULTA TRENES PENDIENTES

@app.route('/safe_train_cco/train_pending', methods=['GET'])
def trainPending():
    try:
        trenId = request.args.get('Pending_Train_ID')

        if not trenId:
            return jsonify({'error': 'Missing Pending_Train_ID parameter'}), 400

        consulta = mysql.connection.cursor()
        consulta.execute('SET @row_number = 0;')

        sql = '''
        SELECT 
            (@row_number:=@row_number + 1) AS row_num, 
            tp.*,
            pts.Validated_Train,
            pts.Offered_Train,
            pts.Validated_By,
            pts.Offered_By,
            pts.Validated_Offered_Date,
            pts.Authorized_Train,
            pts.Called_Train,
            pts.Authorized_By,
            pts.Called_By,
            pts.Authorized_Called_Date,
            (SELECT COUNT(*) 
             FROM 
                 train_pending 
             WHERE 
                 Pending_Train_ID = tp.Pending_Train_ID
             AND 
                 LE_Status <> 'O') AS Total_Cars,
            (SELECT COUNT(*) 
             FROM 
                 train_pending 
             WHERE 
                 Pending_Train_ID = tp.Pending_Train_ID 
             AND 
                 (LE_Status = 'E' OR LE_Status = 'W')) AS empty_cars,
            (SELECT COUNT(*) 
             FROM 
                 train_pending 
             WHERE 
                 Pending_Train_ID = tp.Pending_Train_ID 
             AND 
                 (LE_Status = 'L' OR LE_Status = 'LL' OR LE_Status = 'LE')) AS loaded_cars
        FROM 
            train_pending tp
        LEFT JOIN 
            permanent_train_status pts ON tp.Pending_Train_ID = pts.Pending_Train_ID
        WHERE 
            tp.Pending_Train_ID = %s
        ORDER BY 
            tp.Track_Train_Position DESC
        LIMIT 1;
        '''
        consulta.execute(sql, (trenId,))

        train_pending = consulta.fetchall()
        consulta.close()

        clave_train_pending = []
        for registro in train_pending:
            # Convertir las fechas a un formato legible y eliminar "GMT"
            fecha_validado_ofrecido = registro[32].strftime('%a, %d %b %Y\n%H:%M:%S') if registro[32] else ''

            fecha_autorizado_llamado = registro[37].strftime('%a, %d %b %Y\n %H:%M:%S') if registro[37] else ''

            clave_train_pending.append({
                'origen': registro[10] if registro[10] is not None else '',
                'destino': registro[11] if registro[11] is not None else '',
                'tren': registro[2] if registro[2] is not None else '',
                'fecha': registro[23] if registro[23] is not None else '',
                'carros': registro[38] if registro[38] is not None else 0,
                'cargados': registro[40] if registro[40] is not None else 0,
                'vacios': registro[39] if registro[39] is not None else 0,
                'validado': registro[28] if registro[28] is not None else '',
                'ofrecido': registro[29] if registro[29] is not None else '',
                'validado_por': registro[30] if registro[30] is not None else '',
                'ofrecido_por': registro[31] if registro[31] is not None else '',
                'fecha_validado_ofrecido': fecha_validado_ofrecido,
                'autorizado': registro[33] if registro[33] is not None else '',
                'llamado': registro[34] if registro[34] is not None else '',
                'autorizado_por': registro[35] if registro[35] is not None else '',
                'llamado_por': registro[36] if registro[36] is not None else '',
                'fecha_autorizado_llamado': fecha_autorizado_llamado,
            })

        return jsonify({'train_pending': clave_train_pending})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

# CONSULTA PARA VALIDAR SI UN TREN ESTA VALIDADO Y OFRECIDO
@app.route('/safe_train_cco/check_train_validated', methods=['GET'])
def checkTrainValidate():
    try:
        train = request.args.get('Pending_Train_ID')

        if not train:
            return jsonify({'error': 'Missing Pending_Train_ID parameter'}), 400
        
        consulta = mysql.connection.cursor()
        sql = '''
            SELECT Validated_Train, Offered_Train 
            FROM permanent_train_status 
            WHERE Pending_Train_ID = %s
        '''
        consulta.execute(sql, (train,))
        check_train = consulta.fetchone()
        consulta.close()

        if check_train is None:
            # Si no se encontró el tren, significa que no ha sido validado ni ofrecido
            return jsonify({'status': 'not_found', 'message': 'El tren no ha sido validado ni ofrecido.'}), 404
        else:
            validated_train, offered_train = check_train
            if validated_train == 'OK' and offered_train == 'OK':
                return jsonify({'status': 'already_validated', 'message': 'El tren ya está validado y ofrecido.'})
            else:
                return jsonify({'status': 'not_validated', 'message': 'El tren aún no está validado.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


    
    
# CONSULTA PARA VALIDAR SI UN TREN ESTA AUTORIZADO Y LLAMADO
@app.route('/safe_train_cco/check_train_authorized', methods=['GET'])
def checkTrainAuthorized():
    try:
        train = request.args.get('Pending_Train_ID')

        if not train:
            return jsonify({'error': 'Missing Pending_Train_ID parameter'}), 400
        
        consulta = mysql.connection.cursor()
        sql = '''
            SELECT Authorized_Train, Called_Train 
            FROM permanent_train_status 
            WHERE Pending_Train_ID = %s
        '''
        consulta.execute(sql, (train,))

        check_train = consulta.fetchone()
        consulta.close()

        if check_train:
            authorized_train, called_train = check_train
            if authorized_train == 'OK' and called_train == 'OK':
                return jsonify({'status': 'already_authorized', 'message': 'autorizado'})
            else:
                return jsonify({'status': 'not_authorized', 'message': 'El tren aún no está autorizado.'})
        else:
            return jsonify({'error': 'el tren no ha sido validado y ofrecido'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# CONSULTA INFORMACION DEL TREN
@app.route('/safe_train_cco/info_train', methods=['GET'])
def infoTrain():
    try:
        trainPending = request.args.get('Pending_Train_ID')

        if not trainPending:
            return jsonify({'error': 'Missing Pending_Train_ID parameter'}), 400
        # Consulta informacion de tren
        consulta = mysql.connection.cursor()
        sql = 'SELECT * FROM train_pending WHERE Pending_Train_ID = %s ORDER BY Track_Train_Position ASC'
        consulta.execute(sql, (trainPending,))
        #Obtener los resultados de la consulta
        info_train = consulta.fetchall()
        consulta.close()

        #Convertir los resultados en una lista 
        clave_info_train = [{'tren': registro[1] if registro[1] is not None else '',
                     'posicion': registro[5] if registro[5] is not None else 0,
                     'unidad': registro[3] if registro[3] is not None else '',
                     'estatus': registro[4] if registro[4] is not None else '',
                     'tipo_equipo': registro[6] if registro[6] is not None else '',
                     'articulados': registro[16] if registro[16] is not None else 0,
                     'lotearA': registro[17] if registro[17] is not None else '',
                     'producto': registro[18] if registro[18] is not None else '',
                     'peso': registro[14] if registro[14] is not None else 0,
                     'longitud': registro[13] if registro[13] is not None else 0}
                    for registro in info_train]

        # Devolver la lista de claves de info train como respuesta JSON
        return jsonify({'info_train' : clave_info_train})
    except Exception as e:
        return jsonify({'error: ' : str(e)}), 500
    
    
# CONSULTA INDICADORES DEL TREN
@app.route('/safe_train_cco/indicator_train', methods=['GET'])
def indicatorTrain():
    try:
        trainPending = request.args.get('Pending_Train_ID')

        if not trainPending:
            return jsonify({'error': 'Missing Pending_Train_ID parameter'}), 400
        # Consulta informacion de tren
        consulta = mysql.connection.cursor()

        consulta.execute("SET @minTotalCars = 120;")
        consulta.execute("SET @minTotalWeight = 11000;")
        consulta.execute("SET @minTotalLength = 2200;")

        sql = '''
        SELECT
            (@row_number:=@row_number + 1) AS row_num, 
            tp.Pending_Train_Origin_Station AS Terminal,
            tp.Pending_Train_Origin_Station,
            tp.Pending_Train_Destination_Station,
            SUM(CASE WHEN tp.LE_Status = 'L' OR tp.LE_Status = 'LL' OR tp.LE_Status = 'LE' THEN 1 ELSE 0 END) AS Loaded_Cars,
            SUM(CASE WHEN tp.LE_Status = 'E' OR tp.LE_Status = 'W' THEN 1 ELSE 0 END) AS Empty_Cars,

            SUM(CASE WHEN tp.LE_Status <> 'O' THEN 1 ELSE 0 END) AS Total_Cars, 
            @minTotalCars AS Total_Min_Cars,
            (SUM(CASE WHEN tp.LE_Status <> 'O' THEN 1 ELSE 0 END) / @minTotalCars) * 100 AS Percentage_Cars,

            
            SUM(tp.Weight) AS Total_Weight, 
            @minTotalWeight AS Total_Min_Weight,
            (SUM(tp.Weight) / @minTotalWeight) * 100 AS Percentage_Weight,

            SUM(tp.`Length`) AS Total_Length,
            @minTotalLength AS Total_Min_Length,
            (SUM(tp.`Length`) / @minTotalLength) * 100 AS Percentage_Length,

            GROUP_CONCAT(
        CASE 
            WHEN tp.Equipment_Kind = 'D' THEN tp.Track_Train_Position
            ELSE NULL 
        END 
        ORDER BY tp.Track_Train_Position
    ) AS Locomotora_Sequence

        FROM
            train_pending tp
        WHERE 
            tp.Pending_Train_ID = %s
        '''
        consulta.execute(sql, (trainPending,))
        #Obtener los resultados de la consulta
        indicator_train = consulta.fetchall()
        consulta.close()

        #Convertir los resultados en una lista 
        clave_indicator_train = [{'terminal': registro[1] if registro[1] is not None else '',
                     'origen': registro[2] if registro[2] is not None else '',
                     'destino': registro[3] if registro[3] is not None else '',
                     'cargados': registro[4] if registro[4] is not None else 0,
                     'vacios': registro[5] if registro[5] is not None else 0,

                     'totalcarros': registro[6] if registro[6] is not None else 0,
                     'totalcarrosminimo': registro[7] if registro[7] is not None else 0,
                      'porcentajecarros': f"{int(round(registro[8]))} %" if registro[8] is not None else '0 %',

                     'totaltoneladas': registro[9] if registro[9] is not None else 0,
                     'tonelajeminimo': registro[10] if registro[10] is not None else 0,
                     'porcentajetoneladas': f"{int(round(registro[11]))} %" if registro[11] is not None else '0 %',
                     
                     'longitud': registro[12] if registro[12] is not None else 0,
                     'longitudminima': registro[13] if registro[13] is not None else 0,
                     'porcentajelongitud': f"{int(round(registro[14]))} %" if registro[14] is not None else '0 %',

                     'secuencialocomotoras': registro[15] if registro[15] is not None else 0,
                     }
                    for registro in indicator_train]

        # Devolver la lista de claves de info train como respuesta JSON
        return jsonify({'indicator_train' : clave_indicator_train})
    except Exception as e:
        return jsonify({'error: ' : str(e)}), 500
    

# CONSULTA PARA INSERTAR LOS REGISTROS DE AUTORIZACION Y LLAMADO DEL TREN EN LA TABLA permanent_train_status
@app.route('/safe_train_cco/insert_status_authorized_called_train', methods = ['POST'])
def updateStatus():
    try:
        data = request.get_json()
        Authorized_Train = 'OK'
        Called_Train = 'OK'
        Authorized_By = data.get('Authorized_By') 
        Called_By = data.get('Called_By')
        Authorized_Called_Date = data.get('Authorized_Called_Date')

        Pending_Train_ID = data.get('Pending_Train_ID')
        
        if not Pending_Train_ID:
            return jsonify({'Error: ': 'parametro de tren faltante'}), 400
        
        consulta = mysql.connection.cursor()

        sql = '''
        INSERT INTO permanent_train_status (
            Pending_Train_ID, Authorized_Train, Called_Train, Authorized_By, Called_By, Authorized_Called_Date
        ) VALUES (%s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            Authorized_Train = VALUES(Authorized_Train),
            Called_Train = VALUES(Called_Train),
            Authorized_By = VALUES(Authorized_By),
            Called_By = VALUES(Called_By),
            Authorized_Called_Date = VALUES(Authorized_Called_Date);
        '''

        consulta.execute(sql, (Pending_Train_ID, Authorized_Train, Called_Train, Authorized_By, Called_By, Authorized_Called_Date))
        mysql.connection.commit()
        consulta.close()

        return jsonify({'message': 'registro exitoso/actualizacion completa'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    


# CONSULTA PARA MODIFICAR LOS REGISTROS DE AUTORIZACION Y LLAMADO DEL TREN EN LA TABLA permanent_train_status
@app.route('/safe_train_cco/update_status_authorized_called_train', methods=['POST'])
def updateAuthorized():
    try:
        data = request.get_json()
        Authorized_Train = 'OK'
        Called_Train = 'OK'
        Authorized_By = data.get('Authorized_By')
        Called_By = data.get('Called_By')
        Authorized_Called_Date = data.get('Authorized_Called_Date')

        Pending_Train_ID = data.get('Pending_Train_ID')
        
        if not Pending_Train_ID:
            return jsonify({'Error': 'parametro de tren faltante'}), 400
        
        consulta = mysql.connection.cursor()

        sql = '''
        UPDATE permanent_train_status
        SET
            Authorized_Train = %s,
            Called_Train = %s,
            Authorized_By = %s,
            Called_By = %s,
            Authorized_Called_Date = %s
        WHERE
            Pending_Train_ID = %s;
        '''

        consulta.execute(sql, (Authorized_Train, Called_Train, Authorized_By, Called_By, Authorized_Called_Date, Pending_Train_ID))
        mysql.connection.commit()
        consulta.close()

        return jsonify({'message': 'actualización completa'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

    

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5002)