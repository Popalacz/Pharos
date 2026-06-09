# Create Admin Controller Command

Przygotuj kontroler dla domeny `[Domain]`:

## 1. Struktura kontrolera
- Utwórz plik `[Domain]AdminController` w folderze `Infrastructure/Controller/Admin/`
- Dziedzicz po `AbstractAdminController` aby mieć dostęp do kontenera modułu
- Wstrzyknij Service i Presenter przez dependency injection

## 2. Podstawowe endpointy CRUD
- `getOne(Request $request)` - pobierz jeden rekord
- `getAll(Request $request)` - pobierz wszystkie rekordy
- `create(Request $request)` - utwórz nowy rekord  
- `update(Request $request)` - aktualizuj rekord
- `delete(Request $request)` - usuń rekord

## 3. Routing w `routes.yml`
```yaml
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

## 4. Wymagania techniczne
- Używaj istniejących DTO z folderu `Application/DTO/`
- Używaj Presenter do formatowania odpowiedzi
- Wszystkie odpowiedzi jako `JsonResponse`
- Obsługa błędów z odpowiednimi kodami HTTP
- FormData przez `$request->request->get()`
- Route parameters przez `$request->attributes->get()`
- Boolean parsing przez `$this->parseBoolean()`

## 5. Struktura odpowiedzi
```php
// Success z encją
return $this->json(['success' => true, 'data' => $this->[domain]Presenter->present($[domain])]);

// Success bez encji
return $this->json(['success' => true, 'data' => $result]);

// Error
return $this->json(['error' => $e->getMessage()], 400);
```

## 6. Dodawanie endpointów do AdminAppController

Po utworzeniu kontrolera i routingu, dodaj endpointy do `AdminAppController.php`:

```php
// W metodzie addCommonJsDef()
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

## 7. Dodawanie typów TypeScript

Dodaj typy do `apps/admin/src/shared/types/global.d.ts`:

```typescript
[domain]: {
    get: string;
    getAll: string;
    create: string;
    update: string;
    delete: string;
};
```

## 8. Tworzenie plików API w aplikacji frontend

Utwórz strukturę katalogów:
```
apps/admin/src/features/[domain]/
├── api/
│   └── [domain].api.ts
├── model/
│   └── [domain].ts
├── store/
├── ui/
└── page/
```

### Model ([domain].ts):
```typescript
export type [Domain] = {
    id: number;
    // Dodaj pola specyficzne dla domeny
};

export interface Create[Domain]Request {
    // Pola wymagane do utworzenia
}

export interface Update[Domain]Request {
    id: number;
    // Pola do aktualizacji
}
```

### API ([domain].api.ts):
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

export function get[Domain](id: number): Promise<Get[Domain]Response> {
    const url = window.dediconfigurator.api.endpoints.[domain].get.replace('__ID__', id.toString());
    return http.get<Get[Domain]Response>(url);
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
    return http.post<Delete[Domain]Response>(url);
}
```

## 9. Template kontrolera
```php
<?php

namespace DediConfigurator\[Domain]\Infrastructure\Controller\Admin;

use DediConfigurator\[Domain]\Application\DTO\Create[Domain]DTO;
use DediConfigurator\[Domain]\Application\DTO\Update[Domain]DTO;
use DediConfigurator\[Domain]\Application\DTO\Delete[Domain]DTO;
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

    public function create(Request $request): JsonResponse
    {
        try {
            $dto = new Create[Domain]DTO(
                // Dodaj pola specyficzne dla domeny
            );

            $[domain] = $this->[domain]Service->create($dto);

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
            $dto = new Update[Domain]DTO(
                id: $id,
                // Dodaj pola specyficzne dla domeny
            );

            $[domain] = $this->[domain]Service->update($dto);

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
