<?php
include_once 'config.php';
$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'GET') {
    $stmt = $db->query("SELECT * FROM clients ORDER BY full_name ASC");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}

if ($method == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    if (!empty($data->full_name) && !empty($data->phone) && !empty($data->email)) {
        $stmt = $db->prepare("INSERT INTO clients (full_name, phone, email, history) VALUES (:name, :phone, :email, '')");
        $stmt->execute([':name' => $data->full_name, ':phone' => $data->phone, ':email' => $data->email]);
        echo json_encode(["success" => true]);
    }
}

if ($method == 'PUT') {
    $data = json_decode(file_get_contents("php://input"));
    if (!empty($data->id) && !empty($data->full_name) && !empty($data->phone)) {
        $stmt = $db->prepare("UPDATE clients SET full_name = :name, phone = :phone, email = :email WHERE id = :id");
        $stmt->execute([
            ':name' => $data->full_name,
            ':phone' => $data->phone,
            ':email' => $data->email,
            ':id' => $data->id
        ]);
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "message" => "Неполные данные"]);
    }
}

if ($method == 'DELETE') {
    $data = json_decode(file_get_contents("php://input"));
    if (!empty($data->id)) {
        $stmt = $db->prepare("DELETE FROM clients WHERE id = :id");
        $stmt->execute([':id' => $data->id]);
        echo json_encode(["success" => true]);
    }
}
?>