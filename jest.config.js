module.exports = {
    roots: ['src/'],
    setupFiles: [
        '<rootDir>/__mocks__/regeneratorRuntime.ts',
        '<rootDir>/__mocks__/init-i18next.ts',
        '<rootDir>/__mocks__/apolloClient.ts',
    ],
    setupFilesAfterEnv: ['<rootDir>/__mocks__/resetGlobalMockSeeds.ts'],
    transform: {
        '^.+\\.js$': 'babel-jest',
        '^.+\\.tsx?$': 'ts-jest',
    },
    coverageDirectory: './coverage-react/',
    moduleNameMapper: {
        '\\.(css|less|scss|sss|styl)$': 'jest-css-modules',
        '\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$':
            '<rootDir>/__mocks__/fileMock.ts',
    },
    testPathIgnorePatterns: ['__generated__'],
    snapshotSerializers: ['jest-emotion'],
};
