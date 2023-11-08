import path from 'path';
import fs from 'fs';
import { PluginBuild } from 'esbuild';

export default (projectPath: string) => ({
  name: 'prepare-html',
  setup(build: PluginBuild) {
    build.onEnd((result) => {
      if (!result.metafile) {
        console.error('### Prepare error:', 'Missing metafile');
        process.exit(5);
      }

      // [0] is js' source-map, [2] is css' source-map
      const jsMeta = Object.entries(result.metafile.outputs).find(
        ([_k, v]) => (v.entryPoint ?? '') == 'web/js/index.js',
      );
      if (!jsMeta) {
        console.error('### Prepare error:', 'Unable to retrieve JS metafile');
        process.exit(6);
      }
      const jsFile = jsMeta[0];
      const cssFile = jsMeta[1].cssBundle;
      if (!cssFile) {
        console.error('### Prepare error:', 'Unable to retrieve CSS filename');
        process.exit(6);
      }
      const jsFinalPath = jsFile.replace('dist/', '/');
      const cssFinalPath = cssFile.replace('dist/', '/');

      // Copy HTML file to dist
      const htmlSrcPath = path.join(projectPath, 'web', 'index.html');
      const htmlDistPath = path.join(projectPath, 'dist', 'index.html');

      // Edit html files references to generated files
      console.log(`Reading ${htmlSrcPath}`);
      const data = fs.readFileSync(htmlSrcPath, { encoding: 'utf8' });
      console.log(`Writing ${htmlDistPath}`);
      fs.writeFileSync(
        htmlDistPath,
        data
          .replace('index.js', jsFinalPath)
          .replace('index.css', cssFinalPath),
        'utf8',
      );
    });
  },
});
