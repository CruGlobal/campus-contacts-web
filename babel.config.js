module.exports = api => {
    const isTest = api.env('test');
    return {
        presets: ['@babel/preset-env'],
        plugins: [
            '@babel/plugin-transform-runtime',
            '@babel/plugin-syntax-dynamic-import',
            '@babel/plugin-transform-template-literals',
            ...(!isTest ? ['angularjs-annotate'] : []),
        ],
    };
};
