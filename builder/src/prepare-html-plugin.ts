import path from 'path';
import fs from 'fs';
import { PluginBuild } from 'esbuild';

export default (projectPath: string) => ({
  name: 'prepare-html',
  async setup(build: PluginBuild) {
    build.onEnd((result) => {
      if (!result.metafile) {
        throw 'Missing metafile';
      }

      // [0] is js' source-map
      const jsFile = Object.keys(result.metafile.outputs)[1];

      if (!jsFile) {
        throw 'Unable to retrieve metafiles';
      }

      // Copy HTML file to dist
      const htmlSrcPath = path.join(projectPath, 'web', 'index.html');
      const htmlDistPath = path.join(projectPath, 'dist', 'index.html');

      // Edit html files references to generated files
      fs.readFile(htmlSrcPath, 'utf8', (err, data) => {
        if (err) return console.error(err);

        const jsFinalPath = jsFile.replace('dist/', '/');

        fs.writeFileSync(
          htmlDistPath,
          data.replace('index.js', jsFinalPath),
          'utf8',
        );
      });
    });
  },
});
