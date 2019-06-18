import React from 'react';
import Navigation from './navigation';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../testUtils';

describe('<Navigation />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<Navigation orgId={1} />, {
            mocks: {
                Query: () => ({
                    organization: () => ({
                        id: '1',
                        name: 'Test Organization',
                    }),
                }),
            },
        }).snapshot();
    });

    it('should render properly', async () => {
        const { snapshot, getByText } = renderWithContext(
            <Navigation orgId={1} />,
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
        await waitForElement(() => getByText('Navigation: Test Organization'));
        snapshot();
    });
});
