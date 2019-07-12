module.exports = {
    roots: ['src/'],
    setupFilesAfterEnv: ['./src/setupTests.js'],
    transform: {
        '^.+\\.js$': 'babel-jest',
        '^.+\\.svg$': 'jest-svg-transformer',
    },
    coverageDirectory: './coverage-react/',
    moduleNameMapper: {
        '\\.(css|less|scss|sss|styl)$': 'jest-css-modules',
    },
};
