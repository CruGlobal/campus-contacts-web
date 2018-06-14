# To generate AngularJS $inject annotations:

```
yarn add -D babel-cli babel-plugin-angularjs-annotate
npx babel src/angularjs --out-dir src/angularjs --ignore '**/*.spec.js' --plugins=angularjs-annotate
```
