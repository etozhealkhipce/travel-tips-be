import { mergeConfig, type UserConfig } from 'vite';

export default (config: UserConfig) => {
  // Important: always return the modified config
  return mergeConfig(config, {
    base: '/strapi/admin',
    resolve: {
      alias: {
        '@': '/src',
      },
    },
  });
};
