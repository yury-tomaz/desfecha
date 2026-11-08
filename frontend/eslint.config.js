import js from '@eslint/js';
import prettier from 'eslint-config-prettier';
import sonarjs from 'eslint-plugin-sonarjs';
import svelte from 'eslint-plugin-svelte';
import globals from 'globals';
import ts from 'typescript-eslint';
import sensores from './eslint-sensores.js';

export default ts.config(
	{ ignores: ['.svelte-kit/', '.stryker-tmp/', 'build/', 'node_modules/'] },
	js.configs.recommended,
	...ts.configs.recommended,
	...svelte.configs.recommended,
	prettier,
	...svelte.configs.prettier,
	{
		languageOptions: { globals: { ...globals.browser, ...globals.node } }
	},
	{
		files: ['**/*.svelte', '**/*.svelte.ts', '**/*.svelte.js'],
		languageOptions: { parserOptions: { parser: ts.parser, extraFileExtensions: ['.svelte'] } }
	},
	{
		plugins: { sensores, sonarjs },
		rules: {
			'sensores/codigo-comentado': 'error',
			'sensores/todo-sem-plano': ['error', { terms: ['todo', 'fixme'], location: 'anywhere' }]
		}
	}
);
