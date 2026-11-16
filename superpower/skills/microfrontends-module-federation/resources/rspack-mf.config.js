// Production Remote Microfrontend Configuration (Remote Component Exposer)
const { ModuleFederationPlugin } = require('@module-federation/enhanced/rspack');

module.exports = {
  output: {
    publicPath: 'auto',
  },
  plugins: [
    new ModuleFederationPlugin({
      name: 'checkout',
      filename: 'remoteEntry.js',
      exposes: {
        './CheckoutWidget': './src/components/CheckoutWidget.tsx',
      },
      shared: {
        react: { singleton: true, requiredVersion: '^18.3.0' },
        'react-dom': { singleton: true, requiredVersion: '^18.3.0' },
      },
    }),
  ],
};
