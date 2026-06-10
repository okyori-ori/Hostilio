<?php
// РАЗРЕШАЕМ HEADERS ДЛЯ ИСПРАВЛЕНИЯ БЕСКОНЕЧНОЙ ЗАГРУЗКИ (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Если прилетел предварительный запрос OPTIONS от приложения — сразу отвечаем "ОК" и гасим скрипт
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$host = 'localhost';
$db_name = 'hotel_db';
$username = 'root';
$password = '';

try {
    $db = new PDO("mysql:host=$host;dbname=$db_name;charset=utf8", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo json_encode(["success" => false, "message" => "Ошибка подключения к БД: " . $e->getMessage()]);
    exit();
}
?>