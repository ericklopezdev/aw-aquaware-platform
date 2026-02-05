<?php

declare(strict_types=1);

require_once __DIR__ . '/../vendor/autoload.php';

use App\Calculator;
use App\User;

$calculator = new Calculator();

echo "Calculator Tests:\n";
echo "=================\n";
echo "2 + 3 = " . $calculator->add(2, 3) . "\n";
echo "10 - 4 = " . $calculator->subtract(10, 4) . "\n";
echo "5 * 6 = " . $calculator->multiply(5, 6) . "\n";
echo "20 / 4 = " . $calculator->divide(20, 4) . "\n";

echo "\nUser Tests:\n";
echo "============\n";
$user = new User('John Doe', 'john@example.com', 30);
echo $user->greet() . "\n";
echo "Email: " . $user->getEmail() . "\n";
echo "Age: " . $user->getAge() . "\n";
