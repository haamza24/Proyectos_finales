<html>



<head>
    <title>Cine MH</title>
    <link rel="stylesheet" type="text/css" href="DesignPelicula.css">

</head>

<body>

    <?php
    try {
        $pdo = new PDO("mysql:host=localhost;dbname=ai0", 'ai0', 'ai2024');
    } catch (PDOException $e) {
        die("Error al conectar a la base de datos: " . $e->getMessage());
    }



    //compruebo si esta inciada sesion y que usuario es, si se cumple, mostraré las puntuaciones
    session_start();
    $user_id = isset($_SESSION['id']) ? $_SESSION['id'] : null;
    $idVideo = isset($_GET['idMovie']) ? $_GET['idMovie'] : null;

    if (isset($_SESSION['username'])) {

        echo "<div id='botonesSuperior'>
        <a href='finalizarSesion.php'> <input type='submit' value='Finalizar Sesión'></a>
        <a href='Usuario.php'> <input type='submit' value='Perfil'></a>
        <h1>Usuario: " . $_SESSION['username'] . "</h1>
      </div>";

        echo "<div id=formularioPuntua>
            <form action='Pelicula.php' method='GET'>
                <input type='hidden' name='idMovie' value='$idVideo'>
                Introduzca su puntuación:
                <input type='number' name='usuarioPuntua' min='1' max='5'>
                <input type='submit' name='puntuar' value='Puntuar'>
            </form>
          </div>";

        echo "<div id=formularioComenta>
          <form action='Pelicula.php' method='GET'>
              <input type='hidden' name='idMovie' value='$idVideo'>
              Introduzca su comentario :
    
              <textarea name='Comenta' id='ComentaTextarea'></textarea>
              <input type='submit' name='comentar' value='Comentar'>
          </form>
        </div>";




        if (isset($_GET['usuarioPuntua'])) {

            try {
                $puntuacion = $_GET['usuarioPuntua'];
                $query = "INSERT INTO user_score (id_user, id_movie, score) 
                                     VALUES ( '$user_id', '$idVideo', '$puntuacion') 
                                     ON DUPLICATE KEY UPDATE score = $puntuacion";
                $result = $pdo->query($query);
            } catch (PDOException $e) {
                die("Error en la consulta: " . $e->getMessage());
            }
        }

        if (isset($_GET['comentar'])) {
            try {
                $user_id = isset($_SESSION['id']) ? $_SESSION['id'] : null;
                $idVideo = isset($_GET['idMovie']) ? $_GET['idMovie'] : null;
                $comentario = $_GET['Comenta'];
                $query = "INSERT INTO moviecomments (movie_id, user_id, comment) 
                VALUES ('$idVideo','$user_id','$comentario')";
                $result = $pdo->query($query);
            } catch (PDOException $e) {
                die("Error en la consulta: " . $e->getMessage());
            }
        }
    }


    ?>




    <div id="generos">
        <?php

        try {



            $queryGenero = "SELECT  genre.name from   genre,moviegenre where  moviegenre.movie_id  = $idVideo and moviegenre.genre=genre.id";
            $result = $pdo->query($queryGenero);
            $videos = $result->fetchAll(PDO::FETCH_ASSOC);

            echo "<a href='Index.php' id='volverButton'><input type='submit' value='Volver al Catálogo'></a><br><br>
            Los generos de la pelicula son:";

            foreach ($videos as $video) {
                $genero = $video['name'];

                echo "
                    <li>$genero</li>
                    ";
            }
        } catch (PDOException $e) {
            die("Error en la consulta: " . $e->getMessage());
        }
        ?>

    </div>



    <div id="comentarios">
        <table>
            <thead>
                <tr>
                    <th colspan="2" id="imagenTable">
                        <?php
                        try {
                            $queryImagen = "SELECT movie.url_pic , movie.title FROM movie WHERE movie.id = $idVideo";
                            $resultImagen = $pdo->query($queryImagen);
                            $imagen = $resultImagen->fetch(PDO::FETCH_ASSOC);
                            echo "<h1>$imagen[title]</h1>";
                            echo " <br><img src='images/{$imagen['url_pic']}' ";
                        } catch (PDOException $e) {
                            die("Error en la consulta de la imagen: " . $e->getMessage());
                        }
                        ?>
                    </th>
                </tr>
                <tr>
                    <th>Usuario</th>
                    <th>comentario</th>
                </tr>
            </thead>
            <tbody>
                <?php
                try {

                    $queryComentario = "SELECT  moviecomments.comment,users.name, movie.url_pic from   moviecomments ,
                     movie,users where  moviecomments.movie_id  = $idVideo and movie.id=$idVideo
                     and users.id=moviecomments.user_id";

                    $result = $pdo->query($queryComentario);
                    $videos = $result->fetchAll(PDO::FETCH_ASSOC);



                    foreach ($videos as $video) {
                        $user = $video['name'];
                        $comentario = $video['comment'];
                        echo "   
                <tr>                 
                    <td>$user</td>
                    <td>$comentario</td
                  

                </tr>


                    ";
                    }
                    $query = "SELECT * FROM user_score WHERE user_score.id_user = '$user_id' and id_movie='$idVideo'   ";
                    $result = $pdo->query($query);
                    $puntuaciones = $result->fetchAll(PDO::FETCH_ASSOC);


                    foreach ($puntuaciones as $puntuacion) {
                        $puntuacion = $puntuacion['score'];
                        echo "<tr><td colspan='2' id='SalidaPuntaucion'>Tu puntuacion para esta pelicula es: $puntuacion</td></tr>";
                    }
                } catch (PDOException $e) {
                    die("Error en la consulta: " . $e->getMessage());
                }

                ?>

            </tbody>
        </table>
    </div>

</body>

</html>
