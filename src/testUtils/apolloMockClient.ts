import { ApolloClient } from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { SchemaLink } from 'apollo-link-schema';
import { addMockFunctionsToSchema } from 'graphql-tools';
import { buildClientSchema, IntrospectionQuery } from 'graphql/utilities';
import { createMockerFromIntrospection } from 'fraql/mock';
import gql from 'fraql';

import introspectionQuery from '../../schema.json';

import { globalMocks } from './globalMocks';

export const createApolloMockClient = (mocks = {}) => {
    const schema = buildClientSchema(
        (introspectionQuery as unknown) as IntrospectionQuery,
    );

    addMockFunctionsToSchema({
        schema,
        mocks: { ...globalMocks, ...mocks },
    });

    return new ApolloClient({
        cache: new InMemoryCache(),
        link: new SchemaLink({ schema }),
    });
};

export const mockFragment = (fragmentDocument: any, options: any) => {
    return createMockerFromIntrospection(introspectionQuery, {
        mocks: globalMocks,
    }).mockFragment(gql(fragmentDocument.loc.source.body), options);
};
