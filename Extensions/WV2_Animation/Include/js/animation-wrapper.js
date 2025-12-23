// ===============================================================================================================================
// WV2 Animation Wrapper - Anime.js Integration for AutoIt WebView2
// Version: 1.0.0
// Author: Ralle1976
// ===============================================================================================================================
//
// This module provides a clean interface between AutoIt and Anime.js animations.
// It manages timelines, active animations, and provides simplified methods for common tasks.
//
// ===============================================================================================================================

const WV2Anim = {
    // Animation tracking
    timelines: new Map(),
    activeAnimations: [],
    animationCounter: 0,

    // Initialize
    init: function() {
        console.log('WV2 Animation Wrapper initialized');
        console.log('Anime.js version:', anime.version);
    },

    // Simple animation (basic properties)
    animate: function(selector, props, duration = 1000, easing = 'easeOutQuad') {
        try {
            const targets = document.querySelectorAll(selector);
            if (targets.length === 0) {
                console.warn('No elements found for selector:', selector);
                return null;
            }

            const config = {
                targets: selector,
                duration: duration,
                easing: easing,
                ...props
            };

            const anim = anime(config);
            this.activeAnimations.push({
                id: ++this.animationCounter,
                selector: selector,
                animation: anim
            });

            console.log('Animation started:', selector, props);
            return anim;
        } catch (error) {
            console.error('Animation error:', error);
            return null;
        }
    },

    // Extended animation (full Anime.js options)
    animateEx: function(selector, options) {
        try {
            const targets = document.querySelectorAll(selector);
            if (targets.length === 0) {
                console.warn('No elements found for selector:', selector);
                return null;
            }

            const config = {
                targets: selector,
                ...options
            };

            const anim = anime(config);
            this.activeAnimations.push({
                id: ++this.animationCounter,
                selector: selector,
                animation: anim
            });

            console.log('Extended animation started:', selector);
            return anim;
        } catch (error) {
            console.error('Extended animation error:', error);
            return null;
        }
    },

    // Create timeline
    createTimeline: function(id, autoplay = true) {
        try {
            const timeline = anime.timeline({
                autoplay: autoplay,
                easing: 'easeOutExpo',
                duration: 750
            });

            this.timelines.set(id, timeline);
            console.log('Timeline created:', id, 'autoplay:', autoplay);
            return timeline;
        } catch (error) {
            console.error('Timeline creation error:', error);
            return null;
        }
    },

    // Add animation to timeline
    timelineAdd: function(id, selector, props, duration, easing, offset) {
        try {
            const timeline = this.timelines.get(id);
            if (!timeline) {
                console.warn('Timeline not found:', id);
                return false;
            }

            const config = {
                targets: selector,
                duration: duration,
                easing: easing,
                ...props
            };

            timeline.add(config, offset);
            console.log('Added to timeline:', id, selector);
            return true;
        } catch (error) {
            console.error('Timeline add error:', error);
            return false;
        }
    },

    // Timeline controls
    timelinePlay: function(id) {
        const timeline = this.timelines.get(id);
        if (timeline) {
            timeline.play();
            console.log('Timeline playing:', id);
            return true;
        }
        return false;
    },

    timelinePause: function(id) {
        const timeline = this.timelines.get(id);
        if (timeline) {
            timeline.pause();
            console.log('Timeline paused:', id);
            return true;
        }
        return false;
    },

    timelineRestart: function(id) {
        const timeline = this.timelines.get(id);
        if (timeline) {
            timeline.restart();
            console.log('Timeline restarted:', id);
            return true;
        }
        return false;
    },

    timelineReverse: function(id) {
        const timeline = this.timelines.get(id);
        if (timeline) {
            timeline.reverse();
            console.log('Timeline reversed:', id);
            return true;
        }
        return false;
    },

    // Staggered animation
    stagger: function(selector, props, delayValue, duration, easing) {
        try {
            const targets = document.querySelectorAll(selector);
            if (targets.length === 0) {
                console.warn('No elements found for stagger:', selector);
                return null;
            }

            const config = {
                targets: selector,
                duration: duration,
                easing: easing,
                delay: anime.stagger(delayValue),
                ...props
            };

            const anim = anime(config);
            this.activeAnimations.push({
                id: ++this.animationCounter,
                selector: selector,
                animation: anim
            });

            console.log('Stagger animation started:', selector, 'elements:', targets.length);
            return anim;
        } catch (error) {
            console.error('Stagger animation error:', error);
            return null;
        }
    },

    // Stop animation for specific selector
    stop: function(selector) {
        let stopped = 0;
        this.activeAnimations = this.activeAnimations.filter(item => {
            if (item.selector === selector) {
                item.animation.pause();
                stopped++;
                return false;
            }
            return true;
        });
        console.log('Stopped animations for:', selector, 'count:', stopped);
    },

    // Stop all animations
    stopAll: function() {
        console.log('Stopping all animations...');
        this.activeAnimations.forEach(item => {
            item.animation.pause();
        });
        this.activeAnimations = [];

        this.timelines.forEach((timeline, id) => {
            timeline.pause();
        });
        console.log('All animations stopped');
    },

    // Helper: Create animated element
    createAnimatedElement: function(type, id, styles = {}) {
        const element = document.createElement(type);
        element.id = id;
        Object.assign(element.style, styles);
        return element;
    },

    // Helper: SVG path drawing animation
    drawPath: function(pathSelector, duration = 2000, easing = 'easeInOutSine') {
        try {
            const path = document.querySelector(pathSelector);
            if (!path) {
                console.warn('SVG path not found:', pathSelector);
                return null;
            }

            const pathLength = path.getTotalLength();
            path.style.strokeDasharray = pathLength;
            path.style.strokeDashoffset = pathLength;

            const anim = anime({
                targets: pathSelector,
                strokeDashoffset: [pathLength, 0],
                duration: duration,
                easing: easing
            });

            this.activeAnimations.push({
                id: ++this.animationCounter,
                selector: pathSelector,
                animation: anim
            });

            console.log('Path drawing started:', pathSelector);
            return anim;
        } catch (error) {
            console.error('Path drawing error:', error);
            return null;
        }
    },

    // Helper: Morph between two SVG paths
    morphPath: function(pathSelector, targetPath, duration = 1500, easing = 'easeInOutQuad') {
        try {
            const anim = anime({
                targets: pathSelector,
                d: [{ value: targetPath }],
                duration: duration,
                easing: easing
            });

            this.activeAnimations.push({
                id: ++this.animationCounter,
                selector: pathSelector,
                animation: anim
            });

            console.log('Path morphing started:', pathSelector);
            return anim;
        } catch (error) {
            console.error('Path morphing error:', error);
            return null;
        }
    },

    // Helper: Animate counter/number
    animateNumber: function(elementSelector, from, to, duration = 1000, decimals = 0) {
        try {
            const element = document.querySelector(elementSelector);
            if (!element) {
                console.warn('Element not found for number animation:', elementSelector);
                return null;
            }

            const obj = { value: from };
            const anim = anime({
                targets: obj,
                value: to,
                duration: duration,
                easing: 'easeOutExpo',
                round: decimals === 0 ? 1 : Math.pow(10, decimals),
                update: function() {
                    element.textContent = obj.value.toFixed(decimals);
                }
            });

            console.log('Number animation started:', elementSelector, from, '->', to);
            return anim;
        } catch (error) {
            console.error('Number animation error:', error);
            return null;
        }
    },

    // Helper: Shake animation
    shake: function(selector, intensity = 10, duration = 500) {
        return this.animateEx(selector, {
            translateX: [
                { value: intensity, duration: duration / 8 },
                { value: -intensity, duration: duration / 8 },
                { value: intensity / 2, duration: duration / 8 },
                { value: -intensity / 2, duration: duration / 8 },
                { value: 0, duration: duration / 2 }
            ],
            easing: 'easeInOutQuad'
        });
    },

    // Helper: Pulse animation
    pulse: function(selector, scale = 1.1, duration = 600) {
        return this.animateEx(selector, {
            scale: [1, scale, 1],
            duration: duration,
            easing: 'easeInOutQuad'
        });
    },

    // Helper: Bounce animation
    bounce: function(selector, height = 50, duration = 1000) {
        return this.animateEx(selector, {
            translateY: [
                { value: -height, duration: duration / 2, easing: 'easeOutQuad' },
                { value: 0, duration: duration / 2, easing: 'easeInQuad' }
            ]
        });
    },

    // Helper: Fade in
    fadeIn: function(selector, duration = 600) {
        const element = document.querySelector(selector);
        if (element) element.style.opacity = '0';

        return this.animate(selector, {
            opacity: [0, 1]
        }, duration, 'easeOutQuad');
    },

    // Helper: Fade out
    fadeOut: function(selector, duration = 600) {
        return this.animate(selector, {
            opacity: [1, 0]
        }, duration, 'easeInQuad');
    },

    // Helper: Slide in from left
    slideInLeft: function(selector, distance = 100, duration = 800) {
        const element = document.querySelector(selector);
        if (element) {
            element.style.opacity = '0';
            element.style.transform = 'translateX(-' + distance + 'px)';
        }

        return this.animate(selector, {
            translateX: ['-' + distance + 'px', '0px'],
            opacity: [0, 1]
        }, duration, 'easeOutExpo');
    },

    // Helper: Slide in from right
    slideInRight: function(selector, distance = 100, duration = 800) {
        const element = document.querySelector(selector);
        if (element) {
            element.style.opacity = '0';
            element.style.transform = 'translateX(' + distance + 'px)';
        }

        return this.animate(selector, {
            translateX: [distance + 'px', '0px'],
            opacity: [0, 1]
        }, duration, 'easeOutExpo');
    },

    // Helper: Rotate continuously
    rotateContinuous: function(selector, duration = 2000, direction = 1) {
        return this.animateEx(selector, {
            rotate: direction > 0 ? '+=360' : '-=360',
            duration: duration,
            easing: 'linear',
            loop: true
        });
    },

    // Cleanup
    destroy: function() {
        this.stopAll();
        this.timelines.clear();
        console.log('WV2Anim destroyed');
    }
};

// Auto-initialize when Anime.js is loaded
if (typeof anime !== 'undefined') {
    WV2Anim.init();
} else {
    console.error('Anime.js not loaded!');
}

// ===============================================================================================================================
// End of animation-wrapper.js
// ===============================================================================================================================
