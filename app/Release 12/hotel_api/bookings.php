<?php
include_once 'config.php';
$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'GET') {
    $stmt = $db->query("SELECT * FROM bookings ORDER BY check_in_date DESC");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}

if ($method == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    if (!empty($data->room_id) && !empty($data->client_id) && !empty($data->days) && !empty($data->total_cost)) {
        
        $check_in = date('Y-m-d H:i:s');
        $check_out = date('Y-m-d H:i:s', strtotime("+$data->days days"));

        $stmt = $db->prepare("INSERT INTO bookings (room_id, client_id, check_in_date, check_out_date, total_cost, is_active) VALUES (:room, :client, :in, :out, :cost, 1)");
        $stmt->execute([
            ':room' => $data->room_id,
            ':client' => $data->client_id,
            ':in' => $check_in,
            ':out' => $check_out,
            ':cost' => $data->total_cost
        ]);

        // Меняем статус комнаты на Занят
        $stmtRoom = $db->prepare("UPDATE rooms SET status = 'Занят' WHERE id = :room");
        $stmtRoom->execute([':room' => $data->room_id]);

        // Обновляем историю клиента
        $stmtClient = $db->prepare("UPDATE clients SET history = IF(history = '', :room_num, CONCAT(history, ', ', :room_num)) WHERE id = :client");
        $stmtClient->execute([':room_num' => $data->room_number, ':client' => $data->client_id]);

        echo json_encode(["success" => true]);
    }
}

// ДОБАВИЛИ: Удаление брони из базы данных
if ($method == 'DELETE') {
    $data = json_decode(file_get_contents("php://input"));
    if (!empty($data->id)) {
        $stmt = $db->prepare("DELETE FROM bookings WHERE id = :id");
        $stmt->execute([':id' => $data->id]);
        echo json_encode(["success" => true]);
    }
}
?>