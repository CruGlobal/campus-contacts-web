import React from 'react';
import Navigation from './navigation';
import { waitForElement } from '@testing-library/react';
import { BrowserRouter as Router } from 'react-router-dom';

import { renderWithContext } from '../testUtils';

describe('<Navigation />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(
            <Router>
                <Navigation orgId={1} person={{ full_name: 'test' }} />
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
                <Navigation orgId={1} person={{ full_name: 'test' }} />
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
