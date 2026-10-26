<?php
// Aplicació de consulta dels equipaments d'educació de Barcelona (W-NCC)

$config = @include __DIR__ . '/config.php';
if (!$config) {
    http_response_code(500);
    exit('Falta el fitxer config.php (copia config.example.php).');
}

try {
    $pdo = new PDO(
        "mysql:host={$config['host']};dbname={$config['dbname']};charset=utf8mb4",
        $config['user'],
        $config['password'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
} catch (PDOException $e) {
    http_response_code(500);
    exit('No es pot connectar a la base de dades.');
}

// Districtes per al filtre
$districtes = $pdo->query(
    "SELECT DISTINCT addresses_district_name FROM educacio
      WHERE addresses_district_name <> '' ORDER BY 1"
)->fetchAll(PDO::FETCH_COLUMN);

$q = trim($_GET['q'] ?? '');
$districte = $_GET['districte'] ?? '';

// Consulta preparada: evita la injecció SQL
$sql = "SELECT name, addresses_road_name, addresses_start_street_number,
               addresses_district_name, addresses_neighborhood_name
          FROM educacio
         WHERE name LIKE :q";
$params = [':q' => "%$q%"];
if ($districte !== '') {
    $sql .= " AND addresses_district_name = :d";
    $params[':d'] = $districte;
}
// El CSV té una fila per cada atribut de l'equipament: agrupem per nom
$sql .= " GROUP BY name, addresses_road_name, addresses_start_street_number,
                   addresses_district_name, addresses_neighborhood_name
          ORDER BY name LIMIT 200";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$files = $stmt->fetchAll(PDO::FETCH_ASSOC);

$total = $pdo->query("SELECT COUNT(DISTINCT name) FROM educacio")->fetchColumn();

function e($text) { return htmlspecialchars($text ?? '', ENT_QUOTES, 'UTF-8'); }
?>
<!doctype html>
<html lang="ca">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Equipaments d'educació · BCN</title>
  <style>
    body  { font-family: system-ui, sans-serif; margin: 2rem auto; max-width: 1000px; padding: 0 1rem; }
    form  { display: flex; gap: .5rem; flex-wrap: wrap; margin-bottom: 1rem; }
    input, select, button { padding: .4rem .6rem; font-size: 1rem; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border-bottom: 1px solid #ddd; padding: .4rem; text-align: left; }
    th { background: #f3f3f3; }
    .info { color: #666; }
  </style>
</head>
<body>
  <h1>Equipaments d'educació de Barcelona</h1>
  <p class="info"><?= e($total) ?> equipaments a la base de dades · Font: Open Data BCN</p>

  <form>
    <input name="q" value="<?= e($q) ?>" placeholder="Cerca per nom">
    <select name="districte">
      <option value="">Tots els districtes</option>
      <?php foreach ($districtes as $d): ?>
        <option <?= $d === $districte ? 'selected' : '' ?>><?= e($d) ?></option>
      <?php endforeach; ?>
    </select>
    <button>Cercar</button>
  </form>

  <p class="info"><?= count($files) ?> resultats<?= count($files) === 200 ? ' (es mostren els 200 primers)' : '' ?></p>

  <table>
    <tr><th>Nom</th><th>Adreça</th><th>Barri</th><th>Districte</th></tr>
    <?php foreach ($files as $f): ?>
    <tr>
      <td><?= e($f['name']) ?></td>
      <td><?= e(trim($f['addresses_road_name'] . ' ' . $f['addresses_start_street_number'])) ?></td>
      <td><?= e($f['addresses_neighborhood_name']) ?></td>
      <td><?= e($f['addresses_district_name']) ?></td>
    </tr>
    <?php endforeach; ?>
  </table>
</body>
</html>
