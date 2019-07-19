import React from 'react';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../testUtils';
import PersonalStepsReachedInfo from '../';

describe('<PersonalStepsReachedInfo />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<PersonalStepsReachedInfo />).snapshot();
    });

    it('should render properly with data', async () => {
        const { snapshot, getByText } = renderWithContext(
            <PersonalStepsReachedInfo />,
            {
                mocks: {
                    Query: () => ({
                        impactReport: () => ({
                            pathwayMovedCount: () => 13,
                        }),
                    }),
                },
                appContext: {
                    orgId: 1,
                },
            },
        );

        await waitForElement(() => getByText('This year', { exact: false }));
        snapshot();
    });
});
