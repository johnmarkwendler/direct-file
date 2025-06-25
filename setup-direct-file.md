# Direct File Solo Dev Setup Guide

## Phase 1: Install Prerequisites

### Required Software (Install in this order):

1. **Docker Desktop**
   - Download from: https://www.docker.com/products/docker-desktop/
   - Make sure to enable WSL 2 integration if on Windows

2. **Node.js 18+**
   - Download from: https://nodejs.org/
   - Choose the LTS version

3. **Java 21** 
   - Download from: https://adoptium.net/
   - Make sure JAVA_HOME is set

4. **Verify Installation:**
   ```bash
   docker --version
   node --version
   npm --version
   java -version
   ```

## Phase 2: Environment Setup

### Create `.env.local` file in the direct-file directory:

```env
# Basic Development Environment Variables

# Backend Configuration
LOCAL_WRAPPING_KEY=oE3Pm+fr1I+YbX2ZxEe/n9INqJjy00KSl7oXXW4p5Xw=
DF_API_PORT=8080
DF_FE_PORT=3000

# Database
DF_DB_PORT=5435
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

# Submit Service (Mock Configuration)
SUBMIT_ETIN=11111
SUBMIT_ASID=22222222
SUBMIT_EFIN=333333
SUBMIT_ID_VAR_CHARS=dev

# Development Flags
VITE_DISABLE_AUTO_LOGOUT=true
VITE_ALLOW_LOADING_TEST_DATA=true
VITE_BACKEND_URL=http://localhost:8080/df/file/api/
VITE_ENABLE_ESSAR_SIGNING=false

# Mock Authentication
VITE_SADI_AUTH_ID=00000000-0000-0000-0000-000000000000
VITE_SADI_XFF_HEADER=127.0.0.1
VITE_SADI_TID_HEADER=11111111-1111-1111-1111-111111111111
VITE_SADI_LOGOUT_URL=http://localhost:3000/logout

# Docker Settings
DF_LISTEN_ADDRESS=127.0.0.1
```

## Phase 3: Quick Start Commands

### 1. Start the Backend Services (First Terminal):
```bash
cd direct-file
docker-compose up -d db localstack redis
```

### 2. Start the Main API (Second Terminal):
```bash
cd direct-file
docker-compose up api
```

### 3. Start the Frontend (Third Terminal):
```bash
cd direct-file/df-client/df-client-app
npm install
npm run start
```

## Phase 4: What to Expect

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Database**: localhost:5435

## Phase 5: First Customizations

### Mock Authentication
Create `df-client/df-client-app/src/auth/mockAuth.ts`:

```typescript
// Simple mock authentication for development
export const mockAuth = {
  login: async (email: string) => {
    sessionStorage.setItem('email', email);
    sessionStorage.setItem('authenticated', 'true');
    return { success: true };
  },
  
  logout: () => {
    sessionStorage.clear();
    window.location.href = '/';
  },
  
  isAuthenticated: () => {
    return sessionStorage.getItem('authenticated') === 'true';
  },
  
  getCurrentUser: () => {
    return {
      email: sessionStorage.getItem('email') || 'dev@example.com',
      name: 'Developer User'
    };
  }
};
```

### Mock MeF Submission
Create `backend/src/main/java/gov/irs/directfile/api/mock/MockMefService.java`:

```java
@Service
@Profile("development")
public class MockMefService {
    
    @EventListener
    public void handleSubmission(TaxReturnSubmissionEvent event) {
        // Mock the MeF submission process
        log.info("Mock MeF submission for return: {}", event.getTaxReturnId());
        
        // Simulate processing delay
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        // Mock successful response
        String confirmationNumber = "DF" + System.currentTimeMillis();
        
        // Update the submission status
        event.setStatus(ACCEPTED);
        event.setConfirmationNumber(confirmationNumber);
        
        log.info("Mock MeF accepted with confirmation: {}", confirmationNumber);
    }
}
```

## Phase 6: Common Issues & Solutions

### Issue: Docker won't start
**Solution**: Make sure Docker Desktop is running and WSL 2 is enabled

### Issue: Port conflicts
**Solution**: Change ports in docker-compose.yaml:
```yaml
ports:
  - "8081:8080"  # Change 8080 to 8081
```

### Issue: Database connection errors
**Solution**: Wait for database to fully start (check with `docker logs direct-file-db`)

### Issue: Frontend build errors
**Solution**: 
```bash
cd df-client/df-client-app
rm -rf node_modules package-lock.json
npm install
```

## Phase 7: Development Workflow

### Daily Development:
1. Start backend: `docker-compose up -d`
2. Start frontend: `cd df-client/df-client-app && npm run start`
3. Make changes and test
4. Commit changes: `git add . && git commit -m "Your changes"`

### Useful Commands:
- View logs: `docker-compose logs -f api`
- Reset database: `docker-compose down -v && docker-compose up -d db`
- Rebuild containers: `docker-compose build --no-cache`

## Phase 8: Next Steps

Once you have it running:

1. **Add basic tax calculation logic**
2. **Improve the mock authentication**
3. **Add more tax forms support**
4. **Deploy to a cloud provider**
5. **Add real state integrations**

## Estimated Timeline:
- **Setup**: 1-2 hours
- **First working version**: 1-2 days
- **Basic tax functionality**: 1-2 weeks
- **Production-ready**: 2-3 months 