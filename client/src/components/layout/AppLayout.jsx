import { Outlet, useLocation } from 'react-router-dom'
import { useEffect, useRef, useState } from 'react'
import { useAuth } from '@clerk/clerk-react'
import { motion, AnimatePresence } from 'framer-motion'
import Navbar from './Navbar'
import { authApi } from '../../services/api'

// Page transition overlay component
function PageTransition({ isTransitioning }) {
    return (
        <AnimatePresence>
            {isTransitioning && (
                <motion.div
                    className="fixed inset-0 z-50 flex items-center justify-center pointer-events-none"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    transition={{ duration: 0.3 }}
                >
                    {/* Translucent backdrop with blur */}
                    <motion.div
                        className="absolute inset-0"
                        style={{
                            background: 'rgba(10, 15, 30, 0.85)',
                            backdropFilter: 'blur(8px)',
                        }}
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                    />

                    {/* Stitching pattern overlay */}
                    <motion.div
                        className="absolute inset-0 opacity-10"
                        style={{
                            backgroundImage: `repeating-linear-gradient(
                                0deg,
                                transparent,
                                transparent 20px,
                                rgba(34, 211, 238, 0.1) 20px,
                                rgba(34, 211, 238, 0.1) 21px
                            ), repeating-linear-gradient(
                                90deg,
                                transparent,
                                transparent 20px,
                                rgba(168, 85, 247, 0.1) 20px,
                                rgba(168, 85, 247, 0.1) 21px
                            )`,
                        }}
                    />

                    {/* Floating loading text */}
                    <motion.div
                        className="relative z-10 flex flex-col items-center gap-4"
                        initial={{ y: 20, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        exit={{ y: -20, opacity: 0 }}
                        transition={{ delay: 0.1, duration: 0.3 }}
                    >
                        {/* Wave loading text - each letter animates in sequence */}
                        <div className="flex items-center gap-1">
                            {"Loading".split('').map((letter, i) => (
                                <motion.span
                                    key={i}
                                    className="text-2xl font-bold bg-gradient-to-r from-cyan-400 via-purple-400 to-pink-400 bg-clip-text text-transparent"
                                    animate={{
                                        y: [0, -15, 0],
                                        scale: [1, 1.1, 1],
                                    }}
                                    transition={{
                                        duration: 0.8,
                                        repeat: Infinity,
                                        delay: i * 0.1,
                                        ease: "easeInOut",
                                    }}
                                >
                                    {letter}
                                </motion.span>
                            ))}
                            {/* Animated dots */}
                            {[0, 1, 2].map((i) => (
                                <motion.span
                                    key={`dot-${i}`}
                                    className="text-2xl font-bold text-purple-400"
                                    animate={{
                                        y: [0, -15, 0],
                                        opacity: [0.3, 1, 0.3],
                                    }}
                                    transition={{
                                        duration: 0.8,
                                        repeat: Infinity,
                                        delay: (7 + i) * 0.1,
                                        ease: "easeInOut",
                                    }}
                                >
                                    .
                                </motion.span>
                            ))}
                        </div>

                        {/* Subtitle with shimmer effect */}
                        <motion.div
                            className="text-sm text-slate-400 mt-2"
                            animate={{
                                opacity: [0.5, 1, 0.5],
                            }}
                            transition={{
                                duration: 2,
                                repeat: Infinity,
                                ease: "easeInOut",
                            }}
                        >
                            Preparing your workspace
                        </motion.div>
                    </motion.div>

                    {/* Glow effects */}
                    <motion.div
                        className="absolute w-64 h-64 rounded-full opacity-20"
                        style={{
                            background: 'radial-gradient(circle, rgba(34, 211, 238, 0.4) 0%, transparent 70%)',
                            filter: 'blur(40px)',
                        }}
                        animate={{
                            scale: [1, 1.2, 1],
                            x: [-50, 50, -50],
                        }}
                        transition={{
                            duration: 3,
                            repeat: Infinity,
                            ease: "easeInOut",
                        }}
                    />
                    <motion.div
                        className="absolute w-48 h-48 rounded-full opacity-20"
                        style={{
                            background: 'radial-gradient(circle, rgba(168, 85, 247, 0.4) 0%, transparent 70%)',
                            filter: 'blur(40px)',
                        }}
                        animate={{
                            scale: [1.2, 1, 1.2],
                            x: [50, -50, 50],
                        }}
                        transition={{
                            duration: 3,
                            repeat: Infinity,
                            ease: "easeInOut",
                        }}
                    />
                </motion.div>
            )}
        </AnimatePresence>
    )
}

export default function AppLayout() {
    const { isSignedIn } = useAuth()
    const hasSynced = useRef(false)
    const location = useLocation()
    const [isTransitioning, setIsTransitioning] = useState(false)
    const prevPathRef = useRef(location.pathname)
    const transitionLockRef = useRef(false) // Prevent double transitions from StrictMode

    // Sync user data from Clerk to Firestore on first load
    useEffect(() => {
        if (isSignedIn && !hasSynced.current) {
            hasSynced.current = true
            authApi.sync()
                .then(() => console.log('✅ User synced to Firestore'))
                .catch(err => console.warn('⚠️ User sync:', err.message))
        }
    }, [isSignedIn])

    // Handle page transitions - with guard against double-firing
    useEffect(() => {
        if (prevPathRef.current !== location.pathname && !transitionLockRef.current) {
            transitionLockRef.current = true
            setIsTransitioning(true)
            prevPathRef.current = location.pathname

            // Hide transition after a short delay
            const timer = setTimeout(() => {
                setIsTransitioning(false)
                transitionLockRef.current = false
            }, 400)

            return () => clearTimeout(timer)
        }
    }, [location.pathname])

    return (
        <div className="min-h-screen bg-dark-950">
            <PageTransition isTransitioning={isTransitioning} />
            <Navbar />
            <main className="max-w-7xl mx-auto px-6 py-8">
                <AnimatePresence mode="wait">
                    <motion.div
                        key={location.pathname}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -10 }}
                        transition={{ duration: 0.3 }}
                    >
                        <Outlet />
                    </motion.div>
                </AnimatePresence>
            </main>
        </div>
    )
}
