// React Three Fiber Canvas Scene
import { Canvas } from '@react-three/fiber';
import { OrbitControls, Float } from '@react-three/drei';

export function Scene3D() {
  return (
    <Canvas camera={{ position: [0, 0, 5], fov: 45 }}>
      <ambientLight intensity={0.5} />
      <directionalLight position={[10, 10, 5]} />
      <Float speed={2} rotationIntensity={1}>
        <mesh>
          <boxGeometry args={[1, 1, 1]} />
          <meshStandardMaterial color="#6366f1" roughness={0.2} metalness={0.8} />
        </mesh>
      </Float>
      <OrbitControls enableZoom={false} />
    </Canvas>
  );
}
