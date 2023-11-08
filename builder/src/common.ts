import path from 'path';
import EnvPlugin, { getGitDescribe } from './env-plugin';
import PrepareHtmlPlugin from './prepare-html-plugin';
import ElmPlugin from 'esbuild-plugin-elm';

const projectPath = process.env.DEVENV_ROOT ?? process.cwd();
const gitDescribe = getGitDescribe();

// Update it here and "src/env.ts"
const environment = process.env.APP_ENV ?? 'development';

const options = {
  target: ['es2021'],
  entryPoints: ['web/js/index.js'],
  outdir: 'dist',
  entryNames: '[dir]/[name]-[hash]',
  allowOverwrite: true,
  bundle: true,
  metafile: true,
  minify: environment === 'production',
  sourcemap: true,
  plugins: [
    EnvPlugin(gitDescribe),
    ElmPlugin({ pathToElm: 'env-elmlvl2-wrapper' }),
    PrepareHtmlPlugin(projectPath),
  ],
};

export { options, projectPath, environment };
