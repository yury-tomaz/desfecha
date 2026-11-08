import { builtinRules } from 'eslint/use-at-your-own-risk';
import sonarjs from 'eslint-plugin-sonarjs';

const TODO_SEM_PLANO = /\b(TODO|FIXME)\b(?!\(\d{4}-\d{2}-\d{2}-[a-z0-9]+(?:-[a-z0-9]+)*\): )/;

function comMensagem(regra, mensagem, filtro = () => true) {
	return {
		meta: { ...regra.meta, messages: { sensor: mensagem } },
		create(context) {
			const reportados = new Set();
			const report = ({ node, loc }) => {
				// O sonarjs reporta só com loc, sem node.
				const chave = node ?? `${loc.start.line}:${loc.start.column}`;
				if (!filtro(node) || reportados.has(chave)) return;
				reportados.add(chave);
				context.report({ node, loc, messageId: 'sensor' });
			};
			return regra.create(Object.create(context, { report: { value: report } }));
		}
	};
}

export default {
	rules: {
		'codigo-comentado': comMensagem(
			sonarjs.rules['no-commented-code'],
			'Código comentado. Apague: o histórico fica no git.'
		),
		// Só conta em maiúsculas: "todo" em minúsculas é palavra comum em português.
		'todo-sem-plano': comMensagem(
			builtinRules.get('no-warning-comments'),
			'TODO ou FIXME sem pitch. Escreva no formato TODO(<pasta-do-pitch>): texto, com o nome da pasta do pitch em docs/pitches (ex.: TODO(2026-11-08-sensores-de-teste): ...), ou apague o comentário.',
			(comentario) => TODO_SEM_PLANO.test(comentario.value)
		)
	}
};
