# MissionHub Web App

[![Build Status](https://travis-ci.org/CruGlobal/missionhub-web.svg?branch=master)](https://travis-ci.org/CruGlobal/missionhub-web) [![codecov](https://codecov.io/gh/CruGlobal/missionhub-web/branch/master/graph/badge.svg)](https://codecov.io/gh/CruGlobal/missionhub-web)
[missionhub.com](https://www.missionhub.com) | [stage.missionhub.com](https://stage.missionhub.com)

## Development

### Installing yarn
Use yarn for faster installs and to update the yarn lock file: https://yarnpkg.com/en/docs/install

### Install & Run

1. `yarn` or `npm install`
2. `yarn start` or `npm start`
3. Browse to [`https://localhost:8080`](https://localhost:8080)

### Development Tasks
Note: you may replace `yarn` with `npm` if you aren't using `yarn`
- `yarn start` to start the webpack dev server for this repo
- `yarn start-rails-api` to start the rails api server (looks in `../missionhub-api`)
- `yarn build` to generate minified output files. These files are output to `/dist`.
- `yarn build:analyze` to open a visualization of bundle sizes after building
- `yarn test` to run karma tests once
- `yarn test-watch` to run karma tests on file changes
- `yarn test-debug` to run karma tests in Chrome process for debugging with Chrome's dev tools
- `yarn lint` to run eslint and lint the app's JS files

### Environment Config
By default running this repo locally hits the stage API server. If you need to test against the local API, you can edit [missionhubApp.config.js](https://github.com/CruGlobal/missionhub-web/blob/6619d9325424bca3381c2187d3ad2d73894abb90/app/assets/javascripts/angular/missionhubApp.config.js#L22).

### Deployment

- Development should be done against `master`. Code merged to `master` will be deployed immediately to the production environment.
- The `staging` branch deploys immediately to the staging environment. You can hard reset the `staging` to whatever commit you want to deploy to stage or merge code into that branch.

### Adding dependencies

- Use `yarn add <package-name>` to install app dependencies
- Use `yarn add <package-name> -dev` to install tooling dependencies
