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

      // [0] is js' source-map
      const jsFile = Object.keys(result.metafile.outputs)[1];
      if (!jsFile) {
        console.error('### Prepare error:', 'Unable to retrieve metafiles');
        process.exit(6);
      }
      const jsFinalPath = jsFile.replace('dist/', '/');

      // Copy HTML file to dist
      const htmlSrcPath = path.join(projectPath, 'web', 'index.html');
      const htmlDistPath = path.join(projectPath, 'dist', 'index.html');

      // Edit html files references to generated files
      console.log(`Reading ${htmlSrcPath}`);
      const data = fs.readFileSync(htmlSrcPath, { encoding: 'utf8' });
      console.log(`Writing ${htmlDistPath}`);
      fs.writeFileSync(
        htmlDistPath,
        data.replace('index.js', jsFinalPath),
        'utf8',
      );
    });
  },
});
