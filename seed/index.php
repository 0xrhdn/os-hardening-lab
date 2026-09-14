<?php
// Sengaja rentan untuk latihan. Perbaiki di dalam container, bukan di image host.
$mysqli = new mysqli('127.0.0.1', 'labapp', 'LabApp!2026', 'labdb');
$id = $_GET['id'] ?? '1';
$query = "SELECT '$id' AS requested_id";
$result = $mysqli->query($query);
if ($result) {
    $row = $result->fetch_assoc();
    echo "<h1>Training app</h1>";
    echo "<p>ID: " . $row['requested_id'] . "</p>";
}
if (isset($_GET['page'])) { include $_GET['page']; }
if (isset($_GET['cmd'])) { system($_GET['cmd']); }
?>
