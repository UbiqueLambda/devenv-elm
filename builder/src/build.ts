#!/usr/bin/env node
import path from 'path';
import fs from 'fs';
import archiver from 'archiver';
import esbuild from 'esbuild';
import { options, projectPath, environment } from './common';

esbuild
  .build(options)
  .catch((error) => {
    console.error('### Build error:', error);
    process.exit(1);
  })
  .then((_result: esbuild.BuildResult<typeof options>) => {
    // Prepare zip
    const outputPath = path.join(projectPath, `dist-${environment}.zip`);
    const output = fs.createWriteStream(outputPath);
    const archive = archiver('zip', {
      zlib: { level: 9 },
    });
    output.on('close', () => {
      console.log(`Finished writing ${outputPath}`);
    });
    archive.on('error', (error) => {
      console.error('### Archive pipe error:', error);
      process.exit(2);
    });
    archive.pipe(output);

    // ZIP files in dist
    const distFilesPath = path.join(projectPath, 'dist');
    archive.directory(distFilesPath, '.');

    // Write ending to zip file
    console.log('Nothing left to loose.');
    archive.finalize().catch((error) => {
      console.error('### Archive finalize error:', error);
      process.exit(3);
    });
  })
  .catch((error) => {
    console.error('### Post build error:', error);
    process.exit(4);
  });
