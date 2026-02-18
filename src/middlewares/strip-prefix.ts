/**
 * `strip-prefix` middleware
 * Strips the /strapi prefix from incoming requests so that
 * Strapi's internal routes (/api/*, /admin/*, /_health, etc.) match correctly.
 *
 * Traefik forwards requests as-is: /strapi/api/places → /strapi/api/places
 * This middleware rewrites:       /strapi/api/places → /api/places
 */
export default () => {
  return async (ctx, next) => {
    if (ctx.url.startsWith('/strapi')) {
      ctx.url = ctx.url.replace(/^\/strapi/, '') || '/';
    }
    await next();
  };
};
