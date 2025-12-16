import { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useUser } from '@clerk/clerk-react';
import { preferencesApi } from '../../services/api';

/**
 * OnboardingCheck Component
 * Checks if user has completed onboarding and redirects if needed
 */
const OnboardingCheck = ({ children }) => {
    const { isSignedIn, isLoaded } = useUser();
    const navigate = useNavigate();
    const location = useLocation();
    const [checking, setChecking] = useState(true);
    const [shouldRedirect, setShouldRedirect] = useState(false);

    useEffect(() => {
        const checkOnboarding = async () => {
            // Skip if not signed in or still loading
            if (!isLoaded || !isSignedIn) {
                setChecking(false);
                return;
            }

            // Skip if already on onboarding page
            if (location.pathname === '/onboarding') {
                setChecking(false);
                return;
            }

            try {
                const response = await preferencesApi.get();
                const onboardingCompleted = response.data?.data?.onboardingCompleted;

                if (!onboardingCompleted) {
                    console.log('Onboarding not completed, redirecting...');
                    setShouldRedirect(true);
                    navigate('/onboarding', { replace: true });
                }
            } catch (error) {
                // Only redirect to onboarding if preferences explicitly don't exist (404)
                // For other errors (network, auth), just continue to dashboard
                if (error.response?.status === 404) {
                    console.log('No preferences found, redirecting to onboarding');
                    setShouldRedirect(true);
                    navigate('/onboarding', { replace: true });
                } else {
                    // Log but don't redirect for other errors (network issues, etc.)
                    console.warn('Error checking onboarding status (continuing to dashboard):', error.message);
                }
            } finally {
                setChecking(false);
            }
        };

        checkOnboarding();
    }, [isSignedIn, isLoaded, navigate, location.pathname]);

    // Show loading while checking
    if (checking && isSignedIn) {
        return (
            <div className="min-h-screen bg-slate-950 flex items-center justify-center">
                <div className="flex flex-col items-center gap-4">
                    <div className="animate-spin h-8 w-8 border-4 border-purple-500 border-t-transparent rounded-full"></div>
                    <p className="text-slate-400">Loading your preferences...</p>
                </div>
            </div>
        );
    }

    // Don't render children if redirecting
    if (shouldRedirect) {
        return null;
    }

    return children;
};

export default OnboardingCheck;
