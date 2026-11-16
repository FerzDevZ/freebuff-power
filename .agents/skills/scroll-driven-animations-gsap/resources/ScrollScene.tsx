import { useEffect, useRef } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
gsap.registerPlugin(ScrollTrigger);

export function ScrollScene() {
  const ref = useRef(null);
  useEffect(() => {
    gsap.to(ref.current, {
      scrollTrigger: { trigger: ref.current, start: 'top center', end: 'bottom top', scrub: 1 },
      scale: 1.2, opacity: 1
    });
  }, []);
  return <div ref={ref} className="h-screen flex items-center justify-center">Scroll Animation</div>;
}
