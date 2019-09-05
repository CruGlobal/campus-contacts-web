import React, { ReactNode, ReactElement } from 'react';
import { ApolloProvider } from 'react-apollo-hooks';
import { render } from '@testing-library/react';
import { ThemeProvider } from 'emotion-theming';
import { IMocks } from 'graphql-tools';

import defaultTheme from '../defaultTheme';
import {
    AppContext,
    AppContextValue,
    appContextDefaultValue,
} from '../appContext';

import { createApolloMockClient } from './apolloMockClient';

interface RenderWithContextParams {
    mocks?: IMocks;
    appContext?: AppContextValue;
}

export const renderWithContext = (
    component: ReactElement,
    {
        mocks: mocks = {},
        appContext = appContextDefaultValue,
    }: RenderWithContextParams = {},
) => {
    const mockApolloClient = createApolloMockClient(mocks);

    // Warning: don't call any functions in here that return new instances on every call.
    // All the props need to stay the same otherwise renderer won't work.
    const wrapper = ({ children }: { children?: ReactNode }) => (
        <ApolloProvider client={mockApolloClient}>
            <AppContext.Provider value={appContext}>
                <ThemeProvider theme={defaultTheme}>{children}</ThemeProvider>
            </AppContext.Provider>
        </ApolloProvider>
    );

    const renderResult = render(component, { wrapper });
    return {
        ...renderResult,
        snapshot: () => {
            expect(renderResult.container).toMatchSnapshot();
        },
    };
};
