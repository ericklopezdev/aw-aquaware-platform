<?php

declare(strict_types=1);

namespace App;

class User
{
    public function __construct(
        private string $name,
        private string $email,
        private int $age = 0
    ) {}

    public function getName(): string
    {
        return $this->name;
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    public function getAge(): int
    {
        return $this->age;
    }

    public function setAge(int $age): void
    {
        if ($age < 0) {
            throw new \InvalidArgumentException('Age cannot be negative');
        }
        $this->age = $age;
    }

    public function greet(): string
    {
        return "Hello, my name is {$this->name}";
    }
}
