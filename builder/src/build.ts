#!/usr/bin/env node
import path from 'path';
import fs from 'fs';
import archiver from 'archiver';
import esbuild from 'esbuild';
import { options, projectPath, environment } from './common';

esbuild
  .build(options)
  .catch((error: {}) => {
    console.error(`Build error: ${error}`);
    process.exit(1);
  })
  .then((result: esbuild.BuildResult<typeof options>) => {
    // Prepare zip
    const outputPath = path.join(
      projectPath,
      'dist',
      `dist-${environment}.zip`,
    );
    const output = fs.createWriteStream(outputPath);
    const archive = archiver('zip', {
      zlib: { level: 9 },
    });
    output.on('close', () => {
      console.log(`Finished writing ${outputPath}`);
    });
    archive.on('error', (err) => {
      throw err;
    });
    archive.pipe(output);

    // Zip files in web/assets
    const webFiles = fs.readdirSync(path.join(projectPath, 'web/assets'));
    webFiles.forEach(function (file) {
      const src = path.join(projectPath, 'web/assets', file);
      archive.append(fs.createReadStream(src), {
        name: path.join('assets', file),
      });
    });

    // ZIP files in dist
    const distFiles = fs.readdirSync(path.join(projectPath, 'dist'));
    distFiles.forEach(function (file) {
      if (file.endsWith('.map')) return;
      const src = path.join(projectPath, 'dist', file);
      archive.append(fs.createReadStream(src), { name: file });
    });

    // Write ending to zip file
    archive.finalize();
  });
