package com.corplab.usermanagement.service;

import com.corplab.usermanagement.dto.LoginRequest;
import com.corplab.usermanagement.dto.LoginResponse;
import com.corplab.usermanagement.dto.UserResponse;
import com.corplab.usermanagement.entity.User;
import com.corplab.usermanagement.exception.InvalidCredentialsException;
import com.corplab.usermanagement.exception.UnauthorizedException;
import com.corplab.usermanagement.repository.UserRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Requirement 1.B.3: UserService
 * Contains core business logic for authentication, BCrypt verification,
 * and HTTP session management.
 */
@Service
public class UserService {

    private static final String USER_SESSION_KEY = "LOGGED_IN_USER";

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Authenticates a user by username or email and validates BCrypt password.
     */
    public LoginResponse authenticate(LoginRequest request, HttpSession session) {
        // 1. Find user by either username or email
        User user = userRepository.findByUsernameOrEmail(request.getUsernameOrEmail().trim())
                .orElseThrow(() -> new InvalidCredentialsException("Invalid username/email or password."));

        // 2. Validate password using BCrypt password encoder
        boolean passwordMatches = passwordEncoder.matches(request.getPassword(), user.getPassword());
        if (!passwordMatches) {
            throw new InvalidCredentialsException("Invalid username/email or password.");
        }

        // 3. Establish authenticated session on backend (Challenge 4.5)
        UserResponse userResponse = new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole()
        );
        session.setAttribute(USER_SESSION_KEY, userResponse);

        return new LoginResponse(true, "Login successful! Redirecting to dashboard...", userResponse);
    }

    /**
     * Challenge 4.6: Protect dashboard data by verifying backend session.
     */
    public UserResponse getDashboardUser(HttpSession session) {
        Object userObj = session.getAttribute(USER_SESSION_KEY);
        if (userObj == null) {
            throw new UnauthorizedException("Unauthorized access. Please log in first.");
        }
        return (UserResponse) userObj;
    }

    /**
     * Challenge 4.4: Invalidate user session upon logout.
     */
    public void logout(HttpSession session) {
        session.removeAttribute(USER_SESSION_KEY);
        session.invalidate();
    }
}
