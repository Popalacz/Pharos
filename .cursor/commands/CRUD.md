# CRUD Command - Kompletny przewodnik tworzenia operacji CRUD

Kompletny przewodnik tworzenia operacji CRUD (Create, Read, Update, Delete) dla domeny `[Domain]` z pełną integracją backendu (CQRS), frontendu (Vue) i systemu PrestaShop.

## Spis treści

1. [Przygotowanie encji domenowej](#1-przygotowanie-encji-domenowej)
2. [Utworzenie DTO, Commands, Queries i Handlers](#2-utworzenie-dto-commands-queries-i-handlers)
3. [Utworzenie Repository](#3-utworzenie-repository)
4. [Utworzenie Service i Presenter](#4-utworzenie-service-i-presenter)
5. [Utworzenie kontrolera](#5-utworzenie-kontrolera)
6. [Routing i integracja backend](#6-routing-i-integracja-backend)
7. [Tabele SQL](#7-tabele-sql)
8. [Taby w PrestaShop](#8-taby-w-prestashop)
9. [Frontend - Store](#9-frontend---store)
10. [Frontend - Komponenty Vue](#10-frontend---komponenty-vue)
11. [Frontend - Routing](#11-frontend---routing)

---

## 1. Przygotowanie encji domenowej

Utwórz encję domenową w `src/[Domain]/Domain/Entity/[Domain].php`:

```php
<?php

namespace DediConfigurator\[Domain]\Domain\Entity;

use DediConfigurator\Shared\Domain\ValueObject\LangValue;

if (!defined('_PS_VERSION_')) {
    exit;
}

class [Domain]
{
    /**
     * @param LangValue<string> $name Multilingual name
     * @param ?int $id
     * @param ?\DateTime $createdAt
     * @param ?\DateTime $updatedAt
     */
    public function __construct(
        private LangValue $name,
        private ?int $id = null,
        private ?\DateTime $createdAt = null,
        private ?\DateTime $updatedAt = null,
    ) {
        if ($this->name->isEmpty()) {
            throw new \InvalidArgumentException('Name must have at least one translation');
        }
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    /**
     * Get multilingual name value object
     * 
     * @return LangValue<string>
     */
    public function getName(): LangValue
    {
        return $this->name;
    }

    public function getCreatedAt(): ?\DateTime
    {
        return $this->createdAt;
    }

    public function getUpdatedAt(): ?\DateTime
    {
        return $this->updatedAt;
    }
}
```

**Uwagi:**
- Jeśli encja nie wymaga wielojęzyczności, usuń `LangValue` i użyj zwykłego typu
- Dodaj walidację w konstruktorze zgodnie z wymaganiami domeny
- Dodaj dodatkowe pola specyficzne dla domeny

---

## 2. Utworzenie DTO, Commands, Queries i Handlers

### 2.1. DTO (Data Transfer Objects)

#### Create[Domain]DTO

Utwórz `src/[Domain]/Application/DTO/[Domain]/Create[Domain]DTO.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\DTO\[Domain];

if (!defined('_PS_VERSION_')) {
    exit;
}

class Create[Domain]DTO
{
    /**
     * @param array<int, string> $names Multilingual names: [langId => name]
     */
    public function __construct(
        private readonly array $names = [],
    ) {
    }

    /**
     * @return array<int, string>
     */
    public function getNames(): array
    {
        return $this->names;
    }
}
```

#### Update[Domain]DTO

Utwórz `src/[Domain]/Application/DTO/[Domain]/Update[Domain]DTO.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\DTO\[Domain];

if (!defined('_PS_VERSION_')) {
    exit;
}

class Update[Domain]DTO
{
    /**
     * @param int $id [Domain] ID
     * @param array<int, string> $names Multilingual names: [langId => name]
     */
    public function __construct(
        private readonly int $id,
        private readonly array $names = [],
    ) {
    }

    public function getId(): int
    {
        return $this->id;
    }

    /**
     * @return array<int, string>
     */
    public function getNames(): array
    {
        return $this->names;
    }
}
```

#### Delete[Domain]DTO

Utwórz `src/[Domain]/Application/DTO/[Domain]/Delete[Domain]DTO.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\DTO\[Domain];

if (!defined('_PS_VERSION_')) {
    exit;
}

class Delete[Domain]DTO
{
    public function __construct(
        private readonly int $id,
    ) {
    }

    public function getId(): int
    {
        return $this->id;
    }
}
```

### 2.2. Commands

#### Create[Domain]Command

Utwórz `src/[Domain]/Application/Command/[Domain]/Create[Domain]Command.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\Command\[Domain];

use DediConfigurator\[Domain]\Application\DTO\[Domain]\Create[Domain]DTO;

if (!defined('_PS_VERSION_')) {
    exit;
}

class Create[Domain]Command
{
    public function __construct(
        private readonly Create[Domain]DTO $dto,
    ) {
    }

    public function getDto(): Create[Domain]DTO
    {
        return $this->dto;
    }
}
```

#### Update[Domain]Command

Utwórz `src/[Domain]/Application/Command/[Domain]/Update[Domain]Command.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\Command\[Domain];

use DediConfigurator\[Domain]\Application\DTO\[Domain]\Update[Domain]DTO;

if (!defined('_PS_VERSION_')) {
    exit;
}

class Update[Domain]Command
{
    public function __construct(
        private readonly Update[Domain]DTO $dto,
    ) {
    }

    public function getDto(): Update[Domain]DTO
    {
        return $this->dto;
    }
}
```

#### Delete[Domain]Command

Utwórz `src/[Domain]/Application/Command/[Domain]/Delete[Domain]Command.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\Command\[Domain];

use DediConfigurator\[Domain]\Application\DTO\[Domain]\Delete[Domain]DTO;

if (!defined('_PS_VERSION_')) {
    exit;
}

class Delete[Domain]Command
{
    public function __construct(
        private readonly Delete[Domain]DTO $dto,
    ) {
    }

    public function getDto(): Delete[Domain]DTO
    {
        return $this->dto;
    }
}
```

### 2.3. Queries

#### GetAll[Domain]sQuery

Utwórz `src/[Domain]/Application/Query/[Domain]/GetAll[Domain]sQuery.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\Query\[Domain];

if (!defined('_PS_VERSION_')) {
    exit;
}

class GetAll[Domain]sQuery
{
    // This query doesn't need any parameters as it returns all [domain]s
}
```

#### Get[Domain]Query

Utwórz `src/[Domain]/Application/Query/[Domain]/Get[Domain]Query.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\Query\[Domain];

if (!defined('_PS_VERSION_')) {
    exit;
}

class Get[Domain]Query
{
    public function __construct(
        private readonly int $id,
    ) {
    }

    public function getId(): int
    {
        return $this->id;
    }
}
```

### 2.4. Handlers

#### Create[Domain]Handler

Utwórz `src/[Domain]/Application/Handler/[Domain]/Create[Domain]Handler.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\Handler\[Domain];

use DediConfigurator\[Domain]\Application\Command\[Domain]\Create[Domain]Command;
use DediConfigurator\[Domain]\Domain\Entity\[Domain];
use DediConfigurator\[Domain]\Infrastructure\Repository\[Domain]Repository;
use DediConfigurator\Shared\Domain\ValueObject\LangValue;

if (!defined('_PS_VERSION_')) {
    exit;
}

class Create[Domain]Handler
{
    public function __construct(
        private readonly [Domain]Repository $[domain]Repository,
    ) {
    }

    public function handle(Create[Domain]Command $command): ?[Domain]
    {
        $dto = $command->getDto();
        $nameLangValue = new LangValue();
        foreach ($dto->getNames() as $langId => $name) {
            $nameLangValue->set($langId, $name);
        }
        
        $[domain] = new [Domain](
            name: $nameLangValue
        );
        
        return $this->[domain]Repository->create($[domain]);
    }
}
```

#### Update[Domain]Handler

Utwórz `src/[Domain]/Application/Handler/[Domain]/Update[Domain]Handler.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\Handler\[Domain];

use DediConfigurator\[Domain]\Application\Command\[Domain]\Update[Domain]Command;
use DediConfigurator\[Domain]\Domain\Entity\[Domain];
use DediConfigurator\[Domain]\Infrastructure\Repository\[Domain]Repository;
use DediConfigurator\Shared\Domain\ValueObject\LangValue;

if (!defined('_PS_VERSION_')) {
    exit;
}

class Update[Domain]Handler
{
    public function __construct(
        private readonly [Domain]Repository $[domain]Repository,
    ) {
    }

    public function handle(Update[Domain]Command $command): ?[Domain]
    {
        $dto = $command->getDto();
        
        $existing[Domain] = $this->[domain]Repository->findOne($dto->getId());
        if ($existing[Domain] === null) {
            return null;
        }
        
        $nameLangValue = new LangValue();
        foreach ($dto->getNames() as $langId => $name) {
            $nameLangValue->set($langId, $name);
        }
        
        $[domain] = new [Domain](
            name: $nameLangValue,
            id: $dto->getId(),
            createdAt: $existing[Domain]->getCreatedAt(),
            updatedAt: $existing[Domain]->getUpdatedAt(),
        );
        
        return $this->[domain]Repository->update($[domain]);
    }
}
```

#### Delete[Domain]Handler

Utwórz `src/[Domain]/Application/Handler/[Domain]/Delete[Domain]Handler.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\Handler\[Domain];

use DediConfigurator\[Domain]\Application\Command\[Domain]\Delete[Domain]Command;
use DediConfigurator\[Domain]\Infrastructure\Repository\[Domain]Repository;

if (!defined('_PS_VERSION_')) {
    exit;
}

class Delete[Domain]Handler
{
    public function __construct(
        private readonly [Domain]Repository $[domain]Repository,
    ) {
    }

    public function handle(Delete[Domain]Command $command): bool
    {
        $dto = $command->getDto();
        
        return $this->[domain]Repository->delete($dto->getId());
    }
}
```

#### GetAll[Domain]sHandler

Utwórz `src/[Domain]/Application/Handler/[Domain]/GetAll[Domain]sHandler.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\Handler\[Domain];

use DediConfigurator\[Domain]\Application\Query\[Domain]\GetAll[Domain]sQuery;
use DediConfigurator\[Domain]\Domain\Entity\[Domain];
use DediConfigurator\[Domain]\Infrastructure\Repository\[Domain]Repository;

if (!defined('_PS_VERSION_')) {
    exit;
}

class GetAll[Domain]sHandler
{
    public function __construct(
        private readonly [Domain]Repository $[domain]Repository,
    ) {
    }

    /**
     * @return [Domain][]
     */
    public function handle(GetAll[Domain]sQuery $query): array
    {
        return $this->[domain]Repository->findAll();
    }
}
```

#### Get[Domain]Handler

Utwórz `src/[Domain]/Application/Handler/[Domain]/Get[Domain]Handler.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Application\Handler\[Domain];

use DediConfigurator\[Domain]\Application\Query\[Domain]\Get[Domain]Query;
use DediConfigurator\[Domain]\Domain\Entity\[Domain];
use DediConfigurator\[Domain]\Infrastructure\Repository\[Domain]Repository;

if (!defined('_PS_VERSION_')) {
    exit;
}

class Get[Domain]Handler
{
    public function __construct(
        private readonly [Domain]Repository $[domain]Repository,
    ) {
    }

    public function handle(Get[Domain]Query $query): ?[Domain]
    {
        return $this->[domain]Repository->findOne($query->getId());
    }
}
```

---

## 3. Utworzenie Repository

Utwórz `src/[Domain]/Infrastructure/Repository/[Domain]Repository.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Infrastructure\Repository;

use DediConfigurator\[Domain]\Domain\Entity\[Domain];
use DediConfigurator\Shared\Domain\ValueObject\LangValue;

if (!defined('_PS_VERSION_')) {
    exit;
}

class [Domain]Repository
{
    public const TABLE_NAME = 'dediconfigurator_[domain]';
    public const TABLE_LANG_NAME = 'dediconfigurator_[domain]_lang';

    public function __construct(
        private readonly \Db $db,
    ) {
    }

    /**
     * @param ?int $langId
     * @return [Domain][]
     */
    public function findAll(?int $langId = null): array
    {
        $query = new \DbQuery();
        $query->select('e.*, el.id_lang, el.name');
        $query->from(self::TABLE_NAME, 'e');
        $query->leftJoin(
            self::TABLE_LANG_NAME,
            'el',
            'el.id_[domain] = e.id'
        );

        if ($langId !== null) {
            $query->where('el.id_lang = ' . (int) $langId);
        }

        $[domain]s = $this->db->executeS($query);

        if (empty($[domain]s) || !is_array($[domain]s)) {
            return [];
        }

        return $this->hydrateCollection($[domain]s);
    }

    public function findOne(int $id, ?int $langId = null): ?[Domain]
    {
        $query = new \DbQuery();
        $query->select('e.*, el.id_lang, el.name');
        $query->from(self::TABLE_NAME, 'e');
        $query->leftJoin(
            self::TABLE_LANG_NAME,
            'el',
            'el.id_[domain] = e.id'
        );
        $query->where('e.id = ' . (int) $id);

        if ($langId !== null) {
            $query->where('el.id_lang = ' . (int) $langId);
        }

        $[domain]s = $this->db->executeS($query);

        if (empty($[domain]s) || !is_array($[domain]s)) {
            return null;
        }

        return $this->hydrate($[domain]s);
    }

    public function create([Domain] $[domain]): ?[Domain]
    {
        $now = new \DateTime();
        
        $this->db->insert(self::TABLE_NAME, [
            'created_at' => $now->format('Y-m-d H:i:s'),
            'updated_at' => $now->format('Y-m-d H:i:s'),
        ]);

        $[domain]Id = (int) $this->db->Insert_ID();

        // Save multilingual names
        $this->saveLangFields($[domain]Id, $[domain]->getName());

        return $this->findOne($[domain]Id);
    }

    public function update([Domain] $[domain]): ?[Domain]
    {
        if ($[domain]->getId() === null) {
            throw new \InvalidArgumentException('[Domain] ID is required for update');
        }

        $now = new \DateTime();

        $this->db->update(self::TABLE_NAME, [
            'updated_at' => $now->format('Y-m-d H:i:s'),
        ], 'id = ' . $[domain]->getId());

        // Update multilingual names
        $this->saveLangFields($[domain]->getId(), $[domain]->getName());

        return $this->findOne($[domain]->getId());
    }

    public function delete(int $id): bool
    {
        // Delete multilingual names first
        $this->deleteNames($id);

        return (bool) $this->db->delete(self::TABLE_NAME, 'id = ' . $id);
    }

    /**
     * @param array<array<string, mixed>> $rows Multiple rows from JOIN (one per language)
     *
     * @return [Domain]
     */
    private function hydrate(array $rows): [Domain]
    {
        if (empty($rows) || !is_array($rows)) {
            throw new \Exception('Invalid [domain] data');
        }

        // First row contains main data
        $firstRow = $rows[0];
        
        if (!isset($firstRow['id'])) {
            throw new \Exception('Invalid [domain] data');
        }

        // Collect multilingual names from all rows
        $nameLangValue = new LangValue();
        foreach ($rows as $row) {
            if (isset($row['id_lang']) && isset($row['name']) && $row['id_lang'] !== null && $row['name'] !== null) {
                $nameLangValue->set((int) $row['id_lang'], (string) $row['name']);
            }
        }

        $createdAt = null;
        if (isset($firstRow['created_at']) && $firstRow['created_at']) {
            $createdAt = \DateTime::createFromFormat('Y-m-d H:i:s', $firstRow['created_at']);
        }

        $updatedAt = null;
        if (isset($firstRow['updated_at']) && $firstRow['updated_at']) {
            $updatedAt = \DateTime::createFromFormat('Y-m-d H:i:s', $firstRow['updated_at']);
        }

        return new [Domain](
            name: $nameLangValue,
            id: (int) $firstRow['id'],
            createdAt: $createdAt,
            updatedAt: $updatedAt,
        );
    }

    /**
     * @param array<array<string, mixed>> $data Multiple rows from JOIN (one per language per [Domain])
     *
     * @return [Domain][]
     */
    private function hydrateCollection(array $data): array
    {
        if (empty($data)) {
            return [];
        }

        // Group rows by id (since JOIN returns multiple rows per [Domain])
        $grouped = [];
        foreach ($data as $row) {
            if (!isset($row['id'])) {
                continue;
            }
            
            $key = (int) $row['id'];
            $grouped[$key][] = $row;
        }

        return array_values(array_map([$this, 'hydrate'], $grouped));
    }

    private function saveLangFields(int $[domain]Id, LangValue $nameLangValue): void
    {
        foreach (\Language::getIDs() as $langId) {
            $name = $nameLangValue->get($langId) ?? '';

            $this->db->insert(self::TABLE_LANG_NAME, [
                'id_[domain]' => $[domain]Id,
                'id_lang' => $langId,
                'name' => $name,
            ], false, true, \Db::ON_DUPLICATE_KEY);
        }
    }

    private function deleteNames(int $[domain]Id): void
    {
        $this->db->delete(self::TABLE_LANG_NAME, 'id_[domain] = ' . $[domain]Id);
    }
}
```

**Uwagi:**
- Jeśli encja nie wymaga wielojęzyczności, usuń metody `saveLangFields` i `deleteNames`, oraz uprość `hydrate` i `hydrateCollection`
- Dostosuj nazwy kolumn w zapytaniach SQL do struktury tabeli
- W `saveLangFields` użyj odpowiedniej nazwy kolumny FK (np. `id_category`, `id_template`)

---

## 4. Utworzenie Service i Presenter

### 4.1. Service

Utwórz `src/[Domain]/Infrastructure/Service/[Domain]Service.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Infrastructure\Service;

use Arkonsoft\PsModule\CQRS\CommandBus;
use Arkonsoft\PsModule\CQRS\QueryBus;
use DediConfigurator\[Domain]\Application\Command\[Domain]\Create[Domain]Command;
use DediConfigurator\[Domain]\Application\Command\[Domain]\Delete[Domain]Command;
use DediConfigurator\[Domain]\Application\Command\[Domain]\Update[Domain]Command;
use DediConfigurator\[Domain]\Application\DTO\[Domain]\Create[Domain]DTO;
use DediConfigurator\[Domain]\Application\DTO\[Domain]\Delete[Domain]DTO;
use DediConfigurator\[Domain]\Application\DTO\[Domain]\Update[Domain]DTO;
use DediConfigurator\[Domain]\Application\Query\[Domain]\GetAll[Domain]sQuery;
use DediConfigurator\[Domain]\Application\Query\[Domain]\Get[Domain]Query;
use DediConfigurator\[Domain]\Domain\Entity\[Domain];

if (!defined('_PS_VERSION_')) {
    exit;
}

class [Domain]Service
{
    public function __construct(
        private readonly CommandBus $commandBus,
        private readonly QueryBus $queryBus,
    ) {
    }

    /**
     * @return [Domain][]
     */
    public function getAll(): array
    {
        return $this->queryBus->handle(new GetAll[Domain]sQuery());
    }

    public function getOne(int $id): ?[Domain]
    {
        return $this->queryBus->handle(new Get[Domain]Query($id));
    }

    public function create(Create[Domain]DTO $dto): ?[Domain]
    {
        return $this->commandBus->handle(new Create[Domain]Command($dto));
    }

    public function update(Update[Domain]DTO $dto): ?[Domain]
    {
        return $this->commandBus->handle(new Update[Domain]Command($dto));
    }

    public function delete(Delete[Domain]DTO $dto): bool
    {
        return $this->commandBus->handle(new Delete[Domain]Command($dto));
    }
}
```

### 4.2. Presenter

Utwórz `src/[Domain]/Presentation/Presenter/[Domain]Presenter.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Presentation\Presenter;

use DediConfigurator\[Domain]\Domain\Entity\[Domain];

if (!defined('_PS_VERSION_')) {
    exit;
}

class [Domain]Presenter
{
    /**
     * @return array<string, mixed>
     */
    public function present([Domain] $[domain]): array
    {
        $nameLangValue = $[domain]->getName();
        $createdAt = $[domain]->getCreatedAt();
        $updatedAt = $[domain]->getUpdatedAt();

        return [
            'id' => $[domain]->getId(),
            'name' => $nameLangValue->getAll(),
            'createdAt' => $createdAt ? $createdAt->format('Y-m-d H:i:s') : null,
            'updatedAt' => $updatedAt ? $updatedAt->format('Y-m-d H:i:s') : null,
        ];
    }

    /**
     * @param [Domain][] $[domain]s
     * @return array<array<string, mixed>>
     */
    public function presentCollection(array $[domain]s): array
    {
        return array_map([$this, 'present'], $[domain]s);
    }
}
```

---

## 5. Utworzenie kontrolera

Utwórz `src/[Domain]/Infrastructure/Controller/Admin/[Domain]AdminController.php`:

```php
<?php

namespace DediConfigurator\[Domain]\Infrastructure\Controller\Admin;

use DediConfigurator\[Domain]\Application\DTO\[Domain]\Create[Domain]DTO;
use DediConfigurator\[Domain]\Application\DTO\[Domain]\Delete[Domain]DTO;
use DediConfigurator\[Domain]\Application\DTO\[Domain]\Update[Domain]DTO;
use DediConfigurator\[Domain]\Infrastructure\Service\[Domain]Service;
use DediConfigurator\[Domain]\Presentation\Presenter\[Domain]Presenter;
use DediConfigurator\Shared\Infrastructure\Controller\AbstractAdminController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;

if (!defined('_PS_VERSION_')) {
    exit;
}

class [Domain]AdminController extends AbstractAdminController
{
    private [Domain]Service $[domain]Service;
    private [Domain]Presenter $[domain]Presenter;

    public function __construct()
    {
        parent::__construct();
        
        if ($this->module === null) {
            throw new \RuntimeException('DediConfigurator module is not available');
        }
        
        $this->[domain]Service = $this->module->moduleContainer->get([Domain]Service::class);
        $this->[domain]Presenter = $this->module->moduleContainer->get([Domain]Presenter::class);
    }

    public function getOne(Request $request): JsonResponse
    {
        $id = (int) $request->attributes->get('id');
        
        $[domain] = $this->[domain]Service->getOne($id);
        
        if ($[domain] === null) {
            return $this->json(['error' => '[Domain] not found'], 404);
        }

        return $this->json([
            'success' => true,
            'data' => $this->[domain]Presenter->present($[domain])
        ]);
    }

    public function getAll(Request $request): JsonResponse
    {
        try {
            $[domain]s = $this->[domain]Service->getAll();

            return $this->json([
                'success' => true,
                'data' => $this->[domain]Presenter->presentCollection($[domain]s)
            ]);
        } catch (\Exception $e) {
            return $this->json(['error' => $e->getMessage()], 400);
        }
    }

    public function create(Request $request): JsonResponse
    {
        try {
            $names = $request->request->get('names', []);
            if (!is_array($names)) {
                $names = [];
            }
            
            // Convert string keys to integer keys for LangValue
            $normalizedNames = [];
            foreach ($names as $langId => $name) {
                $normalizedNames[(int) $langId] = (string) $name;
            }

            $dto = new Create[Domain]DTO(
                names: $normalizedNames,
            );

            $[domain] = $this->[domain]Service->create($dto);

            if ($[domain] === null) {
                return $this->json(['error' => 'Failed to create [domain]'], 400);
            }

            return $this->json([
                'success' => true,
                'data' => $this->[domain]Presenter->present($[domain])
            ]);
        } catch (\Exception $e) {
            return $this->json(['error' => $e->getMessage()], 400);
        }
    }

    public function update(Request $request): JsonResponse
    {
        $id = (int) $request->attributes->get('id');
        
        try {
            $names = $request->request->get('names', []);
            if (!is_array($names)) {
                $names = [];
            }
            
            // Convert string keys to integer keys for LangValue
            $normalizedNames = [];
            foreach ($names as $langId => $name) {
                $normalizedNames[(int) $langId] = (string) $name;
            }

            $dto = new Update[Domain]DTO(
                id: $id,
                names: $normalizedNames,
            );

            $[domain] = $this->[domain]Service->update($dto);

            if ($[domain] === null) {
                return $this->json(['error' => 'Failed to update [domain]'], 400);
            }

            return $this->json([
                'success' => true,
                'data' => $this->[domain]Presenter->present($[domain])
            ]);
        } catch (\Exception $e) {
            return $this->json(['error' => $e->getMessage()], 400);
        }
    }

    public function delete(Request $request): JsonResponse
    {
        $id = (int) $request->attributes->get('id');
        
        try {
            $dto = new Delete[Domain]DTO($id);
            $result = $this->[domain]Service->delete($dto);

            return $this->json([
                'success' => $result
            ]);
        } catch (\Exception $e) {
            return $this->json(['error' => $e->getMessage()], 400);
        }
    }
}
```

**Uwagi:**
- Jeśli encja nie wymaga wielojęzyczności, usuń normalizację `$names` i użyj bezpośrednio danych z requesta
- Dodaj dodatkowe pola specyficzne dla domeny w metodach `create` i `update`

---

## 6. Routing i integracja backend

### 6.1. Routing w routes.yml

Dodaj do `config/routes.yml`:

```yaml
# [Domain] Admin Controller
dediconfigurator.admin.[domain].get:
    path: /dediconfigurator/[domain]/{id}
    methods: [GET]
    defaults:
        _controller: DediConfigurator\[Domain]\Infrastructure\Controller\Admin\[Domain]AdminController::getOne

dediconfigurator.admin.[domain].get_all:
    path: /dediconfigurator/[domain]
    methods: [GET]
    defaults:
        _controller: DediConfigurator\[Domain]\Infrastructure\Controller\Admin\[Domain]AdminController::getAll

dediconfigurator.admin.[domain].create:
    path: /dediconfigurator/[domain]
    methods: [POST]
    defaults:
        _controller: DediConfigurator\[Domain]\Infrastructure\Controller\Admin\[Domain]AdminController::create

dediconfigurator.admin.[domain].update:
    path: /dediconfigurator/[domain]/{id}
    methods: [POST]
    defaults:
        _controller: DediConfigurator\[Domain]\Infrastructure\Controller\Admin\[Domain]AdminController::update

dediconfigurator.admin.[domain].delete:
    path: /dediconfigurator/[domain]/{id}/delete
    methods: [POST]
    defaults:
        _controller: DediConfigurator\[Domain]\Infrastructure\Controller\Admin\[Domain]AdminController::delete
```

**Uwaga:** Ze względu na ograniczenia wersji Symfony używanej w PrestaShop, metody HTTP PUT, PATCH i DELETE nie są poprawnie obsługiwane w routingu. Zamiast tego należy używać metody POST dla operacji update i delete. Dla operacji delete, ścieżka powinna zawierać `/delete` na końcu.

### 6.2. Dodawanie endpointów do AdminAppController

Dodaj do `src/Admin/Infrastructure/Controller/AdminAppController.php` w metodzie `addCommonJsDef()`:

```php
$endpoints['[domain]'] = [
    'get' => $this->generateUrl(
        'dediconfigurator.admin.[domain].get',
        ['id' => '__ID__']
    ),
    'getAll' => $this->generateUrl('dediconfigurator.admin.[domain].get_all'),
    'create' => $this->generateUrl('dediconfigurator.admin.[domain].create'),
    'update' => $this->generateUrl(
        'dediconfigurator.admin.[domain].update',
        ['id' => '__ID__']
    ),
    'delete' => $this->generateUrl(
        'dediconfigurator.admin.[domain].delete',
        ['id' => '__ID__']
    ),
];
```

### 6.3. Dodawanie typów TypeScript

Dodaj do `apps/admin/src/shared/types/global.d.ts`:

```typescript
[domain]: {
    get: string;
    getAll: string;
    create: string;
    update: string;
    delete: string;
};
```

---

## 7. Tabele SQL

### 7.1. Tabela główna i językowa w install.sql

Dodaj do `sql/install.sql`:

```sql
CREATE TABLE IF NOT EXISTS `_DB_PREFIX_dediconfigurator_[domain]` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `created_at` datetime NOT NULL,
    `updated_at` datetime NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=_MYSQL_ENGINE_ DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `_DB_PREFIX_dediconfigurator_[domain]_lang` (
    `id_[domain]` int(10) unsigned NOT NULL,
    `id_lang` int(10) unsigned NOT NULL,
    `name` varchar(255) NOT NULL DEFAULT '',
    PRIMARY KEY (`id_[domain]`, `id_lang`),
    KEY `id_[domain]` (`id_[domain]`),
    KEY `id_lang` (`id_lang`)
) ENGINE=_MYSQL_ENGINE_ DEFAULT CHARSET=utf8;
```

**Uwagi:**
- Jeśli encja nie wymaga wielojęzyczności, usuń tabelę `_lang` i dodaj pole `name` bezpośrednio do tabeli głównej
- Jeśli potrzebne są tabele pośrednie dla relacji wiele-do-wielu, dodaj je również

### 7.2. Instrukcje DROP w uninstall.sql

Dodaj do `sql/uninstall.sql` (w odpowiedniej kolejności - najpierw tabele zależne):

```sql
-- DROP TABLE IF EXISTS `_DB_PREFIX_dediconfigurator_[domain]_lang`;
-- DROP TABLE IF EXISTS `_DB_PREFIX_dediconfigurator_[domain]`;
```

---

## 8. Taby w PrestaShop

### 8.1. Dodanie parametru kontrolera

Dodaj do `dediconfigurator.php` w metodzie `prepareContainer()`:

```php
$this->moduleContainer->setParameter('[domain]_controller_class_name', 'Admin[Domain]');
```

### 8.2. Aktualizacja TabInstaller

#### Dodanie parametru w konstruktorze

W `src/Shared/Infrastructure/Bootstrap/Install/TabInstaller.php`:

```php
/**
 * @param string $[domain]ControllerClassName %[domain]_controller_class_name%
 */
public function __construct(
    private readonly \DediConfigurator $module,
    private readonly string $settingsControllerClassName,
    private readonly string $predefinedEngraversControllerClassName,
    private readonly string $[domain]ControllerClassName,
    private readonly TabManagerInterface $tabManager,
) {
}
```

#### Dodanie taba w getTabs()

```php
new TabConfiguration(
    controllerClassName: (string) $this->[domain]ControllerClassName,
    tabName: 'Nazwa taba',
    tabParent: TabDictionary::CATALOG, // lub inny odpowiedni parent
    shouldBeVisibleInMenu: true
),
```

#### Ustawienie route_name w install()

```php
// Set route_name for [domain] tab
if ($tab->getControllerClassName() === $this->[domain]ControllerClassName) {
    $tabId = $this->tabManager->getIdByControllerClassName($tab->getControllerClassName());
    if ($tabId > 0) {
        $prestaShopTab = new \Tab($tabId);
        $prestaShopTab->route_name = 'dediconfigurator.admin.app.[domain]';
        $prestaShopTab->save();
    }
}
```

### 8.3. Routing dla taba

Dodaj do `config/routes.yml`:

```yaml
# Admin app - [Domain]
dediconfigurator.admin.app.[domain]:
    path: /dediconfigurator/app/[domain]
    methods: [GET]
    defaults:
        _controller: DediConfigurator\Admin\Infrastructure\Controller\AdminAppController::index
        _legacy_controller: Admin[Domain]
        type: [domain]
```

---

## 9. Frontend - Store

Utwórz `apps/admin/src/features/[domain]/store/use[Domain]sStore.ts`:

```typescript
import { defineStore } from "pinia";
import { [Domain] } from "../model/[domain]";
import { 
    getAll[Domain]s,
    delete[Domain],
    get[Domain],
    create[Domain],
    update[Domain],
    [Domain]ApiResult,
} from "../api/[domain].api";
import { toast } from "vue3-toastify";

export const use[Domain]sStore = defineStore('[domain]s', {
    state: () => ({
        [domain]s: [] as [Domain][],
        [domain]: null as [Domain] | null,
        isLoading: false,
        error: null as string | null,
    }),
    actions: {
        async init(): Promise<void> {
            await this.fetchAll();
        },

        async fetchAll(): Promise<void> {
            this.isLoading = true;
            this.error = null;

            try {
                const response = await getAll[Domain]s();
                
                if (!response.success) {
                    throw new Error('Failed to fetch [domain]s');
                }
                
                this.[domain]s = response.data;
            } catch (error) {
                this.error = error instanceof Error ? error.message : 'Failed to load [domain]s';
                toast.error('Błąd podczas ładowania [domain]s: ' + this.error);
                throw error;
            } finally {
                this.isLoading = false;
            }
        },

        async delete[Domain](id: number): Promise<void> {
            this.isLoading = true;
            this.error = null;

            try {
                const response = await delete[Domain](id);
                
                if (!response.success) {
                    throw new Error('Failed to delete [domain]');
                }

                // Remove from local state
                this.[domain]s = this.[domain]s.filter([domain] => [domain].id !== id);
                
                toast.success('[Domain] został usunięty');
            } catch (error) {
                this.error = error instanceof Error ? error.message : 'Failed to delete [domain]';
                toast.error('Błąd podczas usuwania [domain]: ' + this.error);
                throw error;
            } finally {
                this.isLoading = false;
            }
        },

        async initForm(id?: number | null): Promise<void> {
            if (id !== null && id !== undefined) {
                await this.fetch[Domain](id);
            } else {
                // Initialize for create mode
                this.[domain] = {
                    id: 0,
                    name: {},
                    createdAt: null,
                    updatedAt: null,
                };
            }
        },

        async fetch[Domain](id: number): Promise<void> {
            this.isLoading = true;
            this.error = null;

            try {
                const result: [Domain]ApiResult = await get[Domain](id);
                
                if ('error' in result) {
                    this.error = result.error;
                    throw new Error(result.error);
                }

                this.[domain] = result.data;
            } catch (error) {
                this.error = error instanceof Error ? error.message : 'Failed to load [domain]';
                toast.error('Błąd podczas ładowania [domain]: ' + this.error);
                throw error;
            } finally {
                this.isLoading = false;
            }
        },

        async create[Domain](): Promise<void> {
            if (!this.[domain]) {
                throw new Error('[Domain] data is not initialized');
            }

            this.isLoading = true;
            this.error = null;

            try {
                const requestData = {
                    names: this.[domain].name,
                };

                const response = await create[Domain](requestData);
                
                if (!response.success) {
                    throw new Error('Failed to create [domain]');
                }

                this.[domain] = response.data;
                
                // Refresh list
                await this.fetchAll();
                
                toast.success('[Domain] został utworzony');
            } catch (error) {
                this.error = error instanceof Error ? error.message : 'Failed to create [domain]';
                toast.error('Błąd podczas tworzenia [domain]: ' + this.error);
                throw error;
            } finally {
                this.isLoading = false;
            }
        },

        async update[Domain](id: number): Promise<void> {
            if (!this.[domain]) {
                throw new Error('[Domain] data is not initialized');
            }

            this.isLoading = true;
            this.error = null;

            try {
                const requestData = {
                    names: this.[domain].name,
                };

                const response = await update[Domain](id, requestData);
                
                if (!response.success) {
                    throw new Error('Failed to update [domain]');
                }

                this.[domain] = response.data;
                
                // Refresh list
                await this.fetchAll();
                
                toast.success('[Domain] został zaktualizowany');
            } catch (error) {
                this.error = error instanceof Error ? error.message : 'Failed to update [domain]';
                toast.error('Błąd podczas aktualizacji [domain]: ' + this.error);
                throw error;
            } finally {
                this.isLoading = false;
            }
        },
    },
});
```

---

## 10. Frontend - Komponenty Vue

### 10.1. Model

Utwórz `apps/admin/src/features/[domain]/model/[domain].ts`:

```typescript
export type [Domain] = {
    id: number;
    name: Record<number, string>;
    createdAt: string | null;
    updatedAt: string | null;
};

export interface Create[Domain]Request {
    names: Record<number, string>;
}

export interface Update[Domain]Request {
    names: Record<number, string>;
}
```

### 10.2. API

Utwórz `apps/admin/src/features/[domain]/api/[domain].api.ts`:

```typescript
import { useHttp } from "@/shared/api/useHttp";
import { [Domain], Create[Domain]Request, Update[Domain]Request } from "../model/[domain]";

const http = useHttp();

export interface Get[Domain]Response {
    success: boolean;
    data: [Domain];
}

export interface GetAll[Domain]sResponse {
    success: boolean;
    data: [Domain][];
}

export interface Create[Domain]Response {
    success: boolean;
    data: [Domain];
}

export interface Update[Domain]Response {
    success: boolean;
    data: [Domain];
}

export interface Delete[Domain]Response {
    success: boolean;
}

export interface [Domain]ApiErrorResponse {
    error: string;
}

export type [Domain]ApiResult = Get[Domain]Response | [Domain]ApiErrorResponse;

export function get[Domain](id: number): Promise<[Domain]ApiResult> {
    const url = window.dediconfigurator.api.endpoints.[domain].get.replace('__ID__', id.toString());
    return http.get<[Domain]ApiResult>(url);
}

export function getAll[Domain]s(): Promise<GetAll[Domain]sResponse> {
    const url = window.dediconfigurator.api.endpoints.[domain].getAll;
    return http.get<GetAll[Domain]sResponse>(url);
}

export function create[Domain](data: Create[Domain]Request): Promise<Create[Domain]Response> {
    const url = window.dediconfigurator.api.endpoints.[domain].create;
    return http.post<Create[Domain]Response>(url, data);
}

export function update[Domain](id: number, data: Update[Domain]Request): Promise<Update[Domain]Response> {
    const url = window.dediconfigurator.api.endpoints.[domain].update.replace('__ID__', id.toString());
    return http.post<Update[Domain]Response>(url, data);
}

export function delete[Domain](id: number): Promise<Delete[Domain]Response> {
    const url = window.dediconfigurator.api.endpoints.[domain].delete.replace('__ID__', id.toString());
    return http.post<Delete[Domain]Response>(url, {});
}
```

### 10.3. Widok listy

Utwórz `apps/admin/src/features/[domain]/page/[Domain]sList.vue`:

```vue
<script lang="ts" setup>
import Table, { TableHeader } from "@/shared/ui/Table.vue";
import { PuikCard } from "@prestashopcorp/puik-components";
import { computed, onMounted } from "vue";
import { use[Domain]sStore } from "../store/use[Domain]sStore";
import { [Domain] } from "../model/[domain]";

const store = use[Domain]sStore();

const headers: TableHeader[] = [
    {
        key: "id",
        label: "ID",
        width: "50px",
        searchable: true,   
        sortable: true,
    },
    {
        key: "name",
        label: "Nazwa",
        searchable: true,
        sortable: true,
    },
];

const items = computed(() => {
    return store.[domain]s.map(([domain]: [Domain]) => {
        // Get first available name or empty string
        const nameKeys = Object.keys([domain].name);
        const firstName = nameKeys.length > 0 ? [domain].name[Number(nameKeys[0])] : '';
        
        return {
            id: [domain].id,
            name: firstName,
            _[domain]: [domain], // Store original [domain] for actions
        };
    });
});

const handleAddClick = () => {
    const url = new URL(window.location.href);
    url.searchParams.set("action", "add");
    url.searchParams.set("type", "[domain]");
    window.location.href = url.toString();
};

const handleDelete = async (row: any) => {
    if (confirm('Czy na pewno chcesz usunąć ten [domain]?')) {
        try {
            await store.delete[Domain](row.id);
        } catch (error) {
            // Error handling is done in store
        }
    }
};

const getEditUrl = (row: any): string => {
    const url = new URL(window.location.href);
    url.searchParams.set('action', 'edit');
    url.searchParams.set('type', '[domain]');
    url.searchParams.set('id', row.id.toString());
    return url.toString();
};

onMounted(async () => {
    await store.init();
});
</script>

<template>
  <PuikCard>
    <Table
      :header="headers"
      :rows="items"
      title="[Domain]s"
      :fullWidth="true"
      :count="items.length"
      :showAddAction="true"
      :editUrl="getEditUrl"
      :onDelete="handleDelete"
      @addClick="handleAddClick"
      />
  </PuikCard>
</template>

<style scoped>
.actions-wrapper {
    display: flex;
    gap: 1rem;
    justify-content: flex-end;
}
</style>
```

### 10.4. Widok formularza

Utwórz `apps/admin/src/features/[domain]/page/[Domain]sForm.vue`:

```vue
<script lang="ts" setup>
import { PuikCard, PuikButton } from "@prestashopcorp/puik-components";
import FormGroup from "@/shared/ui/FormGroup.vue";
import FormGroupHeader from "@/shared/ui/FormGroupHeader.vue";
import Container from "@/shared/ui/Container.vue";
import MultilingualInput from "@/shared/ui/MultilingualInput.vue";
import { use[Domain]sStore } from "../store/use[Domain]sStore";
import { computed, onMounted } from "vue";

interface Props {
    [domain]Id: number | null;
}

const props = defineProps<Props>();
const store = use[Domain]sStore();

const isEditMode = computed(() => props.[domain]Id !== null);
const [domain] = computed(() => store.[domain]);

const handleSave = async () => {
    if (![domain].value) {
        return;
    }

    try {
        if (isEditMode.value && props.[domain]Id !== null) {
            await store.update[Domain](props.[domain]Id);
        } else {
            await store.create[Domain]();
        }

        // Redirect to list after successful save
        const url = new URL(window.location.href);
        url.searchParams.delete("action");
        url.searchParams.delete("id");
        // Keep type=[domain] to show [domain]s list
        window.location.href = url.toString();
    } catch (error) {
        // Error handling is done in store
    }
};

onMounted(async () => {
    await store.initForm(props.[domain]Id);
});
</script>

<template>
    <Container>
        <PuikCard>
            <div>
                <FormGroup>
                    <FormGroupHeader title="Nazwa" description="Nazwa [domain] wyświetlana w panelu administracyjnym" />
                    <div class="row" v-if="[domain]">
                        <div class="col-md-6">
                            <MultilingualInput
                                :model-value="[domain].name"
                                @update:model-value="
                                    (updatedNames) => {
                                        if ([domain]) {
                                            [domain].name = updatedNames;
                                        }
                                    }
                                "
                            />
                        </div>
                    </div>
                </FormGroup>

                <div class="row">
                    <div class="col-md-12">
                        <div class="form-actions">
                            <PuikButton @click="handleSave" :disabled="store.isLoading || ![domain]">
                                {{ isEditMode ? "Zaktualizuj" : "Utwórz" }}
                            </PuikButton>
                        </div>
                    </div>
                </div>
            </div>
        </PuikCard>
    </Container>
</template>

<style lang="scss" scoped>
.form-actions {
    margin-top: 1rem;
    display: flex;
    gap: 0.5rem;
}
</style>
```

---

## 11. Frontend - Routing

Zaktualizuj `apps/admin/src/shared/bootstrap/Router.vue`:

```vue
<script lang="ts" setup>
import BaseEditForm from "@/features/base/page/BaseEditForm.vue";
import { useUrl } from "../utils/useUrl";
import ComponentEditForm from "@/features/component/page/ComponentEditForm.vue";
import [Domain]sForm from "@/features/[domain]/page/[Domain]sForm.vue";
import [Domain]sList from "@/features/[domain]/page/[Domain]sList.vue";
import { computed } from "vue";

const { appSection, queryParams } = useUrl();

const [domain]Id = computed(() => {
    return queryParams.value.id && queryParams.value.type === '[domain]' ? parseInt(queryParams.value.id) : null;
});

const isAddAction = computed(() => {
    return queryParams.value.action === 'add';
});

const is[Domain]Type = computed(() => {
    return queryParams.value.type === '[domain]';
});

const show[Domain]sForm = computed(() => {
    return appSection.value === '[domain]' && is[Domain]Type.value && ([domain]Id.value !== null || isAddAction.value);
});

const show[Domain]sList = computed(() => {
    return appSection.value === '[domain]' && is[Domain]Type.value && [domain]Id.value === null && !isAddAction.value;
});
</script>
<template>
    <!-- ... existing components ... -->
    <[Domain]sForm
        v-if="show[Domain]sForm"
        :[domain]Id="[domain]Id"
    />
    <[Domain]sList
        v-if="show[Domain]sList"
    />
</template>
```

---

## Podsumowanie

Po wykonaniu wszystkich kroków będziesz mieć:

1. ✅ Pełną warstwę domenową (encja)
2. ✅ Warstwę aplikacji (DTO, Commands, Queries, Handlers)
3. ✅ Warstwę infrastruktury (Repository, Service, Presenter, Controller)
4. ✅ Routing i integrację z systemem
5. ✅ Tabele SQL
6. ✅ Taby w PrestaShop
7. ✅ Frontend (Store, Komponenty Vue, Routing)

Wszystkie operacje CRUD będą działać zarówno z backendu (API), jak i z frontendu (interfejs użytkownika).

