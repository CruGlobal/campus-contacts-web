import React from 'react';
import Navigation from './navigation';
import { waitForElement } from '@testing-library/react';
import { BrowserRouter as Router } from 'react-router-dom';

import { renderWithContext } from '../testUtils';
import AppContext from '../appContext';

describe('<Navigation />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(
            <Router>
                <AppContext.Provider value={{ person: { full_name: 'test' } }}>
                    <Navigation orgId={1} />
                </AppContext.Provider>
            </Router>,
            {
                mocks: {
                    Query: () => ({
                        organization: () => ({
                            id: '1',
                            name: 'Test Organization',
                        }),
                    }),
                },
            },
        ).snapshot();
    });

    it('should render properly', async () => {
        const { snapshot, getByText } = renderWithContext(
            <Router>
                <AppContext.Provider value={{ person: { full_name: 'test' } }}>
                    <Navigation orgId={'1'} />
                </AppContext.Provider>
            </Router>,
            {
                mocks: {
                    Query: () => ({
                        organization: () => ({
                            id: '1',
                            name: 'Test Organization',
                        }),
                    }),
                },
            },
        );
        await waitForElement(() => getByText('Test Organization'));
        snapshot();
    });
});
