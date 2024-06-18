<!DOCTYPE html>
<html>

<head>
    <title>Finalizar Sesion</title>
</head>

<body>
    <?php
    // mantener la  session
    session_start();

    if (!isset($_SESSION['username'])) {
        header('Location: Registro.php');
        exit();
    }

    if (isset($_GET['confirmLogout'])) {
        session_destroy();

        header('Location: Index.php');
        exit();
    }
    ?>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Finalizar Sesion</title>
    </head>

    <body>
        <script>
            var confirmLogout = confirm("¿Está seguro de que desea cerrar sesión?");

            if (confirmLogout) {
                window.location.href = "finalizarSesion.php?confirmLogout=true";
            } else {
                window.location.href = "Usuario.php";
            }
        </script>
    </body>

    </html>



</html>
