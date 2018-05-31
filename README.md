# MissionHub Web App

[![Build Status](https://travis-ci.org/CruGlobal/missionhub-web.svg?branch=master)](https://travis-ci.org/CruGlobal/missionhub-web) [![codecov](https://codecov.io/gh/CruGlobal/missionhub-web/branch/master/graph/badge.svg)](https://codecov.io/gh/CruGlobal/missionhub-web)
[missionhub.com](https://www.missionhub.com) | [stage.missionhub.com](https://stage.missionhub.com)

## Development

### Installing yarn
Use yarn for faster installs and to update the yarn lock file: https://yarnpkg.com/en/docs/install

### Install & Run

1. `yarn` or `npm install`
2. `yarn start` or `npm start`
3. Browse to [`http://localhost:4200`](http://localhost:4200)

### Deployment

- Development should be done against `master`. Code merged to `master` will be deployed immediately to the production environment.
- The `staging` branch deploys immediately to the staging environment. You can hard reset the `staging` to whatever commit you want to deploy to stage or merge code into that branch.

### Adding dependencies

- Use `yarn add <package-name>` to install app dependencies
- Use `yarn add <package-name> -dev` to install tooling dependencies

## Angular CLI Docs

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 6.0.8.

### Development server

Run `ng serve` for a dev server. Navigate to `http://localhost:4200/`. The app will automatically reload if you change any of the source files.

### Code scaffolding

Run `ng generate component component-name` to generate a new component. You can also use `ng generate directive|pipe|service|class|guard|interface|enum|module`.

### Build

Run `ng build` to build the project. The build artifacts will be stored in the `dist/` directory. Use the `--prod` flag for a production build.

### Running unit tests

Run `ng test` to execute the unit tests via [Karma](https://karma-runner.github.io).

### Running end-to-end tests

Run `ng e2e` to execute the end-to-end tests via [Protractor](http://www.protractortest.org/).

### Further help

To get more help on the Angular CLI use `ng help` or go check out the [Angular CLI README](https://github.com/angular/angular-cli/blob/master/README.md).
