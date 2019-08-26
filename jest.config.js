module.exports = {
    roots: ['src/'],
    setupFilesAfterEnv: ['./src/setupTests.js'],
    transform: {
        '^.+\\.js$': 'babel-jest',
        '^.+\\.tsx?$': 'ts-jest',
    },
    coverageDirectory: './coverage-react/',
    moduleNameMapper: {
        '\\.(css|less|scss|sss|styl)$': 'jest-css-modules',
        '\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$':
            '<rootDir>/src/dashboard/testUtils/fileMock.js',
    },
};
