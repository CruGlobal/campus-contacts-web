import angular from 'angular';
import React, { lazy, Suspense } from 'react';
import { react2angular } from 'react2angular';

import { GraphqlPlaygroundProps } from './GraphqlPlayground';

const GraphqlPlayground = lazy(() =>
    import(/* webpackChunkName: "graphql-playground" */ './GraphqlPlayground'),
);

const GraphqlPlaygroundLoader = (props: GraphqlPlaygroundProps) => (
    <Suspense
        fallback={
            <h1 style={{ margin: '2em' }}>
                Loading GraphQL Playground JS bundle...
            </h1>
        }
    >
        <GraphqlPlayground {...props} />
    </Suspense>
);

angular
    .module('missionhubApp')
    .component(
        'graphqlPlayground',
        react2angular(GraphqlPlaygroundLoader, null, [
            'authenticationService',
            'envService',
        ]),
    );
