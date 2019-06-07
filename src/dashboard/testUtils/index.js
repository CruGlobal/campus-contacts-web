import React, { ReactElement } from 'react';
import { ApolloProvider } from 'react-apollo-hooks';
import { render } from '@testing-library/react';

import { createApolloMockClient } from './apolloMockClient';

export const renderWithContext = (component, { mocks }) => {
    const mockApolloClient = createApolloMockClient(mocks);

    // Warning: don't call any functions in here that return new instances on every call.
    // All the props need to stay the same otherwise renderer won't work.
    const wrapper = ({ children }) => (
        <ApolloProvider client={mockApolloClient}>{children}</ApolloProvider>
    );

    const renderResult = render(component, { wrapper });

    return {
        ...renderResult,
        snapshot: () => {
            expect(renderResult.container).toMatchSnapshot();
        },
    };
};
