# MissionHub Web App

[![Build Status](https://travis-ci.org/CruGlobal/missionhub-web.svg?branch=master)](https://travis-ci.org/CruGlobal/missionhub-web) [![codecov](https://codecov.io/gh/CruGlobal/missionhub-web/branch/master/graph/badge.svg)](https://codecov.io/gh/CruGlobal/missionhub-web)
[missionhub.com](https://www.missionhub.com) | [stage.missionhub.com](https://stage.missionhub.com)

## Development

### Installing yarn
Use yarn for faster installs and to update the yarn lock file: https://yarnpkg.com/en/docs/install

### Install & Run

1. `yarn` or `npm install`
2. `yarn start` or `npm start`
3. Currently this repo needs to be run inside the legacy missionhub rails app. Clone and run the [missionhub](https://github.com/CruGlobal/missionhub) and [missionhub-api](https://github.com/CruGlobal/missionhub-api) repos. `yarn run start-rails-web` and `start-rails-api` can be used as shortcuts to start the respective rails servers if you have cloned all of these repos in the same parent directory.
3. Browse to [`http://localhost:3000`](http://localhost:3000) (url of legacy rails app)

### Development Tasks
Note: you may replace `yarn` with `npm` if you aren't using `yarn`
- `yarn start` to start the webpack dev server for this repo
- `yarn run start-rails-web` to start the legacy rails web server (looks in `../missionhub`)
- `yarn run start-rails-api` to start the rails api server (looks in `../missionhub-api`)
- `yarn run build` to generate minified output files. These files are output to `/dist`.
- `yarn run build:analyze` to open a visualization of bundle sizes after building
- `yarn run test` to run karma tests once
- `yarn run test-watch` to run karma tests on file changes
- `yarn run test-debug` to run karma tests in Chrome process for debugging with Chrome's dev tools
- `yarn run lint` to run eslint and lint the app's JS files

### Deployment

- Development should be done against `master`. Code merged to `master` will be deployed immediately to the production environment.
- The `staging` branch deploys immediately to the staging environment. You can hard reset the `staging` to whatever commit you want to deploy to stage or merge code into that branch.
- Currently the legacy rails all uses `manifest.json` (output by webpack in `/dist`) to get the correct urls of the other `/dist` files.

### Adding dependencies

- Use `yarn add <package-name>` to install app dependencies
- Use `yarn add <package-name> -dev` to install tooling dependencies
