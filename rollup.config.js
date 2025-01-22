import resolve from "@rollup/plugin-node-resolve"
import commonjs from '@rollup/plugin-commonjs';

export default {
  input: "app/javascript/application.js",
  output: {
    file: "app/assets/builds/application.js",
    format: "esm",
    inlineDynamicImports: true,
    sourcemap: true,
   	globals : {}
  },
  plugins: [
    resolve({
      // Remove after https://github.com/projectblacklight/blacklight-gallery/pull/176
      modulePaths: ['node_modules/blacklight-gallery/app/assets/javascripts/blacklight_gallery']
    }),
    commonjs()
  ],
  external: []
}
