<!DOCTYPE html>
<html>

<head>
    <title>Cine MH</title>
    <link rel="stylesheet" type="text/css" href="DesignCatalogo.css">
</head>

<body>
    <?php
    // comprobamos si el usuario esta logeado
    session_start();
    $user_id = isset($_SESSION['id']) ? $_SESSION['id'] : null;


    try {
        $pdo = new PDO("mysql:host=localhost;dbname=ai0", 'ai0', 'ai2024');
    } catch (PDOException $e) {
        die("Error al conectar a la base de datos: " . $e->getMessage());
    }

    try {
        $query = "SELECT * FROM users WHERE id = '$user_id' ";
        $result = $pdo->query($query);
        $user = $result->fetch(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        die("Error en la consulta: " . $e->getMessage());
    }


    if (isset($_SESSION['username'])) {
        echo "<div id='tabla-Registro'>
        <table>
             <tr>
                <td><a href='Usuario.php'> <input type='submit'  value='Perfil:$user[name]'></a> </td>
                <td><a href='finalizarSesion.php'><input type='submit'  value='Finalizar Sesión'></a></td>
              </tr>
            </table>
        </div>";
    } else {
        echo "<div id='tabla-Registro'>
            <h1>BIENVENIDO A LA CINES MH</h1>
            <table>
                <tr>
                    <td colspan='2'>Inicie sesion o Registrese</td>
                </tr>
                <tr>
                    <form action='iniciarSesion.php' method='GET'>
                        <td> <input type='submit' name='Iniciar_Sesion' value='Iniciar Sesion'></td>
                    </form>
                    <form action='Registro.php' method='GET'>
                        <td><input type='submit' name='Registrese' value='Registrese'></td>
                    </form>
                </tr>
            </table>
        </div>";
    }
    ?>

    <!-- Para permitir la reordenación -->
    <form method="get" action="Index.php">
        <div id="EntradaOrdenar">
            <label for="orden">Ordenar por:</label>
            <select name="orden" id="orden">
                <option value="defecto">Orden por defecto</option>
                <option value="nombreZA">Nombre Z-A</option>
                <option value="nombreAZ">Nombre A-Z</option>
                <option value="puntuacion">Puntuación Media</option>
            </select>
            <input type="submit" value="Ordenar">
        </div>
    </form>

    <div id="tabla-Datos">
        <table>
            <th>Imagen </th>
            <th>Título </th>
            <th>Descripción</th>
            <th>Fecha estreno </th>
            <th>Puntuación media</th>
            <th>Número puntuaciones</th>
            <th>Puntación ponderada </th>

            <?php
            try {
                $queryMovie = "Select * From movie";
                $orden = isset($_GET['orden']) ? $_GET['orden'] : 'defecto';
                if ($orden == 'nombreZA') {
                    $queryMovie  .= " ORDER BY movie.title DESC";
                } else if ($orden == 'nombreAZ') {

                    $queryMovie  .= " ORDER BY movie.title ASC";
                } else if ($orden == 'puntuacion') {
                    $queryMovie  .= " ORDER BY (SELECT AVG(score) FROM user_score WHERE user_score.id_movie = movie.id) DESC";
                }

                $result = $pdo->query($queryMovie);
                $pelis = $result->fetchAll(PDO::FETCH_ASSOC);

                foreach ($pelis as $peli) {
                    $idMovie = $peli['id'];
                    $Imagen = $peli['url_pic'];
                    $Titulo = $peli['title'];
                    $Descripcion = $peli['desc'];
                    $fechaEstreno = $peli['date'];

                    //Consulta para obtener la media de puntuacion de cada pelicula y el numero de puntuaciones
                    $queryScore = "SELECT AVG(score) AS media,COUNT(score) AS numero  FROM user_score WHERE user_score.id_movie= $idMovie";
                    $result = $pdo->query($queryScore);
                    $scoreData = $result->fetch(PDO::FETCH_ASSOC);
                    $puntuacionMedia = $scoreData['media'];
                    $numeroPuntaciones = $scoreData['numero'];

                    //Consulta para obtener la puntuacion ponderada de cada pelicula
                    // Número total de películas
                    $queryNumeroPeliculas = "SELECT COUNT(*) AS numeroPeliculas FROM movie";
                    $result = $pdo->query($queryNumeroPeliculas);
                    $NP = $result->fetch(PDO::FETCH_ASSOC);
                    $NumeroPeliculas = $NP['numeroPeliculas'];

                    // Puntuación media de todas las películas
                    $queryMediaTodasPeliculas = "SELECT AVG(score) AS mediaTodasPeliculas FROM user_score";
                    $result = $pdo->query($queryMediaTodasPeliculas);
                    $MTP = $result->fetch(PDO::FETCH_ASSOC);
                    $MediaTodasPeliculas = $MTP['mediaTodasPeliculas'];


                    $NumeroPuntuacionesPelicula = $numeroPuntaciones;
                    // Puntuación ponderada
                    $puntuacionPonderada = (($NumeroPeliculas * $MediaTodasPeliculas) + ($NumeroPuntuacionesPelicula * $puntuacionMedia)) / ($NumeroPeliculas + $NumeroPuntuacionesPelicula);

                    //modificado para que te lleve a PrubeaPelicula.php
                    echo "
                        <tr> 
                        <td><a href='Pelicula.php?idMovie=$idMovie'><img src=images/$Imagen></a></td> 
                        <td>$Titulo</td>
                            <td>$Descripcion</td>
                            <td>$fechaEstreno</td>
                            <td>$puntuacionMedia</td>
                            <td>$numeroPuntaciones</td>
                            <td>$puntuacionPonderada</td>
                        </tr>";
                }
            } catch (PDOException $e) {
                die("Error en la consulta: " . $e->getMessage());
            }
            ?>

        </table>
    </div>

</body>

</html>
