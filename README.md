# Campus Contacts Web App

[![Build Status](https://travis-ci.com/CruGlobal/campus-contacts-web.svg?branch=master)](https://travis-ci.com/CruGlobal/campus-contacts-web) [![codecov](https://codecov.io/gh/CruGlobal/campus-contacts-web/branch/master/graph/badge.svg)](https://codecov.io/gh/CruGlobal/campus-contacts-web)
[campuscontacts.cru.org](https://campuscontacts.cru.org) | [stage.campuscontacts.cru.org](https://stage.campuscontacts.cru.org) | [ccontacts.app/](https://ccontacts.app/) | [stage.ccontacts.app/](https://stage.ccontacts.app/)

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
- `yarn start-rails-api` to start the rails api server (looks in `../campus-contacts-api`)
- `yarn build` to generate minified output files. These files are output to `/dist`.
- `yarn build:analyze` to open a visualization of bundle sizes after building
- `yarn test` to run karma tests once
- `yarn test-watch` to run karma tests on file changes
- `yarn test-debug` to run karma tests in Chrome process for debugging with Chrome's dev tools
- `yarn lint` to run eslint and lint the app's JS files

### Environment Config
By default running this repo locally hits the stage API server. If you need to test against the local API, you can edit [campusContactsApp.config.js](https://github.com/CruGlobal/campus-contacts-web/blob/master/app/assets/javascripts/angular/campusContactsApp.config.js#L17).

### Deployment

- Development should be done against `master`. Code merged to `master` will be deployed immediately to the production environment.
- The `staging` branch deploys immediately to the staging environment. You can hard reset the `staging` to whatever commit you want to deploy to stage or merge code into that branch.

### Adding dependencies

- Use `yarn add <package-name>` to install app dependencies
- Use `yarn add <package-name> -dev` to install tooling dependencies
