<!DOCTYPE html>

<head>
  <title>Formulario de Registro</title>
 
    <link rel="stylesheet" type="text/css" href="DesignRegistro.css">

  <script src="WebJS.js"></script>
</head>

<body>

  <h1>Registro de Usuario</h1>


  <form action="Registro.php" method="POST" enctype="multipart/form-data">
    Nombre:
    <input type="text" name="nombre" placeholder="Introduzca su nombre"  required>

    Edad:
    <input type="number" name="edad" min="1" max="100" placeholder="Introduzca su edad" required>

    Sexo:
    <select name="sexo" required>
      <option value="M">M</option>
      <option value="F">F</option>

    </select>


    Ocupacion: 
    <select name="ocupacion"  required>
        <option value="administrator">administrator </option>
        <option value="artist"> artist</option>
        <option value="doctor"> doctor</option>
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
    <input type="password" name="clave" placeholder="Introduzca su contraseña" required >
    <br>

    Elija su foto de perfil:
    <input type="file" id="foto" name="foto" accept="image/*" >

    <input type="submit" value="Registrar">

  </form>
  <a href="iniciarSesion.php"><input type="submit" value="Iniciar sesion"></a>
  <a href="Index.php"><input type="submit" value="Catalogo"></a>



</body>




<?php

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
  

  // Verificar si el nombre de usuario ya existe en la base de datos
  $query = "SELECT COUNT(*) FROM users WHERE name = :nombre";
  $statement = $pdo->prepare($query);
  $statement->bindParam(':nombre', $nombre);
  $statement->execute();
  $count = $statement->fetchColumn();

  if ($count > 0) {
    echo "<script> registroYaExiste()</script>";
    exit;
  }

  if (!empty($nombre) & !empty($edad) & !empty($sexo) & !empty($ocupacion) & !empty($foto) & !empty($claveString)) {
       //vamos a operar sobre la foto
      $nombreFoto = $_FILES['foto']['name'];

      //carptea temporal donde se guarda la foto
      $carpetaTemporal = $_FILES['foto']['tmp_name'];
      $carpetaDestino = $_SERVER['DOCUMENT_ROOT'] . '/carpeta_web/video/imagenesUsuario/'.$nombreFoto;      
      move_uploaded_file($carpetaTemporal,  $carpetaDestino);

    // Preparar la consulta para insertar el usuario en la base de datos
    $query = "INSERT INTO users (name, edad, sex, ocupacion, pic, passwd) 
    VALUES ('$nombre', '$edad', '$sexo', '$ocupacion', '$nombreFoto ', '$clave')";
     $result = $pdo->query($query);
    
    if ($result) {
      echo "<script> registroCorrecto() </script>";
    } else {
      echo "<script>registroFallido() </script>";
    }
  }
} catch (PDOException $e) {
  die("Error en la consulta: " . $e->getMessage());
}


?>

</body>



</html>
