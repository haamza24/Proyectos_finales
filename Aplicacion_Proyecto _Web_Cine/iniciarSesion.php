<!DOCTYPE html>

<head>
    <title>Iniciar Sesión</title>
    <link rel="stylesheet" type="text/css" href="DesignIniciarSesion.css">

    <script src="WebJS.js"></script>

</head>

<body>
    <br>
    <form action="iniciarSesion.php" method="post">
        <h1> INICIO SESION </h1>

        Nombre de Usuario:
        <input type="text" name="username" placeholder="Introduzca tu nombre" required>

        Clave:
        <input type="password" name="password" placeholder="Introduzca tu password" required>

        <input type="submit" value=" Iniciar Sesion">
    </form>

    <div class="menuAbajo">
        <a href="Registro.php"><input type="submit" value="Registrate"></a>
        <a href="Index.php"><input type="submit" value="Catalogo"></a>

    </div>

    <?php

    if (isset($_POST['username']) && isset($_POST['password'])) {   //si se ha introducido un nombre de usuario y una contraseña
        $username = $_POST['username'];
        $password = sha1($_POST['password']);
        //conectar a la base de datos
        try {
            $pdo = new PDO("mysql:host=localhost;dbname=ai0", 'ai0', 'ai2024');
        } catch (PDOException $e) {
            die("Error al conectar a la base de datos: " . $e->getMessage());
        }

        try {
            $query = "SELECT * FROM users WHERE name = '$username' AND passwd = '$password'";
            $result = $pdo->query($query);
            $user = $result->fetch(PDO::FETCH_ASSOC);

            if ($user) {
                session_start();             // Iniciar sesión
                $_SESSION['id'] = $user['id']; // Almacenar el ID del usuario en la variable de sesión
                $_SESSION['username'] = $username; // Almacenar el nombre de usuario en la variable de sesión
                header("Location: Usuario.php");  //para que me redirija a la pagina de usuario
                exit();
            } else {
                echo "<script>entradaIncorrecta()</script>";
            }
        } catch (PDOException $e) {
            die("Error en la consulta: " . $e->getMessage());
        }
    }

    ?>

</body>

</html>
