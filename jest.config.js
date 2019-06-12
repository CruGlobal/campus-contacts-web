module.exports = {
    roots: ['src/'],
    setupFiles: ['./src/setupTests.js'],
    transform: {
        '^.+\\.js$': 'babel-jest',
        '^.+\\.svg$': 'jest-svg-transformer',
    },
};
