import resolve from "@rollup/plugin-node-resolve"
import commonjs from '@rollup/plugin-commonjs';
export default {
  input: "app/javascript/application.js",
  output: {
    file: "app/assets/builds/application.js",
    format: "esm",
    inlineDynamicImports: true,
    sourcemap: true,
   	globals : {
      // clipboard: 'Clipboard'
    }
  },
  plugins: [
    resolve(),
    commonjs()
  ],
  external: [
    // 'jquery' //,
    // 'clipboard'
  ]
}
