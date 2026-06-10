php
include_once 'config.php';
$method = $_SERVER['REQUEST_METHOD'];
$data = json_decode(file_get_contents(phpinput));

if ($method == 'POST') {
     Регистрация
    if (isset($data-action) && $data-action == 'register') {
        if (!empty($data-username) && !empty($data-password)) {
            $stmt = $db-prepare(INSERT INTO users (username, password) VALUES (user, pass));
            try {
                $stmt-execute(['user' = $data-username, 'pass' = password_hash($data-password, PASSWORD_BCRYPT)]);
                echo json_encode([success = true]);
            } catch(PDOException $e) {
                echo json_encode([success = false, message = Пользователь уже существует]);
            }
        }
    }
     Вход
    if (isset($data-action) && $data-action == 'login') {
        if (!empty($data-username) && !empty($data-password)) {
            $stmt = $db-prepare(SELECT  FROM users WHERE username = user);
            $stmt-execute(['user' = $data-username]);
            $user = $stmt-fetch(PDOFETCH_ASSOC);
            
            if ($user && password_verify($data-password, $user['password'])) {
                echo json_encode([success = true]);
            } else {
                echo json_encode([success = false, message = Неверный логин или пароль]);
            }
        }
    }
}
