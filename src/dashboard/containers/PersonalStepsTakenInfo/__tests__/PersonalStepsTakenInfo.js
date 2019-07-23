// Vendors
import React from 'react';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../testUtils';
import PersonalStepsTakenInfo from '../';
import PersonalStepsReachedInfo from '../../PersonalStepsReachedInfo';

describe('<PersonalStepsTakenInfo />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<PersonalStepsTakenInfo />, {
            appContext: {
                orgId: 1,
            },
        }).snapshot();
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
