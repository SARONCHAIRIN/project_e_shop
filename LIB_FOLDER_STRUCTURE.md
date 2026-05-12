# Lib Folder Structure Documentation

## Overview
This document describes the organization and purpose of each folder in the `lib/` directory of the Flutter e-commerce application. The structure follows Clean Architecture principles with clear separation of concerns.

## Folder Structure

### 📁 `core/`
**Purpose**: Contains the fundamental building blocks and shared utilities that are used across the entire application.

#### Subfolders:
- **`config/`**: Application configuration files, environment settings, and constants
- **`constants/`**: App-wide constants, API endpoints, and configuration values
- **`network/`**: Network-related utilities, API clients, and HTTP interceptors
- **`storage/`**: Local storage management, token storage, and data persistence utilities
- **`utils/`**: Shared utility functions, helpers, and common tools

### 📁 `data/`
**Purpose**: Handles all data operations, external API communications, and data persistence. This layer is responsible for data fetching, caching, and storage.

#### Subfolders:
- **`datasources/`**: Concrete implementations for data sources (API calls, database operations, local storage)
- **`models/`**: Data transfer objects (DTOs) and model classes that represent API responses and database entities
- **`repositories/`**: Repository implementations that abstract data sources and provide clean interfaces to the domain layer

### 📁 `domains/`
**Purpose**: Contains business logic, domain entities, and use cases. This layer is independent of any external frameworks or UI concerns.

#### Subfolders:
- **`entities/`**: Domain entities that represent core business objects
- **`repositories/`**: Abstract repository interfaces that define data operations
- **`use_cases/`**: Business logic use cases that orchestrate domain operations

### 📁 `Presentation/`
**Purpose**: Contains all UI-related code, state management, and presentation logic. This layer handles user interactions and displays data.

#### Subfolders:
- **`controllers/`**: State management controllers (Provider, Bloc, etc.) that manage UI state
- **`screen/`**: Screen/page widgets that represent full application screens
- **`widgets/`**: Reusable UI components and custom widgets

### 📁 `utils/`
**Purpose**: Application-wide utility functions and helpers that don't fit into other specific layers.

#### Contents:
- **`validator.dart`**: Input validation utilities and form validation logic

## Architecture Principles

### Clean Architecture Layers
1. **Presentation Layer** (`Presentation/`): UI and state management
2. **Domain Layer** (`domains/`): Business logic and use cases
3. **Data Layer** (`data/`): Data access and external APIs
4. **Core Layer** (`core/`): Shared utilities and infrastructure

### Dependency Rule
- **Presentation** → **Domain** → **Data** → **Core**
- Inner layers should not depend on outer layers
- Dependencies point inward only

### Naming Conventions
- Use `snake_case` for folder names
- Use `PascalCase` for class names and file names
- Use descriptive, meaningful names that clearly indicate purpose

## File Organization Guidelines

### Controllers
- Place in `Presentation/controllers/`
- One controller per major feature (auth, cart, product, etc.)
- Follow naming pattern: `{Feature}Controller`

### Screens
- Place in `Presentation/screen/`
- Organize by feature: `auth/`, `product/`, `cart/`, etc.
- Use descriptive names: `login_screen.dart`, `product_list_screen.dart`

### Widgets
- Place in `Presentation/widgets/`
- Group by feature or commonality: `common/`, `auth/`, `product/`
- Use reusable, composable components

### Models
- Place in `data/models/`
- Group by feature: `user/`, `product/`, `cart/`
- Include both request/response models and local models

### Services & Repositories
- Services in `data/datasources/`
- Repository interfaces in `domains/repositories/`
- Repository implementations in `data/repositories/`

## Benefits of This Structure

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Testability**: Business logic is isolated and easily testable
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features without affecting existing code
5. **Reusability**: Components can be reused across different parts of the app

## Migration Notes

When restructuring existing code:
1. Update all import statements to reflect new paths
2. Ensure dependency injection is properly configured
3. Update any hardcoded paths or references
4. Test all affected functionality after moves

## Future Improvements

Consider implementing:
- Feature-based folder organization within layers
- Shared widgets library
- More granular separation of concerns
- Automated testing structure aligned with folder organization
