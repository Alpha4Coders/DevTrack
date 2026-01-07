import { useEffect, useState } from 'react';
import { useUser, useAuth, SignIn } from '@clerk/clerk-react';
import './MobileAuth.css';

/**
 * Mobile Auth Page
 * 
 * This page handles authentication for the Flutter mobile app.
 * Flow:
 * 1. User opens this page from the Flutter app
 * 2. Clerk sign-in modal appears
 * 3. User signs in with GitHub
 * 4. After success, this page redirects back to the Flutter app
 *    with the session token via deep link
 */
const MobileAuth = () => {
    const { isSignedIn, isLoaded: userLoaded } = useUser();
    const { getToken, isLoaded: authLoaded } = useAuth();
    const [status, setStatus] = useState('loading');
    const [error, setError] = useState(null);

    useEffect(() => {
        const handleAuth = async () => {
            // Wait for Clerk to load
            if (!userLoaded || !authLoaded) {
                return;
            }

            // If user is signed in, get the token and redirect
            if (isSignedIn) {
                setStatus('redirecting');

                try {
                    // Get the session token
                    const token = await getToken();

                    if (token) {
                        console.log('✅ Got session token, redirecting to app...');

                        // Redirect to Flutter app via deep link
                        const deepLinkUrl = `devtrack://auth/callback?token=${encodeURIComponent(token)}`;

                        // Also try the https scheme as fallback
                        // const httpsUrl = `https://devtrack-pwkj.onrender.com/mobile-callback?token=${encodeURIComponent(token)}`;

                        // Redirect to the app
                        window.location.href = deepLinkUrl;

                        // Show success message in case redirect is blocked
                        setTimeout(() => {
                            setStatus('success');
                        }, 2000);
                    } else {
                        setError('Failed to get session token');
                        setStatus('error');
                    }
                } catch (err) {
                    console.error('Error getting token:', err);
                    setError(err.message || 'Failed to get session token');
                    setStatus('error');
                }
            } else {
                // User is not signed in, show sign-in
                setStatus('signin');
            }
        };

        handleAuth();
    }, [isSignedIn, userLoaded, authLoaded, getToken]);

    // Loading state
    if (status === 'loading') {
        return (
            <div className="mobile-auth-container">
                <div className="mobile-auth-card">
                    <div className="loader"></div>
                    <h2>Loading...</h2>
                    <p>Preparing authentication...</p>
                </div>
            </div>
        );
    }

    // Show sign-in form
    if (status === 'signin') {
        return (
            <div className="mobile-auth-container">
                <div className="mobile-auth-header">
                    <img src="/DevTrack.png" alt="DevTrack" className="mobile-auth-logo" />
                    <h1>DevTrack</h1>
                    <p>Sign in to continue to the mobile app</p>
                </div>
                <div className="mobile-auth-signin">
                    <SignIn
                        afterSignInUrl="/mobile-auth"
                        appearance={{
                            elements: {
                                rootBox: 'clerk-root-box',
                                card: 'clerk-card',
                                headerTitle: 'clerk-header-title',
                                socialButtonsBlockButton: 'clerk-social-button',
                            }
                        }}
                    />
                </div>
            </div>
        );
    }

    // Redirecting state
    if (status === 'redirecting') {
        return (
            <div className="mobile-auth-container">
                <div className="mobile-auth-card">
                    <div className="loader"></div>
                    <h2>Success!</h2>
                    <p>Redirecting to DevTrack app...</p>
                    <p className="mobile-auth-hint">
                        If you're not redirected automatically,<br />
                        please open the DevTrack app manually.
                    </p>
                </div>
            </div>
        );
    }

    // Success state (shown if deep link doesn't work)
    if (status === 'success') {
        return (
            <div className="mobile-auth-container">
                <div className="mobile-auth-card success">
                    <div className="success-icon">✓</div>
                    <h2>Authentication Complete!</h2>
                    <p>You can now return to the DevTrack app.</p>
                    <button
                        className="mobile-auth-button"
                        onClick={async () => {
                            const token = await getToken();
                            if (token) {
                                window.location.href = `devtrack://auth/callback?token=${encodeURIComponent(token)}`;
                            }
                        }}
                    >
                        Open DevTrack App
                    </button>
                    <p className="mobile-auth-hint">
                        If the button doesn't work, copy your session token manually<br />
                        from the web dashboard.
                    </p>
                </div>
            </div>
        );
    }

    // Error state
    if (status === 'error') {
        return (
            <div className="mobile-auth-container">
                <div className="mobile-auth-card error">
                    <div className="error-icon">✕</div>
                    <h2>Authentication Failed</h2>
                    <p>{error || 'An error occurred during authentication.'}</p>
                    <button
                        className="mobile-auth-button"
                        onClick={() => window.location.reload()}
                    >
                        Try Again
                    </button>
                </div>
            </div>
        );
    }

    return null;
};

export default MobileAuth;
