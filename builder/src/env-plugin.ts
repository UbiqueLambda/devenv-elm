import { PluginBuild } from 'esbuild';
import { execSync } from 'child_process';

export const getGitDescribe = (): string => {
  if (process.env.GIT_DESCRIBE) return process.env.GIT_DESCRIBE;

  const stdout = execSync('git describe --always --tags --dirty=+');
  const result = stdout.toString().split('\n', 1)[0] || '';

  process.env.GIT_DESCRIBE = result;
  return result;
};

export default () => ({
  name: 'env',
  setup(build: PluginBuild) {
    const options = build.initialOptions;

    options.define = Object.entries(process.env).reduce(
      (accu, [key, value]): Record<string, string> => {
        return { ...accu, [`env_${key}`]: JSON.stringify(value) };
      },
      options.define || {},
    );
  },
});
