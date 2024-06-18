<html>

<head>
    <script src="WebJS.js"></script>
    <link rel="stylesheet" type="text/css" href="DesignModificacion.css">

</head>

<body>
    <form action="ModificarInformacion.php" method="POST" enctype="multipart/form-data">
        Nombre:
        <input type="text" name="nombre" placeholder="Introduzca su nombre">

        Edad:
        <input type="number" name="edad" min="1" max="100" placeholder="Introduzca su edad">

        Sexo:
        <select name="sexo">
            <option value="" selected="selected"></option>
            <option value="M">M</option>
            <option value="F">F</option>

        </select>


        Ocupacion:
        <select name="ocupacion">

            <option value="administrator">administrator </option>
            <option value="" selected="selected"></option>
            <option value="artist"> artist</option>
            <<option value="doctor"> doctor</option>
                <option value="educator"> educator</option>
                <option value="engineer"> engineer</option>
                <option value="entertainment">entertainment </option>
                <option value="executive">executive </option>
                <option value="healthcare">healthcare </option>
                <option value="homemaker"> homemaker</option>
                <option value="lawyer">lawyer</option>
                <option value="librarian">librarian </option>
                <option value="marketing"> marketing</option>> </option>
                <option value="none"> none</option>
                <option value="other">other </option>
                <option value="programmer">programmer </option>
                <option value="retired"> retired</option>
                <option value="salesman"> salesman</option>
                <option value="scientist"> scientist</option>
                <option value="student"> student</option>
                <option value="technician">technician </option>
                <option value="writer">writer </option>
        </select>

        Clave
        <input type="password" name="clave" placeholder="Introduzca su contraseña">
        <br>

        Elija su foto de perfil:
        <input type="file" id="foto" name="foto" accept="image/*">

        <input type="submit" name="Registrar" value="Actualizar">

    </form>
    <a href="Usuario.php"><input type="submit" value="Perfil"></a>



    <?php
    session_start();
    $user_id = $_SESSION['id'];


    try {
        $pdo = new PDO("mysql:host=localhost;dbname=ai0", 'ai0', 'ai2024');
    } catch (PDOException $e) {
        die("Error al conectar a la base de datos: " . $e->getMessage());
    }



    try {

        $nombre = isset($_POST['nombre']) ? $_POST['nombre'] : null;
        $edad = isset($_POST['edad']) ? $_POST['edad'] : null;
        $sexo = isset($_POST['sexo']) ? $_POST['sexo'] : null;
        $ocupacion = isset($_POST['ocupacion']) ? $_POST['ocupacion'] : null;
        $foto = isset($_FILES['foto']) ? $_FILES['foto'] : null;
        $claveString = isset($_POST['clave']) ? $_POST['clave'] : null;
        $clave = sha1($claveString);
      


        if (isset( $nombre) &  $nombre != null) {

            $query = "SELECT COUNT(*) FROM users WHERE name = :nombre";
            $statement = $pdo->prepare($query);
            $statement->bindParam(':nombre', $nombre);
            $statement->execute();
            $count = $statement->fetchColumn();
          
            if ($count > 0) {
              echo "<script> registroYaExiste()</script>";
              exit;
            }else{
            $query = "UPDATE users SET   name='$nombre' where id=$user_id";
            $statement = $pdo->query($query);
        }

        }

        if (  isset($edad) &   $edad != null) {
            $query = "UPDATE users SET   edad='$edad' where id=$user_id";
            $statement = $pdo->query($query);
        }

        if (isset($sexo) & $sexo != null) {
            $query = "UPDATE users SET   sex='$sexo' where id=$user_id";
            $statement = $pdo->query($query);
        }

        if (isset($ocupacion) & $ocupacion!= null) {
            $query = "UPDATE users SET   ocupacion='$ocupacion' where id=$user_id";
            $statement = $pdo->query($query);
        }


        if (isset($claveString) & $claveString != null) {
            $query = "UPDATE users SET   passwd='$clave' where id=$user_id";
            $statement = $pdo->query($query);
        }

        


        if (isset($foto) && $foto['error'] == UPLOAD_ERR_OK) {
            $nombreFoto = $_FILES['foto']['name'];
            $carpetaTemporal = $_FILES['foto']['tmp_name'];
            $carpetaDestino = $_SERVER['DOCUMENT_ROOT'] . '/carpeta_web/video/imagenesUsuario/' . $nombreFoto;
            move_uploaded_file($carpetaTemporal, $carpetaDestino);
        
            $query = "UPDATE users SET pic='$nombreFoto' WHERE id=$user_id";
            $statement = $pdo->query($query);
        }

    } catch (PDOException $e) {
        die("Error en la consulta: " . $e->getMessage());
    }


    ?>


</body>

</html>
