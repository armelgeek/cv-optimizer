import { config } from '@repo/next-config';
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  ...config,
  transpilePackages: [],
};

export default nextConfig;
