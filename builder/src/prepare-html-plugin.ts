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
      const jsFile = Object.keys(result.metafile.outputs)[1];
      const cssFile = Object.keys(result.metafile.outputs)[3];
      if (!jsFile || !cssFile) {
        console.error('### Prepare error:', 'Unable to retrieve metafiles');
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
