import _ from 'lodash';
import { PluginBuild } from 'esbuild';

export const getGitDescribe = (): string => {
  if (process.env.GIT_DESCRIBE) return process.env.GIT_DESCRIBE;

  const exec = require('child_process').execSync;
  const stdout = exec('git describe --always --tags --dirty=+');
  const result = stdout.toString().split('\n', 1)[0];

  process.env.GIT_DESCRIBE = result;
  return result;
};

export default (gitDescribe: string) => ({
  name: 'env',
  async setup(build: PluginBuild) {
    const options = build.initialOptions;

    options.define = Object.entries(process.env).reduce(
      (accu, [key, value]): Record<string, string> => {
        return { ...accu, [`env_${key}`]: JSON.stringify(value) };
      },
      options.define || {},
    );
  },
});
