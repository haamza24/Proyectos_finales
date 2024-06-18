


<?php
session_start();


$user_id = $_SESSION['id'];

try {
    $pdo = new PDO("mysql:host=localhost;dbname=ai0", 'ai0', 'ai2024');
} catch (PDOException $e) {
    die("Error al conectar a la base de datos: " . $e->getMessage());
}

try {
    $query = "SELECT * FROM users WHERE id = '$user_id' ";
    $result = $pdo->query($query);
    //ejecutamos las consulta anterior :
    $user = $result->fetch(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    die("Error en la consulta: " . $e->getMessage());
}

?>
<!DOCTYPE html>
<html>

<head>

<link rel="stylesheet" type="text/css" href="DesignUsuario.css">
</head>

<body>
    <?php

    if ($user) {

        $nombre = $user['name'];
        $edad = $user['edad'];
        $sexo = $user['sex'];
        $ocupacion = $user['ocupacion'];
        $foto = $user['pic'];
    } else {
        echo "Error: No se encontró el usuario con ID $user_id.";
    }


    ?>


    
<div id="menu">
        <a href="Index.php">Catalogo</a>
        <a href="finalizarSesion.php">Finalizar Sesion</a>
        <a href="ModificarInformacion.php">Modificar Informacion</a>
    </div>

            
    <div id="user-info">
        <?php echo "<img src=imagenesUsuario/$foto>"; ?>
        <table id="user-table">
            <tr>
                
                <td>Nombre:<?php echo $nombre; ?></td>
            </tr>
            <tr>
             
                <td>Edad:<?php echo $edad; ?></td>
            </tr>
            <tr>
                
                <td>Sexo:<?php echo $sexo; ?></td>
            </tr>
            <tr>
               
                <td>Ocupación:<?php echo $ocupacion; ?></td>
            </tr>
           
        </table>
        <BR>
   
    </div>

        <h1>Bienvenido, <?php echo $nombre; ?>!</h1>
       
        
</body>

</html>
