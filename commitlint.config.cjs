module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'fix', 'feat', 'docs', 'ci', 'chore', 'test', 'refactor', 'style', 'perf', 'build', 'revert',
      'Fix', 'Feat', 'Docs', 'Ci', 'Chore', 'Test', 'Refactor', 'Style', 'Perf', 'Build', 'Revert' 
      ]],
    'header-max-length': [2, 'always', 150],
    'subject-case': [0],
    'type-case': [0],
  }
};