I'll explore this codebase to understand its architecture and structure. Based on the project layout, this appears to be a complex tax filing application called "Direct File" with multiple frontend applications, backend services, and supporting infrastructure.

Let me start by examining key files to understand the overall structure:
Read file: README.md
Read file: direct-file/df-client/df-client-app/package.json
Read file: direct-file/df-client/df-client-app/src/App.tsx
Read file: direct-file/df-static-site/package.json
Ran tool
Let me continue exploring the static site and look at some key architecture files:
Read file: direct-file/df-client/df-static-site/package.json
Read file: ONBOARDING.md
Ran tool
Search files...
Read file: direct-file/df-client/df-client-app/src/factgraph
Let me continue exploring the architecture by looking at the fact graph implementation and other key components:
Ran tool
Read file: direct-file/df-client/df-client-app/src/factgraph/FactGraphContext.tsx
Read file: direct-file/df-client/df-client-app/src/flow
Ran tool
Ran tool
Let me continue exploring to understand the architecture better:
Read file: direct-file/df-client/df-client-app/src/flow/flowConfig.tsx
Read file: direct-file/docker-compose.yaml
Ran tool
Ran tool
Ran tool
Based on my exploration of the codebase, I can provide you with a comprehensive overview of the **Direct File** project architecture:

## 🏛️ **Overall Architecture Overview**

Direct File is a sophisticated tax filing application built by the IRS that provides taxpayers with a free, government-provided tax filing service. The architecture follows a modern microservices pattern with the following key characteristics:

### **🎯 Core Components**

#### **1. Frontend Applications (React/TypeScript)**
- **Main Application** (`df-client-app`): The primary taxpayer-facing UI
  - Built with React 18, TypeScript, Vite, and USWDS (US Web Design System)
  - Uses Redux Toolkit for state management
  - Multilingual support (English/Spanish) with i18next
  - Mobile-first responsive design

- **Static Site** (`df-static-site`): Information pages and screener
  - Lighter-weight React application for marketing/info content
  - Uses similar tech stack but without the complex form logic

#### **2. Backend Services (Java/Spring Boot)**
- **Primary API** (`backend/`): Main backend service handling authentication, user data, and fact graph operations
- **Email Service**: SMTP relay for taxpayer notifications
- **State API**: Handles state tax software integration via REST APIs
- **Submit Service**: Interfaces with IRS MeF (Modernized e-File) system
- **Status Service**: Polls MeF for return acknowledgments

#### **3. Fact Graph Engine (Scala)**
This is the most innovative architectural component:
- **Declarative Knowledge Graph**: XML-based data structure for reasoning about incomplete tax information
- **Cross-Platform**: Runs on JVM backend and transpiled to JavaScript for client-side use via Scala.js
- **Tax Logic Engine**: Interprets US Internal Revenue Code as plain language questions
- **Validation & Flow Control**: Determines which screens to show based on taxpayer responses

### **🔧 Technical Stack Deep Dive**

#### **Frontend Technologies:**
- **React 18** with TypeScript 5.6.3
- **Vite** for build tooling and dev server
- **@trussworks/react-uswds** for government design system compliance
- **React Router v6** for navigation
- **Redux Toolkit** for state management
- **i18next** for internationalization
- **Vitest** for testing

#### **Backend Technologies:**
- **Java Spring Boot** microservices
- **PostgreSQL** databases (separate per service)
- **Maven** for build management
- **Docker** for containerization
- **LocalStack** for AWS service simulation
- **OpenTelemetry** for observability

#### **Infrastructure:**
- **Docker Compose** for local development
- **Redis** for caching
- **LocalStack** for AWS services simulation
- **Grafana & Prometheus** for monitoring

### **🌊 Application Flow Architecture**

The application uses a sophisticated flow management system:

1. **Screen Flow Configuration**: Declarative configuration that determines which screens to show based on taxpayer data
2. **Condition-Based Navigation**: Uses the Fact Graph to evaluate conditions and determine next steps
3. **Dynamic UI Generation**: Screens are generated based on XML configurations and fact graph state
4. **Validation Gates**: Each section has completion conditions that must be met before proceeding

### **🔐 Key Architectural Patterns**

#### **1. Microservices with Shared Libraries**
- Each service has its own database and concerns
- Shared fact graph library ensures consistent tax logic
- BOM (Bill of Materials) for dependency management

#### **2. Domain-Driven Design**
- Tax logic is centralized in the fact graph
- Clear separation between UI flow and business rules
- Test scenarios mirror real tax situations

#### **3. Progressive Enhancement**
- Server-side fact graph validation
- Client-side optimization for user experience
- Graceful degradation for network issues

### **🎨 Frontend Architecture Patterns**

#### **Context Providers & Hooks:**
- `FactGraphContext`: Manages fact graph state across components
- `TaxReturnsContext`: Handles multiple tax return scenarios
- `SystemAlertContext`: Manages system-wide alerts and messages

#### **Component Architecture:**
- **Screen-based Components**: Each tax form section is a screen
- **Reusable UI Components**: Built on USWDS for consistency
- **Flow Control**: Dynamic routing based on fact graph state

#### **State Management:**
```typescript
// Fact graph integration with React
const { factGraph } = useFactGraph();
const taxReturnData = factGraph.get(somePath);
```

### **🔍 Development Experience**

The codebase demonstrates excellent engineering practices:
- **TypeScript** throughout for type safety
- **Comprehensive testing** with Vitest and React Testing Library
- **ESLint/Prettier** for code quality
- **Automated dependency management** with npm workspaces
- **Hot reloading** for development efficiency

### **🚀 Notable Innovations**

1. **Fact Graph**: A declarative approach to tax logic that's domain-agnostic and could be useful for other rule-based systems
2. **Cross-language Integration**: Scala code running on both JVM and JavaScript
3. **Government-Grade Accessibility**: Full USWDS compliance and accessibility features
4. **Real-time Validation**: Immediate feedback on tax form completion

This is a remarkably well-architected system that balances complexity with maintainability, showcasing modern full-stack development practices in a government context.