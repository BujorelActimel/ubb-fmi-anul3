const serverConfig = require('./config.json');

export default ({ config }) => ({
  ...config,
  extra: {
    apiUrl: process.env.API_URL || serverConfig.serverUrl,
  },
  android: {
    ...config.android,
    config: {
      googleMaps: {
        apiKey: serverConfig.googleMapsApiKey,
      },
    },
  },
  plugins: [
    ...(config.plugins || []),
    "expo-sqlite"
  ],
});
