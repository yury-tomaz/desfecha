import { builtinRules } from 'eslint/use-at-your-own-risk';
import sonarjs from 'eslint-plugin-sonarjs';

const TODO_SEM_PLANO = /\b(TODO|FIXME)\b(?!\(\d{4}-\d{2}-\d{2}-[a-z0-9]+(?:-[a-z0-9]+)*\): )/;

function comMensagem(regra, mensagem, filtro = () => true) {
	return {
		meta: { ...regra.meta, messages: { sensor: mensagem } },
		create(context) {
			const reportados = new Set();
			const report = ({ node, loc }) => {
				if (!filtro(node) || reportados.has(node)) return;
				reportados.add(node);
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
			'TODO ou FIXME sem exec-plan. Escreva no formato TODO(<slug-do-plano>): texto, com o nome do arquivo do plano sem .md (ex.: TODO(2026-11-07-sensores-computacionais): ...), ou apague o comentário.',
			(comentario) => TODO_SEM_PLANO.test(comentario.value)
		)
	}
};
