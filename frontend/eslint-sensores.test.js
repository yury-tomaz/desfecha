import { describe, it } from 'node:test';
import { RuleTester } from 'eslint';
import ts from 'typescript-eslint';
import sensores from './eslint-sensores.js';

RuleTester.describe = describe;
RuleTester.it = it;

// O sonarjs analisa o texto do comentário com o parser configurado; sem ele, não reporta nada.
const tester = new RuleTester({ languageOptions: { parser: ts.parser } });
const opcoesTodo = [{ terms: ['todo', 'fixme'], location: 'anywhere' }];

tester.run('codigo-comentado', sensores.rules['codigo-comentado'], {
	valid: ['// Os horários vêm em UTC porque o fornecedor não manda fuso.\nconst a = 1;'],
	invalid: [
		{
			code: '// const a = 1;\nconst x = 0;\n\n// const b = 2;\nconst y = 0;',
			errors: [
				{ messageId: 'sensor', line: 1 },
				{ messageId: 'sensor', line: 4 }
			]
		}
	]
});

tester.run('todo-sem-plano', sensores.rules['todo-sem-plano'], {
	valid: [
		{ code: '// TODO(2026-11-07-sensores-computacionais): ligar o alerta', options: opcoesTodo },
		{ code: '// FIXME(2026-11-07-sensores-computacionais): trocar o nome', options: opcoesTodo },
		{ code: '// Isso vale para o todo do pedido.', options: opcoesTodo }
	],
	invalid: [
		{ code: '// TODO: arrumar', options: opcoesTodo, errors: [{ messageId: 'sensor' }] },
		{ code: '// FIXME ver depois', options: opcoesTodo, errors: [{ messageId: 'sensor' }] },
		{
			code: '// TODO(sensores): sem data',
			options: opcoesTodo,
			errors: [{ messageId: 'sensor' }]
		},
		{
			code: '// TODO(2026-11-07-sensores-computacionais) sem dois pontos',
			options: opcoesTodo,
			errors: [{ messageId: 'sensor' }]
		},
		{
			code: '// TODO: um\n// TODO: dois',
			options: opcoesTodo,
			errors: [
				{ messageId: 'sensor', line: 1 },
				{ messageId: 'sensor', line: 2 }
			]
		}
	]
});
