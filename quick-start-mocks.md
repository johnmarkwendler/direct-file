# Quick Start Mocks

These are the essential files you need to create to bypass the missing authentication and MeF integration.

## 1. Mock Authentication Component

Create `df-client/df-client-app/src/auth/DevLogin.tsx`:

```tsx
import React, { useState } from 'react';
import { Button } from '@trussworks/react-uswds';

export const DevLogin: React.FC = () => {
  const [email, setEmail] = useState('dev@example.com');

  const handleLogin = () => {
    // Bypass real authentication for development
    sessionStorage.setItem('email', email);
    sessionStorage.setItem('authenticated', 'true');
    
    // Add some test data
    const testUuid = '00000000-0000-0000-0000-000000000001';
    localStorage.setItem('preauthUuid', testUuid);
    
    // Redirect to the app
    window.location.href = '/loading';
  };

  return (
    <div style={{ padding: '2rem', maxWidth: '400px', margin: '0 auto' }}>
      <h1>Direct File - Dev Mode</h1>
      <p>Development login bypass</p>
      
      <div style={{ marginBottom: '1rem' }}>
        <label htmlFor="email">Email:</label>
        <input
          id="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          style={{ width: '100%', padding: '0.5rem', margin: '0.5rem 0' }}
        />
      </div>
      
      <Button type="button" onClick={handleLogin}>
        Login (Dev Mode)
      </Button>
      
      <div style={{ marginTop: '2rem', fontSize: '0.875rem', color: '#666' }}>
        <p>This is a development-only login bypass.</p>
        <p>In production, this would integrate with SADI authentication.</p>
      </div>
    </div>
  );
};
```

## 2. Backend Authentication Bypass

Create `backend/src/main/java/gov/irs/directfile/api/config/DevAuthConfig.java`:

```java
package gov.irs.directfile.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
@Profile("development")
public class DevAuthConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors().and()
            .csrf().disable()
            .authorizeHttpRequests(authz -> authz
                .anyRequest().permitAll()  // Allow all requests in dev mode
            );
        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.addAllowedOriginPattern("*");
        configuration.addAllowedMethod("*");
        configuration.addAllowedHeader("*");
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

## 3. Mock MeF Controller

Create `backend/src/main/java/gov/irs/directfile/api/mock/MockSubmissionController.java`:

```java
package gov.irs.directfile.api.mock;

import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.UUID;
import java.time.LocalDateTime;

@RestController
@RequestMapping("/v1/taxreturns")
@Profile("development")
public class MockSubmissionController {

    @PostMapping("/{taxReturnId}/submit")
    public ResponseEntity<Map<String, Object>> submitTaxReturn(
            @PathVariable UUID taxReturnId,
            @RequestBody Map<String, Object> submissionData) {
        
        // Mock successful submission
        String confirmationNumber = "DF" + System.currentTimeMillis();
        
        return ResponseEntity.ok(Map.of(
            "status", "ACCEPTED",
            "confirmationNumber", confirmationNumber,
            "submissionId", UUID.randomUUID().toString(),
            "timestamp", LocalDateTime.now().toString(),
            "message", "Tax return submitted successfully (MOCK)"
        ));
    }

    @PostMapping("/{taxReturnId}/sign")
    public ResponseEntity<Map<String, Object>> signTaxReturn(
            @PathVariable UUID taxReturnId,
            @RequestBody Map<String, Object> signatureData) {
        
        return ResponseEntity.ok(Map.of(
            "status", "SIGNED",
            "signatureId", UUID.randomUUID().toString(),
            "timestamp", LocalDateTime.now().toString(),
            "message", "Tax return signed successfully (MOCK)"
        ));
    }
}
```

## 4. Simple Tax Calculation Mock

Create `backend/src/main/java/gov/irs/directfile/api/mock/MockTaxCalculator.java`:

```java
package gov.irs.directfile.api.mock;

import org.springframework.stereotype.Service;
import org.springframework.context.annotation.Profile;
import java.math.BigDecimal;
import java.util.Map;

@Service
@Profile("development")
public class MockTaxCalculator {

    public Map<String, Object> calculateTax(Map<String, Object> taxData) {
        // Very basic tax calculation for demo purposes
        BigDecimal income = new BigDecimal(taxData.getOrDefault("totalIncome", 0).toString());
        BigDecimal standardDeduction = new BigDecimal("13850"); // 2024 standard deduction
        
        BigDecimal taxableIncome = income.subtract(standardDeduction);
        if (taxableIncome.compareTo(BigDecimal.ZERO) < 0) {
            taxableIncome = BigDecimal.ZERO;
        }
        
        // Simple tax calculation (not real tax brackets)
        BigDecimal tax = taxableIncome.multiply(new BigDecimal("0.12"));
        
        BigDecimal withheld = new BigDecimal(taxData.getOrDefault("totalWithheld", 0).toString());
        BigDecimal refundOrOwed = withheld.subtract(tax);
        
        return Map.of(
            "totalIncome", income,
            "standardDeduction", standardDeduction,
            "taxableIncome", taxableIncome,
            "totalTax", tax,
            "totalWithheld", withheld,
            "refundOrOwed", refundOrOwed,
            "isRefund", refundOrOwed.compareTo(BigDecimal.ZERO) > 0
        );
    }
}
```

## 5. Frontend Route Update

Add to `df-client/df-client-app/src/App.tsx` (find the Routes section and add):

```tsx
// Add this route to your existing Routes
<Route 
  path="/dev-login" 
  element={<DevLogin />} 
/>
```

## 6. Environment Variables Override

Add to your `.env.local` file:

```env
# Development overrides
VITE_DEV_MODE=true
VITE_SKIP_AUTH=true
VITE_MOCK_SUBMISSION=true
```

## Usage Instructions

1. **First Time Setup:**
   ```bash
   # Copy these files to your project
   # Install dependencies
   cd df-client/df-client-app
   npm install
   ```

2. **Start Development:**
   ```bash
   # In direct-file directory
   .\start-dev.ps1
   ```

3. **Access the App:**
   - Go to http://localhost:3000/dev-login
   - Enter any email and click "Login (Dev Mode)"
   - You'll be redirected to the main app

4. **If Issues:**
   ```bash
   # Run troubleshooting
   .\troubleshoot.ps1
   ```

## What This Gets You

- ✅ Bypass authentication completely
- ✅ Mock tax calculation (basic)
- ✅ Mock submission workflow
- ✅ All existing UI components working
- ✅ Database persistence
- ✅ Ready for your custom development

## Next Steps

Once this is working:
1. Explore the existing fact graph system
2. Add more realistic tax calculations
3. Customize the UI flow
4. Add additional tax forms
5. Deploy to cloud when ready

This setup should get you from zero to a working tax filing system in under an hour! 