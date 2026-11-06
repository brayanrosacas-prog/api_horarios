<?php
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept');
    $conn = new mysqli("localhost", "root", "", "ionic");
    if ($conn->connect_error) {
    // Si hay error, detiene el proceso y envía un JSON para que Ionic lo pueda leer sin crashear
    die(json_encode([
        "status" => "error", 
        "mensaje" => "Error de conexión a la base de datos: " . $conn->connect_error
    ]));
}

// Configurar caracteres a UTF-8 para aceptar acentos y la letra ñ correctamente
$conn->set_charset("utf8");

?>