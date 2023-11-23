import EnvPlugin, { getGitDescribe } from './env-plugin';
import PrepareHtmlPlugin from './prepare-html-plugin';
import ElmPlugin from 'esbuild-plugin-elm';
import { Loader } from 'esbuild';

const projectPath = process.env.DEVENV_ROOT ?? process.cwd();
const _gitDescribe = getGitDescribe(); // Adds it (when missing) to GIT_DESCRIBE
const environment = process.env.APP_ENV ?? 'development';

const loader: { [ext: string]: Loader } = {
  '.svg': 'text',
  '.png': 'file',
  '.jpg': 'file',
};

const options = {
  target: ['es2021'],
  entryPoints: ['web/js/index.js'],
  outdir: 'dist',
  entryNames: '[dir]/[name]-[hash]',
  assetNames: 'assets/[name]',
  allowOverwrite: true,
  bundle: true,
  metafile: true,
  minify: environment === 'production',
  sourcemap: true,
  loader,
  plugins: [
    EnvPlugin(),
    ElmPlugin(
      environment !== 'development'
        ? { pathToElm: 'env-elmlvl2-wrapper' }
        : { debug: true },
    ),
    PrepareHtmlPlugin(projectPath),
  ],
};

export { options, projectPath, environment };
