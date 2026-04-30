# Further Reading — TypeScript DDD & Architecture

Reference for implementing RAVEgraph and Swamp following Domain-Driven Design patterns in TypeScript. The primary reference is **Khalil Stemmler's** work at [khalilstemmler.com](https://khalilstemmler.com), which is the closest TypeScript equivalent to Cosmic Python.

---

## Priority Reading Order (for Swamp)

1. **Use Cases / Application Layer** — how to structure the orchestration pipeline
2. **Ports & Adapters** — how to keep external-tool connectors swappable
3. **Domain Events** — the falsifier-triggers → incident-created pattern
4. **Repository Pattern + Entities/Value Objects** — the domain model
5. **Result/Either** — error handling throughout all layers
6. **`stemmlerjs/ddd-forum`** — read `src/modules/` to see all patterns wired together

---

## Foundational / Overview

**[An Introduction to Domain-Driven Design (DDD)](https://khalilstemmler.com/articles/domain-driven-design-intro/)**
Covers all core DDD building blocks — Entities, Value Objects, Aggregates, Repositories, Domain Events, Domain Services — and the layered architecture they inhabit. Best starting point before the more focused articles.

**[Organizing App Logic with the Clean Architecture](https://khalilstemmler.com/articles/software-design-architecture/organizing-app-logic/)**
Maps six types of logic (presentation, data access, use case, domain service, validation, entity logic) to their correct architectural layers. Directly applicable when deciding where to put evidence-fetching, API-pushing, and triggering logic in Swamp.

**[Clean Node.js Architecture (Ports & Adapters)](https://khalilstemmler.com/articles/enterprise-typescript-nodejs/clean-nodejs-architecture/)**
Explains the Policy vs. Detail distinction and the Dependency Rule: domain layer code never depends on infrastructure. Shows how to use TypeScript interfaces as "ports" and concrete implementations as "adapters" — the pattern needed to keep external-tool clients (Datadog, GitHub, OPA) swappable.

**[DDD vs. Clean Architecture — Concept Comparison](https://khalilstemmler.com/articles/software-design-architecture/domain-driven-design-vs-clean-architecture/)**
Clarifies terminological overlap: DDD's "Application Services" = Clean Architecture's "Use Cases", etc. References `stemmlerjs/ddd-forum` as the working example.

---

## Application / Service Layer

**[Better Software Design with Application Layer Use Cases](https://khalilstemmler.com/articles/enterprise-typescript-nodejs/application-layer-use-cases/)**
The definitive article on use cases as application services. Covers the `UseCase<Req, Res>` interface, dependency-injected repositories, Command-Query Segregation, and chaining use cases via domain events. Directly maps to how Swamp's "fetch evidence" and "push to RAVEgraph API" operations should be structured.

**[Use DTOs to Enforce a Layer of Indirection](https://khalilstemmler.com/articles/enterprise-typescript-nodejs/use-dtos-to-enforce-a-layer-of-indirection/)**
Explains why DTOs act as a data contract between layers, preventing API clients from being broken by internal domain changes. Relevant when designing the API push layer of Swamp.

---

## Domain Events

**[Decoupling Logic with Domain Events [Guide]](https://khalilstemmler.com/articles/typescript-domain-driven-design/chain-business-logic-domain-events/)**
The primary reference for domain events in TypeScript. Shows a static `DomainEvents` dispatcher, the `IDomainEvent` interface, how Aggregate Roots raise events, and how separate handlers subscribe without coupling. Directly maps to the "falsifier triggers → emit event → create incident" pattern.

**[Where Do Domain Events Get Created?](https://khalilstemmler.com/blogs/domain-driven-design/where-do-domain-events-get-dispatched/)**
Clarifies that domain events belong in the domain layer and should be raised inside aggregate root methods. Explains how TypeScript getters/setters enable event creation on state change before repository dispatch.

**[Why Event-Based Systems?](https://khalilstemmler.com/articles/enterprise-typescript-nodejs/why-event-based-systems/)**
Makes the architectural case for event-driven design: auditing, scalability, avoiding anemic domain models. Foundational framing for building an automation service around domain events.

**[Temporal Decoupling: Why We Use Events & Messages](https://khalilstemmler.com/articles/temporal-decoupling-messaging/)**
Explains why event/message-based architecture decouples features temporally, enabling async workflows. References "Enterprise Integration Patterns" (Hohpe & Woolf) for deeper reading.

---

## Aggregates

**[How to Design & Persist Aggregates](https://khalilstemmler.com/articles/typescript-domain-driven-design/aggregate-design-persistence/)**
Walks through identifying an aggregate root, defining its consistency boundary over related entities, and wiring up repositories and use cases. Discusses tradeoffs: invariant enforcement vs. query performance vs. CQS.

**[How to Handle Updates on Aggregates](https://khalilstemmler.com/articles/typescript-domain-driven-design/updating-aggregates-in-domain-driven-design/)**
Covers the atomic update pattern: collect `Result` instances for each field change into a `changes` array, call `Result.combine()`, then persist only if all pass. Useful when an orchestration service modifies incident aggregates based on incoming evidence.

**[Challenges in Aggregate Design #1](https://khalilstemmler.com/articles/typescript-domain-driven-design/domain-modeling-1/)**
Tackles cross-subdomain aggregate references: the right answer is domain events + eventual consistency rather than direct coupling. Models the kind of cross-service concern that arises in multi-tool orchestration.

**[Handling Collections in Aggregates (0-to-Many, Many-to-Many)](https://khalilstemmler.com/articles/typescript-domain-driven-design/one-to-many-performance/)**
Addresses performance problems with unbounded collections inside aggregates using CQS principles. Relevant when an incident aggregate accumulates many evidence items over time.

---

## Entities & Value Objects

**[Understanding Domain Entities](https://khalilstemmler.com/articles/typescript-domain-driven-design/entities/)**
Covers the full entity lifecycle: creation via static factory methods, storage, reconstitution, modification. Private constructors, invariant enforcement, and the use of repositories/mappers to separate domain from persistence.

**[Value Objects - DDD w/ TypeScript](https://khalilstemmler.com/articles/typescript-value-object/)**
Explains Value Objects as structurally-equal, immutable domain primitives. Shows the base `ValueObject<T>` class with `equals()`, private constructors, and factory methods. The pattern for wrapping every domain primitive (severity levels, incident IDs, confidence scores, etc.).

**[Make Illegal States Unrepresentable!](https://khalilstemmler.com/articles/typescript-domain-driven-design/make-illegal-states-unrepresentable/)**
Shows how TypeScript's type system (nominal types, private constructors, `Result<T>`, `Either<L,R>`) makes it impossible to construct invalid domain objects at compile time. Key for ensuring external API responses can't corrupt domain state.

---

## Repository Pattern

**[Implementing DTOs, Mappers & the Repository Pattern using Sequelize ORM](https://khalilstemmler.com/articles/typescript-domain-driven-design/repository-dto-mapper/)**
The core repository article. Shows domain-specific repository interfaces, concrete ORM implementations, and Data Mappers that transform between domain entities, ORM models, and DTOs.

---

## Error Handling

**[Flexible Error Handling w/ the Result Class](https://khalilstemmler.com/articles/enterprise-typescript-nodejs/handling-errors-result-class/)**
Introduces the `Result<T>` class with `isSuccess`, `isFailure`, `Result.ok()`, `Result.fail()`, and `Result.combine()`. The fundamental building block used in every factory method and use case.

**[Functional Error Handling with Express.js and DDD](https://khalilstemmler.com/articles/enterprise-typescript-nodejs/functional-error-handling/)**
Extends `Result<T>` with the `Either<L,R>` monad and domain-specific error namespaces. Shows how use cases express every possible failure as a typed value that callers must handle.

---

## Example Repositories

**[stemmlerjs/ddd-forum](https://github.com/stemmlerjs/ddd-forum)**
The primary, most complete example. A Hacker News-inspired forum built with Express.js, Sequelize, Redis, and TypeScript. Implements two full subdomains (Users, Forum) with Aggregate Roots, Value Objects, Domain Events, Repositories, and Use Cases. Companion app for solidbook.io. Read `src/modules/` to see all patterns wired together.

**[stemmlerjs/white-label](https://github.com/stemmlerjs/white-label)**
An older vinyl-trading DDD app referenced by many article code examples. Less complete than ddd-forum but useful for reading specific patterns like the Either monad branch and aggregate design.

**[Sairyss/domain-driven-hexagon](https://github.com/Sairyss/domain-driven-hexagon)**
Heavily-cited educational repo demonstrating DDD + Hexagonal (Ports & Adapters) + Clean Architecture + CQRS in TypeScript. Uses NestJS as the delivery mechanism but the domain and application layers contain no NestJS dependencies — the patterns are framework-agnostic. Excellent as a structural reference.

**[node-ts/ddd](https://github.com/node-ts/ddd)**
A lightweight, plain Node.js/TypeScript DDD framework (no NestJS). Focuses on aggregate roots with a single point of access and domain event emission. Useful for understanding a minimal framework implementation.

---

## Book

**[solidbook.io](https://solidbook.io)**
Khalil Stemmler's paid software design and architecture handbook. Covers DDD use cases, application services, and the ddd-forum codebase in depth. The free [wiki](https://wiki.solidbook.io/) has summary pages including one on [use cases / application services](https://wiki.solidbook.io/summary-on-use-cases-application-services-5956daca6f394d6180f26696bcfe38cb/).
