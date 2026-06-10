<?php
include_once 'config.php';
$method = $_SERVER['REQUEST_METHOD'];

// Получение списка номеров
if ($method == 'GET') {
    $stmt = $db->query("SELECT * FROM rooms ORDER BY number ASC");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}

// Добавление нового номера
if ($method == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    if (!empty($data->number) && !empty($data->type) && !empty($data->price_per_night)) {
        $stmt = $db->prepare("INSERT INTO rooms (number, type, price_per_night, status) VALUES (:num, :type, :price, 'Свободен')");
        $stmt->execute([':num' => $data->number, ':type' => $data->type, ':price' => $data->price_per_night]);
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "message" => "Неполные данные"]);
    }
}

// ОБНОВЛЕНИЕ СТАТУСА (Заезд/Выезд/Уборка) - ИСПРАВЛЕНО
if ($method == 'PUT') {
    $data = json_decode(file_get_contents("php://input"));
    
    // Проверяем, что пришли и ID, и новый статус
    if (!empty($data->id) && !empty($data->status)) {
        // Жестко привязываемся к ID, чтобы обновить только одну запись
        $stmt = $db->prepare("UPDATE rooms SET status = :status WHERE id = :id");
        $success = $stmt->execute([
            ':status' => $data->status, 
            ':id' => $data->id
        ]);
        
        if ($success) {
            echo json_encode(["success" => true]);
        } else {
            echo json_encode(["success" => false, "message" => "Ошибка БД при обновлении"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Некорректный ID или статус"]);
    }
}

// Удаление номера
if ($method == 'DELETE') {
    $data = json_decode(file_get_contents("php://input"));
    if (!empty($data->id)) {
        $stmt = $db->prepare("DELETE FROM rooms WHERE id = :id");
        $stmt->execute([':id' => $data->id]);
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "message" => "ID не указан"]);
    }
}
?>